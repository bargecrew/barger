use crate::models;

#[actix_web::get("/api/health/ready")]
async fn ready() -> actix_web::HttpResponse {
    actix_web::HttpResponse::Ok().json(models::responses::GetHealthReadyResponse {})
}

#[actix_web::get("/api/health/live")]
async fn live() -> actix_web::HttpResponse {
    actix_web::HttpResponse::Ok().json(models::responses::GetHealthLiveResponse {})
}

#[cfg(test)]
mod test_ready {
    use crate::authorization;
    use crate::handlers;
    use actix_web::dev::Service;
    use actix_web::{http, test, Error};

    #[actix_rt::test]
    async fn test_success() -> Result<(), Error> {
        let app = actix_web::App::new()
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
                    .wrap(actix_web_httpauth::middleware::HttpAuthentication::bearer(
                        authorization::authorize,
                    ))
                    .service(handlers::clusters::get),
            );
        let mut app = test::init_service(app).await;

        let req = test::TestRequest::get()
            .uri("/api/health/ready")
            .to_request();
        let resp = app.call(req).await.unwrap();

        assert_eq!(resp.status(), http::StatusCode::OK);

        Ok(())
    }
}

#[cfg(test)]
mod test_live {
    use crate::authorization;
    use crate::handlers;
    use actix_web::dev::Service;
    use actix_web::{http, test, Error};

    #[actix_rt::test]
    async fn test_success() -> Result<(), Error> {
        let app = actix_web::App::new()
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
                    .wrap(actix_web_httpauth::middleware::HttpAuthentication::bearer(
                        authorization::authorize,
                    ))
                    .service(handlers::clusters::get),
            );
        let mut app = test::init_service(app).await;

        let req = test::TestRequest::get()
            .uri("/api/health/live")
            .to_request();
        let resp = app.call(req).await.unwrap();

        assert_eq!(resp.status(), http::StatusCode::OK);

        Ok(())
    }
}
