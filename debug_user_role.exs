
alias Elixir4vet.{Repo, Accounts, Authorization}
alias Elixir4vet.Accounts.User
import Ecto.Query

email = "maksud.nurullaev@gmail.com"
user = Repo.get_by(User, email: email)

if user do
  IO.puts "User found: #{user.email}"
  IO.puts "Legacy role field: #{user.role}"
  
  IO.puts "Checking Accounts.admin?(user)..."
  is_admin = Accounts.admin?(user)
  IO.puts "Is Admin? #{is_admin}"

  roles = Authorization.get_user_roles(user)
  IO.puts "Assigned Roles: #{inspect(Enum.map(roles, & &1.name))}"
  
  if !is_admin do 
     IO.puts "Attempting to fix by assigning admin role..."
     case Authorization.assign_role_by_name(user, "admin") do
       {:ok, _} -> IO.puts "Successfully assigned admin role."
       {:error, reason} -> IO.puts "Failed to assign role: #{inspect(reason)}"
     end
  end
else
  IO.puts "User #{email} not found!"
end
