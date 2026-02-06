defmodule Mix.Tasks.Admin.Make do
  @moduledoc """
  Make a user an administrator.

  ## Examples

      # Make user admin by email
      mix admin.make user@example.com

      # Make the first user admin
      mix admin.make --first

      # Make the most recent user admin
      mix admin.make --recent
  """

  use Mix.Task
  import Ecto.Query

  alias Elixir4photos.{Accounts, Authorization, Repo}

  @shortdoc "Make a user an administrator"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    case args do
      ["--first"] ->
        make_first_user_admin()

      ["--recent"] ->
        make_recent_user_admin()

      [email] ->
        make_user_admin(email)

      [] ->
        show_help()

      _ ->
        Mix.shell().error("Invalid arguments. See help below:")
        show_help()
    end
  end

  defp make_user_admin(email) do
    case Accounts.get_user_by_email(email) do
      nil ->
        Mix.shell().error("❌ User not found with email: #{email}")
        Mix.shell().info("\nAvailable users:")
        list_users()

      user ->
        assign_admin_role(user)
    end
  end

  defp make_first_user_admin do
    case Repo.one(from u in Elixir4photos.Accounts.User, order_by: [asc: u.id], limit: 1) do
      nil ->
        Mix.shell().error("❌ No users found in database")

      user ->
        Mix.shell().info("Making first user admin: #{user.email}")
        assign_admin_role(user)
    end
  end

  defp make_recent_user_admin do
    case Repo.one(from u in Elixir4photos.Accounts.User, order_by: [desc: u.inserted_at], limit: 1) do
      nil ->
        Mix.shell().error("❌ No users found in database")

      user ->
        Mix.shell().info("Making most recent user admin: #{user.email}")
        assign_admin_role(user)
    end
  end

  defp assign_admin_role(user) do
    admin_role = Authorization.get_role_by_name("admin")

    if admin_role do
      case Authorization.assign_role(user, admin_role) do
        {:ok, _} ->
          Mix.shell().info("✅ Successfully made #{user.email} an administrator!")
          Mix.shell().info("")
          Mix.shell().info("User now has admin role with permissions:")
          show_admin_permissions()
          Mix.shell().info("")
          Mix.shell().info("They can now access:")
          Mix.shell().info("  • /admin/users - User management")
          Mix.shell().info("  • /admin/permissions - Permission matrix")

        {:error, %{errors: errors}} ->
          if Keyword.has_key?(errors, :user_id) do
            Mix.shell().info("⚠️  User already has admin role!")
            verify_permissions(user)
          else
            Mix.shell().error("❌ Failed to assign admin role")
            IO.inspect(errors)
          end
      end
    else
      Mix.shell().error("❌ Admin role not found. Run migrations first:")
      Mix.shell().info("    mix ecto.migrate")
    end
  end

  defp verify_permissions(user) do
    roles = Authorization.get_user_roles(user)
    admin_role = Enum.find(roles, &(&1.name == "admin"))

    if admin_role do
      Mix.shell().info("✅ Confirmed: User has admin role")
      show_admin_permissions()
    else
      Mix.shell().info("⚠️  User doesn't have admin role. Assigning now...")
      assign_admin_role(user)
    end
  end

  defp show_admin_permissions do
    Mix.shell().info("  • People: RW")
    Mix.shell().info("  • Organizations: RW")
    Mix.shell().info("  • Animals: RW")
    Mix.shell().info("  • Events: RW")
    Mix.shell().info("  • Photographs: RW")
    Mix.shell().info("  • Users: RW")
  end

  defp list_users do
    import Ecto.Query

    users = Repo.all(from u in Elixir4photos.Accounts.User, order_by: [desc: u.inserted_at], limit: 10)

    if Enum.empty?(users) do
      Mix.shell().info("  (no users in database)")
    else
      Enum.each(users, fn user ->
        Mix.shell().info("  • #{user.email} (ID: #{user.id})")
      end)
    end
  end

  defp show_help do
    Mix.shell().info("""
    Usage:
      mix admin.make <email>     Make user with email an admin
      mix admin.make --first     Make the first user an admin
      mix admin.make --recent    Make the most recent user an admin

    Examples:
      mix admin.make user@example.com
      mix admin.make --first
      mix admin.make --recent
    """)
  end
end
