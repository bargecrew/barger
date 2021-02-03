extern crate chrono;
#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate serde;

mod handlers;
mod models;
mod schema;

use dotenv::dotenv;
use std::env;

async fn authorize(req: actix_web::dev::ServiceRequest, _credentials: actix_web_httpauth::extractors::bearer::BearerAuth) -> Result<actix_web::dev::ServiceRequest, actix_web::Error> {
    match req.path() {
        "/api/auth" => {
            Ok(req)
        },
        _ => {
            return Err(actix_web::error::ErrorNotFound("Not Found"));
        }
    }
}

#[actix_web::get("/api/auth")]
async fn auth() -> actix_web::HttpResponse {
    let version = env::var("CARGO_PKG_VERSION").expect("CARGO_PKG_VERSION must be set");
    actix_web::HttpResponse::Ok().json(models::responses::GetStatusResponse{
        version,
    })
}

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
            .service(
                actix_web::web::scope("")
                    .wrap(actix_web_httpauth::middleware::HttpAuthentication::bearer(authorize))
                    .service(auth)
            )
    })
    .bind(format!("{host}:{port}", host = host, port = port))?
    .run()
    .await
}
