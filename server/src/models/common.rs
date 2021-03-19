use crate::database;
use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Cluster {
    pub id: i32,
    pub name: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

pub fn new_cluster(cluster: database::models::Cluster) -> Cluster {
    Cluster {
        id: cluster.id,
        name: cluster.name,
        created_at: cluster.created_at,
        updated_at: cluster.updated_at,
    }
}
