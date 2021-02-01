extern crate chrono;
#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate serde;

mod models;
mod schema;

use dotenv::dotenv;
use std::env;

async fn validator(req: actix_web::dev::ServiceRequest, _credentials: actix_web_httpauth::extractors::bearer::BearerAuth) -> Result<actix_web::dev::ServiceRequest, actix_web::Error> {
    println!("{:?}", _credentials);
    Ok(req)
}

#[actix_web::get("/api/status")]
async fn status() -> actix_web::HttpResponse {
    let version = env::var("CARGO_PKG_VERSION").expect("CARGO_PKG_VERSION must be set");
    actix_web::HttpResponse::Ok().json(models::responses::GetStatusResponse{
        version,
    })
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
            .service(status)
            .service(
                actix_web::web::scope("")
                    .wrap(actix_web_httpauth::middleware::HttpAuthentication::bearer(validator))
                    .service(auth)
            )
    })
    .bind(format!("{host}:{port}", host = host, port = port))?
    .run()
    .await
}
