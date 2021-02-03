use crate::models;

use std::env;

#[actix_web::get("/api/status")]
async fn get() -> actix_web::HttpResponse {
    let version = env::var("CARGO_PKG_VERSION").expect("CARGO_PKG_VERSION must be set");
    actix_web::HttpResponse::Ok().json(models::responses::GetStatusResponse{
        version,
    })
}