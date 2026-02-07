# Get the most recently logged in user (or specify email)
alias Elixir4vet.{Accounts, Authorization, Repo}

# Option A: Get user by email
email = IO.gets("Enter user email: ") |> String.trim()
user = Accounts.get_user_by_email(email)

if user do
  # Assign admin role via new RBAC system
  admin_role = Authorization.get_role_by_name("admin")
  
  case Authorization.assign_role(user, admin_role) do
    {:ok, _} ->
      IO.puts("✅ Successfully made #{user.email} an administrator!")
      IO.puts("User now has admin role with full permissions.")
    {:error, _} ->
      IO.puts("⚠️  User may already have admin role")
  end
else
  IO.puts("❌ User not found with email: #{email}")
end
