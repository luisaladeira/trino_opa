package trino

# Import data diretamente (sem alias)
import data

# Default deny
default allow := false

# Allow access based on user permissions from users.json
allow if {
    user := input.context.identity.user
    operation := input.action.operation
    user_has_permission(user, operation)
    not is_restricted_column_access(user, operation)
}

# Admin has all permissions (wildcard)
user_has_permission(user, operation) if {
    data.users[user].role == "admin"
}

# Allow specific operations based on role permissions
user_has_permission(user, operation) if {
    user_role := data.users[user].role
    role_permissions := data.roles[user_role].permissions
    operation in role_permissions
}

# Allow wildcard permissions (admin)
user_has_permission(user, operation) if {
    user_role := data.users[user].role
    role_permissions := data.roles[user_role].permissions
    "*" in role_permissions
}

# Check if this is a restricted column access for analysts
is_restricted_column_access(user, operation) if {
    # Only apply to SelectFromColumns operations
    operation == "SelectFromColumns"

    # Only for analysts
    user_role := data.users[user].role
    user_role == "analyst"

    # Check if any of the columns being accessed are restricted
    restricted_columns := data.roles[user_role].restricted_columns
    table_columns := input.action.resource.table.columns

    # If any column in the table is restricted for this analyst
    some column in table_columns
    column in restricted_columns
}

# Filtered columns for analysts (restricts sensitive data)
filtered_columns contains column if {
    user := input.context.identity.user
    user_role := data.users[user].role

    # If user is analyst, filter restricted columns
    user_role == "analyst"

    restricted := data.roles[user_role].restricted_columns
    column_name := input.action.resource.column.columnName
    column_name in restricted
    column := column_name
}
