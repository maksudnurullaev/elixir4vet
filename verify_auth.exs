
alias Elixir4photos.{Accounts, Authorization}
alias Elixir4photos.AccountsFixtures

# 1. Create a user
user = AccountsFixtures.user_fixture()
IO.puts "Created user: #{user.email}"

# 2. Check default admin status (should be false)
is_admin = Accounts.admin?(user)
IO.puts "Is admin (default)? #{is_admin}"

if is_admin do
  raise "New user should not be admin!"
else
  IO.puts "✅ PASS: Default user is not admin"
end

# 3. Assign 'admin' role via Authorization context
case Authorization.assign_role_by_name(user, "admin") do
  {:ok, _} -> IO.puts "Assigned admin role"
  error -> raise "Failed to assign role: #{inspect(error)}"
end

# 4. Check admin status again (should be true)
is_admin_now = Accounts.admin?(user)
IO.puts "Is admin (after assignment)? #{is_admin_now}"

if is_admin_now do
  IO.puts "✅ PASS: User is now admin via RBAC"
else
  raise "User should be admin after role assignment!"
end

IO.puts "🎉 Verification Successful!"
