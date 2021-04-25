extern crate chrono;
#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate serde;

mod authorization;
mod config;
mod database;
mod handlers;
mod models;
mod schema;

use dotenv::dotenv;
use std::env;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();

    let host = env::var("HOST").expect("HOST must be set");
    let port = env::var("PORT").expect("PORT must be set");

    println!("Listening on {}:{}", host, port);

    actix_web::HttpServer::new(|| {
        actix_web::App::new()
            .wrap(actix_web::middleware::Logger::default())
            .wrap(actix_cors::Cors::default())
            .configure(config::config)
    })
    .bind(format!("{host}:{port}", host = host, port = port))?
    .run()
    .await
}
