table! {
    change_sets (id) {
        id -> Int4,
        branch -> Varchar,
        commit -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    clusters (id) {
        id -> Int4,
        name -> Varchar,
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
    resources (id) {
        id -> Int4,
        name -> Varchar,
        content -> Json,
        service_id -> Nullable<Int4>,
        change_set_id -> Nullable<Int4>,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

table! {
    services (id) {
        id -> Int4,
        name -> Varchar,
        group_id -> Nullable<Int4>,
        cluster_id -> Nullable<Int4>,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

joinable!(resources -> change_sets (change_set_id));
joinable!(resources -> services (service_id));
joinable!(services -> clusters (cluster_id));
joinable!(services -> groups (group_id));

allow_tables_to_appear_in_same_query!(
    change_sets,
    clusters,
    groups,
    resources,
    services,
);
