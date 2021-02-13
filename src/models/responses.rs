use serde::{Serialize};

// - /api/status
#[derive(Serialize)]
pub struct GetStatusResponse {
    pub version: String,
}

// - /api/health
#[derive(Serialize)]
pub struct GetHealthReadyResponse {}

#[derive(Serialize)]
pub struct GetHealthLiveResponse {}

// - /api/users
#[derive(Serialize)]
pub struct GetUsersResponse {
    pub users: Vec<String>,
}
