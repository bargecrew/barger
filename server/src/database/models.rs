use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

#[derive(Queryable, Debug, Serialize, Deserialize)]
pub struct ChangeSet {
    pub id: i32,
    pub branch: String,
    pub commit: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Queryable, Debug, Serialize, Deserialize)]
pub struct Cluster {
    pub id: i32,
    pub name: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Queryable, Debug, Serialize, Deserialize)]
pub struct Configuration {
    pub id: i32,
    pub key: String,
    pub value: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Queryable, Debug, Serialize, Deserialize)]
pub struct Group {
    pub id: i32,
    pub name: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Queryable, Debug, Serialize, Deserialize)]
pub struct Resource {
    pub id: i32,
    pub name: String,
    pub content: String,
    pub service_id: i32,
    pub change_set_id: i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Queryable, Debug, Serialize, Deserialize)]
pub struct Secret {
    pub id: i32,
    pub key: String,
    pub value: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Queryable, Debug, Serialize, Deserialize)]
pub struct Service {
    pub id: i32,
    pub name: String,
    pub group_id: i32,
    pub cluster_id: i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}
