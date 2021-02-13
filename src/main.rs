extern crate chrono;
#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate serde;

mod authorization;
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

    actix_web::HttpServer::new(|| {
        actix_web::App::new()
            .wrap(actix_web::middleware::Logger::default())
            .wrap(actix_cors::Cors::default())
            // health
            .service(handlers::health::ready)
            .service(handlers::health::live)
            // status
            .service(handlers::status::get)
            // authorized
            .service(
                actix_web::web::scope("")
                    .wrap(actix_web_httpauth::middleware::HttpAuthentication::basic(authorization::authorize))
                    .service(handlers::users::get)
            )
    })
    .bind(format!("{host}:{port}", host = host, port = port))?
    .run()
    .await
}
