use crate::authorization;
use crate::handlers;

pub fn config(cfg: &mut actix_web::web::ServiceConfig) {
    cfg
        // health
        .service(handlers::health::ready)
        .service(handlers::health::live)
        // status
        .service(handlers::status::get)
        // authorized
        .service(
            actix_web::web::scope("")
                .wrap(actix_web_httpauth::middleware::HttpAuthentication::bearer(
                    authorization::authorize,
                ))
                .service(handlers::clusters::get),
        );
}
