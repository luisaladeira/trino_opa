package trino
import data.assets_mapping
import data.users.users
default allow := true


# Allow access based on user permissions from users.json
allow := false if {
    schema := input.action.resource.table.schemaName
    table := input.action.resource.table.tableName
    not table_has_mapping(schema, table)
}

table_has_mapping(schema, table) = true if {
    data.assets_mapping[schema][table]
}

batch := [ i |
    some i
    input.action.filterResources[i]
    user := input.context.identity.user
    data.users[user]  # User must exist in our database
]
