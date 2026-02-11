defmodule Elixir4vet.AuthorizationVerificationTest do
  use Elixir4vet.DataCase

  alias Elixir4vet.{Accounts, Authorization}
  import Elixir4vet.AccountsFixtures

  test "unification of authorization system" do
    # Ensure there's at least one user so the test user isn't the first (and doesn't get admin)
    _first_user = user_fixture()

    # 1. Create a user
    user = user_fixture()
    IO.puts("Created user: #{user.email}")

    # 2. Check default admin status (should be false)
    refute Accounts.admin?(user), "New user should not be admin"
    IO.puts("✅ PASS: Default user is not admin")

    # 3. Assign 'admin' role via Authorization context
    {:ok, _} = Authorization.assign_role_by_name(user, "admin")
    IO.puts("Assigned admin role")

    # 4. Check admin status again (should be true)
    # We might need to reload user or roles, but admin? checks via Repo queries internally usually?
    # Let's see how user_has_role? is implemented. It calls get_user_roles(user).
    # get_user_roles queries the DB, so we don't need to reload the user struct necessarily
    # if we pass the ID or if it uses the ID.
    # Authorization.user_has_role? takes %User{}.

    assert Accounts.admin?(user), "User should be admin after role assignment"
    IO.puts("✅ PASS: User is now admin via RBAC")
  end
end
