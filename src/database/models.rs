use chrono::{NaiveDateTime};
use serde::{Deserialize, Serialize};

#[derive(Queryable, Debug, Serialize, Deserialize)]
pub struct Cluster {
    pub id: i32,
    pub name: String,
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
pub struct Permission {
    pub id: i32,
    pub value: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Queryable, Debug, Serialize, Deserialize)]
pub struct User {
    pub id: i32,
    pub username: String,
    pub password: String,
    pub email: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}
