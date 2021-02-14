table! {
    clusters (id) {
        id -> Int4,
        name -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    group_permissions (id) {
        id -> Int4,
        group_id -> Int4,
        permission_id -> Int4,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    groups (id) {
        id -> Int4,
        name -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    permissions (id) {
        id -> Int4,
        value -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    tokens (id) {
        id -> Int4,
        token -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    user_groups (id) {
        id -> Int4,
        user_id -> Int4,
        group_id -> Int4,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    user_tokens (id) {
        id -> Int4,
        user_id -> Int4,
        token_id -> Int4,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    users (id) {
        id -> Int4,
        admin -> Bool,
        username -> Varchar,
        password -> Varchar,
        email -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

joinable!(group_permissions -> groups (group_id));
joinable!(group_permissions -> permissions (permission_id));
joinable!(user_groups -> groups (group_id));
joinable!(user_groups -> users (user_id));
joinable!(user_tokens -> tokens (token_id));
joinable!(user_tokens -> users (user_id));

allow_tables_to_appear_in_same_query!(
    clusters,
    group_permissions,
    groups,
    permissions,
    tokens,
    user_groups,
    user_tokens,
    users,
);
