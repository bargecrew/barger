pub async fn authorize(
    req: actix_web::dev::ServiceRequest,
    credentials: actix_web_httpauth::extractors::bearer::BearerAuth,
) -> Result<actix_web::dev::ServiceRequest, actix_web::Error> {
    eprintln!("{:?}", credentials);
    match req.path() {
        "/api/users" => match req.method().as_str() {
            "GET" => Ok(req),
            _ => {
                return Err(actix_web::error::ErrorBadRequest("Bad Request"));
            }
        },
        _ => {
            return Err(actix_web::error::ErrorNotFound("Not Found"));
        }
    }
}
