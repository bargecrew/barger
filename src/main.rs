extern crate chrono;
#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate serde;

mod models;
mod schema;

use actix_web::{get, App, HttpServer, HttpResponse};
use dotenv::dotenv;
use std::env;

#[get("/api/status")]
async fn status() -> HttpResponse {
    let version = env::var("CARGO_PKG_VERSION").expect("CARGO_PKG_VERSION must be set");
    HttpResponse::Ok().json(models::responses::GetStatusResponse{
        version: version,
    })
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();

    let host = env::var("HOST").expect("HOST must be set");
    let port = env::var("PORT").expect("PORT must be set");

    HttpServer::new(|| {
        App::new()
            .service(status)
    })
    .bind(format!("{host}:{port}", host = host, port = port))?
    .run()
    .await
}
