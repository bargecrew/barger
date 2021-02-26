mod claims;
use jsonwebtoken::{decode, Algorithm, DecodingKey, Validation};
use std::env;

pub async fn authorize(
    req: actix_web::dev::ServiceRequest,
    credentials: actix_web_httpauth::extractors::bearer::BearerAuth,
) -> Result<actix_web::dev::ServiceRequest, actix_web::Error> {
    let key = env::var("JWT_KEY").expect("JWT_KEY must be set");
    let claims = get_claims(credentials.token(), &key);
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

fn get_claims(token: &str, key: &str) -> claims::Claims {
    decode::<claims::Claims>(
        token,
        &DecodingKey::from_rsa_pem(key.as_bytes()).unwrap(),
        &Validation::new(Algorithm::RS256),
    )
    .unwrap()
    .claims
}
