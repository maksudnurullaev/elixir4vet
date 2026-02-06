defmodule Elixir4photos.Repo.Migrations.CreateRbacSystem do
  use Ecto.Migration

  def change do
    # ROLES table - Define roles in the system
    create table(:roles) do
      add :name, :string, null: false
      add :description, :string
      add :is_system_role, :boolean, default: false  # For built-in roles like admin

      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:name])

    # USER_ROLES - Assign roles to users (many-to-many)
    create table(:user_roles) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :role_id, references(:roles, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_roles, [:user_id])
    create index(:user_roles, [:role_id])
    create unique_index(:user_roles, [:user_id, :role_id])

    # ROLE_PERMISSIONS - Define what each role can do on each resource
    create table(:role_permissions) do
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      add :resource, :string, null: false  # e.g., "people", "animals", "events"
      add :permission, :string, null: false  # "NA", "RO", "RW"

      timestamps(type: :utc_datetime)
    end

    create index(:role_permissions, [:role_id])
    create index(:role_permissions, [:resource])
    create unique_index(:role_permissions, [:role_id, :resource])

    # Seed initial roles
    execute """
    INSERT INTO roles (name, description, is_system_role, inserted_at, updated_at)
    VALUES
      ('admin', 'Full system administrator', true, datetime('now'), datetime('now')),
      ('manager', 'Can manage most resources', true, datetime('now'), datetime('now')),
      ('user', 'Regular user with limited access', true, datetime('now'), datetime('now')),
      ('guest', 'Read-only access', true, datetime('now'), datetime('now'))
    """, """
    DELETE FROM roles WHERE is_system_role = true
    """

    # Seed admin permissions (RW on everything)
    execute """
    INSERT INTO role_permissions (role_id, resource, permission, inserted_at, updated_at)
    SELECT r.id, resource, 'RW', datetime('now'), datetime('now')
    FROM roles r, (
      SELECT 'organizations' as resource
      UNION SELECT 'animals'
      UNION SELECT 'events'
      UNION SELECT 'photographs'
      UNION SELECT 'users'
    )
    WHERE r.name = 'admin'
    """, """
    DELETE FROM role_permissions WHERE role_id IN (SELECT id FROM roles WHERE name = 'admin')
    """

    # Seed manager permissions
    execute """
    INSERT INTO role_permissions (role_id, resource, permission, inserted_at, updated_at)
    SELECT r.id, 'organizations', 'RW', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'manager'
    UNION ALL
    SELECT r.id, 'animals', 'RW', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'manager'
    UNION ALL
    SELECT r.id, 'events', 'RW', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'manager'
    UNION ALL
    SELECT r.id, 'photographs', 'RW', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'manager'
    UNION ALL
    SELECT r.id, 'users', 'RO', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'manager'
    """, """
    DELETE FROM role_permissions WHERE role_id IN (SELECT id FROM roles WHERE name = 'manager')
    """

    # Seed regular user permissions
    execute """
    INSERT INTO role_permissions (role_id, resource, permission, inserted_at, updated_at)
    SELECT r.id, 'organizations', 'RO', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'user'
    UNION ALL
    SELECT r.id, 'animals', 'RO', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'user'
    UNION ALL
    SELECT r.id, 'events', 'RO', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'user'
    UNION ALL
    SELECT r.id, 'photographs', 'RO', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'user'
    UNION ALL
    SELECT r.id, 'users', 'NA', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'user'
    """, """
    DELETE FROM role_permissions WHERE role_id IN (SELECT id FROM roles WHERE name = 'user')
    """

    # Seed guest permissions (all read-only or no access)
    execute """
    INSERT INTO role_permissions (role_id, resource, permission, inserted_at, updated_at)
    SELECT r.id, 'organizations', 'RO', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'guest'
    UNION ALL
    SELECT r.id, 'animals', 'RO', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'guest'
    UNION ALL
    SELECT r.id, 'events', 'NA', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'guest'
    UNION ALL
    SELECT r.id, 'photographs', 'NA', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'guest'
    UNION ALL
    SELECT r.id, 'users', 'NA', datetime('now'), datetime('now')
    FROM roles r WHERE r.name = 'guest'
    """, """
    DELETE FROM role_permissions WHERE role_id IN (SELECT id FROM roles WHERE name = 'guest')
    """

    # Migrate existing users with 'admin' role field to new system
    execute """
    INSERT INTO user_roles (user_id, role_id, inserted_at, updated_at)
    SELECT u.id, r.id, datetime('now'), datetime('now')
    FROM users u
    JOIN roles r ON (
      CASE
        WHEN u.role = 'admin' THEN r.name = 'admin'
        ELSE r.name = 'user'
      END
    )
    """, """
    DELETE FROM user_roles
    """
  end
end
