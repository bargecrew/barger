use serde::Deserialize;

#[derive(Deserialize)]
pub struct PostClustersRequest {
    pub name: String,
}
