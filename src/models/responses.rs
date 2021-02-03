use serde::{Serialize};

#[derive(Serialize)]
pub struct GetStatusResponse {
    pub version: String,
}

#[derive(Serialize)]
pub struct GetHealthReadyResponse {}

#[derive(Serialize)]
pub struct GetHealthLiveResponse {}
