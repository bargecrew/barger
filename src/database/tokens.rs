use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::sql_types::Bool;

#[derive(QueryableByName)]
pub struct HasPermission {
    #[sql_type = "Bool"]
    pub permission: bool,
}

pub fn has_permission(connection: &PgConnection, token: &str, permission: &str) -> bool {
    diesel::sql_query("SELECT TRUE")
        .get_result::<HasPermission>(connection)
        .ok()
        .unwrap()
        .permission
}
