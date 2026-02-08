defmodule Elixir4vet.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Elixir4vet.Repo

  alias Elixir4vet.Accounts.{User, UserToken, UserNotifier}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user (email only, for magic link).
  New users start as "guest" role until they confirm their email.
  First user gets "admin" role immediately.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    # Check if this is the first user
    is_first_user = Repo.aggregate(User, :count, :id) == 0

    changeset =
      %User{}
      |> User.email_changeset(attrs)

    case Repo.insert(changeset) do
      {:ok, user} = result ->
        # Assign role in RBAC system
        role_name = if is_first_user, do: "admin", else: "guest"

        case Elixir4vet.Authorization.get_role_by_name(role_name) do
          nil -> result
          role -> Elixir4vet.Authorization.assign_role(user, role)
        end

        result

      error ->
        error
    end
  end

  @doc """
  Registers a user with password and phone.
  Users with password are auto-confirmed and get "user" role.
  First user gets "admin" role.

  ## Examples

      iex> register_user_with_password(%{email: ..., password: ..., phone: ...})
      {:ok, %User{}}

      iex> register_user_with_password(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user_with_password(attrs) do
    # Check if this is the first user
    is_first_user = Repo.aggregate(User, :count, :id) == 0

    changeset =
      %User{}
      |> User.email_changeset(attrs)
      |> User.password_changeset(attrs)
      |> Ecto.Changeset.cast(attrs, [:phone])
      |> Ecto.Changeset.validate_required([:phone])
      |> User.confirm_changeset()

    changeset =
      if is_first_user do
        Ecto.Changeset.put_change(changeset, :role, "admin")
      else
        # Password users are auto-confirmed, so they get "user" role
        Ecto.Changeset.put_change(changeset, :role, "user")
      end

    case Repo.insert(changeset) do
      {:ok, user} = result ->
        # Assign role in RBAC system
        role_name = if is_first_user, do: "admin", else: "user"

        case Elixir4vet.Authorization.get_role_by_name(role_name) do
          nil -> result
          role -> Elixir4vet.Authorization.assign_role(user, role)
        end

        result

      error ->
        error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user registration changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(user, attrs \\ %{}) do
    user
    |> User.email_changeset(attrs, validate_unique: false)
    |> User.password_changeset(attrs, hash_password: false)
    |> Ecto.Changeset.cast(attrs, [:phone])
  end

  ## Settings

  @doc """
  Checks whether the user is in sudo mode.

  The user is in sudo mode when the last authentication was done no further
  than 20 minutes ago. The limit can be given as second argument in minutes.
  """
  def sudo_mode?(user, minutes \\ -20)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    DateTime.after?(ts, DateTime.utc_now() |> DateTime.add(minutes, :minute))
  end

  def sudo_mode?(_user, _minutes), do: false

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  See `Elixir4vet.Accounts.User.email_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}, opts \\ []) do
    User.email_changeset(user, attrs, opts)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    Repo.transact(fn ->
      with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
           %UserToken{sent_to: email} <- Repo.one(query),
           {:ok, user} <- Repo.update(User.email_changeset(user, %{email: email})),
           {_count, _result} <-
             Repo.delete_all(from(UserToken, where: [user_id: ^user.id, context: ^context])) do
        {:ok, user}
      else
        _ -> {:error, :transaction_aborted}
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  See `Elixir4vet.Accounts.User.password_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}, opts \\ []) do
    User.password_changeset(user, attrs, opts)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user profile.

  ## Examples

      iex> change_user_profile(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_profile(user, attrs \\ %{}) do
    User.profile_changeset(user, attrs)
  end

  @doc """
  Updates the user profile.

  ## Examples

      iex> update_user_profile(user, %{first_name: ...})
      {:ok, %User{}}

      iex> update_user_profile(user, %{first_name: ""})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_profile(user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates the user password.

  Returns a tuple with the updated user, as well as a list of expired tokens.

  ## Examples

      iex> update_user_password(user, %{password: ...})
      {:ok, {%User{}, [...]}}

      iex> update_user_password(user, %{password: "too short"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, attrs, opts \\ [validate_current_password: true]) do
    user
    |> User.password_changeset(attrs, opts)
    |> update_user_and_delete_all_tokens()
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.

  If the token is valid `{user, token_inserted_at}` is returned, otherwise `nil` is returned.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Gets the user with the given magic link token.
  """
  def get_user_by_magic_link_token(token) do
    with {:ok, query} <- UserToken.verify_magic_link_token_query(token),
         {user, _token} <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Logs the user in by magic link.

  There are three cases to consider:

  1. The user has already confirmed their email. They are logged in
     and the magic link is expired.

  2. The user has not confirmed their email and no password is set.
     In this case, the user gets confirmed, logged in, and all tokens -
     including session ones - are expired. In theory, no other tokens
     exist but we delete all of them for best security practices.
     Additionally, the user is upgraded from "guest" to "user" role.

  3. The user has not confirmed their email but a password is set.
     This cannot happen in the default implementation but may be the
     source of security pitfalls. See the "Mixing magic link and password registration" section of
     `mix help phx.gen.auth`.
  """
  def login_user_by_magic_link(token) do
    {:ok, query} = UserToken.verify_magic_link_token_query(token)

    case Repo.one(query) do
      # Prevent session fixation attacks by disallowing magic links for unconfirmed users with password
      {%User{confirmed_at: nil, hashed_password: hash}, _token} when not is_nil(hash) ->
        raise """
        magic link log in is not allowed for unconfirmed users with a password set!

        This cannot happen with the default implementation, which indicates that you
        might have adapted the code to a different use case. Please make sure to read the
        "Mixing magic link and password registration" section of `mix help phx.gen.auth`.
        """

      {%User{confirmed_at: nil} = user, _token} ->
        result =
          user
          |> User.confirm_changeset()
          |> update_user_and_delete_all_tokens()

        # Update RBAC system - upgrade guest to user role upon confirmation
        case result do
          {:ok, {confirmed_user, _tokens}} ->
            # Remove guest role and assign user role
            guest_roles = Elixir4vet.Authorization.get_user_roles(confirmed_user)

            Enum.each(guest_roles, fn role ->
              if role.name == "guest" do
                Elixir4vet.Authorization.remove_role(confirmed_user.id, role.id)
              end
            end)

            case Elixir4vet.Authorization.get_role_by_name("user") do
              nil -> :ok
              user_role -> Elixir4vet.Authorization.assign_role(confirmed_user, user_role)
            end

            result

          _ ->
            result
        end

      {user, token} ->
        Repo.delete!(token)
        {:ok, {user, []}}

      nil ->
        {:error, :not_found}
    end
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm-email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Delivers the magic link login instructions to the given user.
  """
  def deliver_login_instructions(%User{} = user, magic_link_url_fun)
      when is_function(magic_link_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "login")
    Repo.insert!(user_token)
    UserNotifier.deliver_login_instructions(user, magic_link_url_fun.(encoded_token))
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(from(UserToken, where: [token: ^token, context: "session"]))
    :ok
  end

  ## Token helper

  defp update_user_and_delete_all_tokens(changeset) do
    Repo.transact(fn ->
      with {:ok, user} <- Repo.update(changeset) do
        tokens_to_expire = Repo.all_by(UserToken, user_id: user.id)

        Repo.delete_all(from(t in UserToken, where: t.id in ^Enum.map(tokens_to_expire, & &1.id)))

        {:ok, {user, tokens_to_expire}}
      end
    end)
  end

  ## Admin functions

  @doc """
  Returns the list of all users (admin only).
  """
  def list_users do
    Repo.all(from u in User, order_by: [desc: u.inserted_at])
  end

  @doc """
  Returns paginated list of users (admin only).
  """
  def list_users(opts) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    offset = (page - 1) * per_page

    query = from u in User, order_by: [desc: u.inserted_at]

    users = Repo.all(from q in query, limit: ^per_page, offset: ^offset)
    total = Repo.aggregate(User, :count, :id)

    %{
      users: users,
      page: page,
      per_page: per_page,
      total: total,
      total_pages: ceil(total / per_page)
    }
  end

  @doc """
  Deletes a user (admin only).
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Checks if a user is an admin.
  """
  def admin?(%User{} = user), do: Elixir4vet.Authorization.user_has_role?(user, "admin")
  def admin?(_), do: false
end
