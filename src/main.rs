extern crate diesel;
extern crate dotenv;

mod schema;

use actix_web::{get, App, HttpServer, HttpResponse};
use dotenv::dotenv;
use std::env;

#[get("/api/status")]
async fn status() -> HttpResponse {
    HttpResponse::Ok().body("OK")
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
