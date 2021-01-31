use serde::{Serialize};

#[derive(Serialize)]
pub struct GetStatusResponse {
    pub version: String,
}