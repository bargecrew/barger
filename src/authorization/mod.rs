mod claims;
use jsonwebtoken::{decode, Algorithm, DecodingKey, Validation};
use std::env;

pub async fn authorize(
    req: actix_web::dev::ServiceRequest,
    credentials: actix_web_httpauth::extractors::bearer::BearerAuth,
) -> Result<actix_web::dev::ServiceRequest, actix_web::Error> {
    let key = env::var("JWT_KEY").expect("JWT_KEY must be set");
    match get_claims(credentials.token(), &key) {
        Ok(claims) => {
            return if is_valid(&claims, req.path(), req.method().as_str()) {
                Ok(req)
            } else {
                Err(actix_web::error::ErrorUnauthorized("Not Authorized"))
            }
        }
        Err(err) => return Err(err),
    }
}

fn get_claims(token: &str, key: &str) -> Result<claims::Claims, actix_web::Error> {
    match decode::<claims::Claims>(
        token,
        &DecodingKey::from_rsa_pem(key.as_bytes()).unwrap(),
        &Validation::new(Algorithm::RS256),
    ) {
        Ok(result) => Ok(result.claims),
        Err(err) => Err(actix_web::error::ErrorUnauthorized(err)),
    }
}

fn is_valid(claims: &claims::Claims, path: &str, method: &str) -> bool {
    let claim = format!("{}:{}", path, method);
    for i in 0..claims.claims.len() {
        if claims.claims[i] == claim {
            return true;
        }
    }
    return false;
}

#[cfg(test)]
mod tests_is_valid {
    use super::*;

    #[test]
    fn test_is_valid_with_match() {
        assert_eq!(
            true,
            is_valid(
                &claims::Claims {
                    sub: "Jhon".to_string(),
                    exp: 0,
                    claims: vec!["/api/clusters:GET".to_string()]
                },
                "/api/clusters",
                "GET"
            )
        );
    }

    #[test]
    fn test_is_valid_with_invalid_method() {
        assert_eq!(
            false,
            is_valid(
                &claims::Claims {
                    sub: "Jhon".to_string(),
                    exp: 0,
                    claims: vec!["/api/clusters:GET".to_string()]
                },
                "/api/clusters",
                "POST"
            )
        );
    }

    #[test]
    fn test_is_valid_with_invalid_path() {
        assert_eq!(
            false,
            is_valid(
                &claims::Claims {
                    sub: "Jhon".to_string(),
                    exp: 0,
                    claims: vec!["/api/clusters:GET".to_string()]
                },
                "/api/cls",
                "GET"
            )
        );
    }
}
