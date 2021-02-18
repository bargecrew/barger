use crate::database::tokens;

pub async fn authorize(req: actix_web::dev::ServiceRequest, _credentials: actix_web_httpauth::extractors::basic::BasicAuth) -> Result<actix_web::dev::ServiceRequest, actix_web::Error> {
    match req.path() {
        "/api/users" => {
            match req.method().as_str() {
                "GET" => {
                    Ok(req)
                },
                _ => {
                    return Err(actix_web::error::ErrorBadRequest("Bad Request"));
                }
            }
        },
        _ => {
            return Err(actix_web::error::ErrorNotFound("Not Found"));
        }
    }
}
