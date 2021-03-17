mod claims;
use jsonwebtoken::{decode, Algorithm, DecodingKey, Validation};
use std::env;
use std::time::{SystemTime, UNIX_EPOCH};

pub async fn authorize(
    req: actix_web::dev::ServiceRequest,
    credentials: actix_web_httpauth::extractors::bearer::BearerAuth,
) -> Result<actix_web::dev::ServiceRequest, actix_web::Error> {
    let key = env::var("JWT_KEY").expect("JWT_KEY must be set");
    match get_claims(credentials.token(), &key) {
        Ok(claims) => match is_valid(&claims, req.path(), req.method().as_str()) {
            Ok(valid) => {
                return if valid {
                    Ok(req)
                } else {
                    Err(actix_web::error::ErrorUnauthorized("Not Authorized"))
                }
            }
            Err(err) => return Err(err),
        },
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

fn is_valid(claims: &claims::Claims, path: &str, method: &str) -> Result<bool, actix_web::Error> {
    match SystemTime::now().duration_since(UNIX_EPOCH) {
        Ok(time) => {
            if claims.exp < time.as_millis() {
                return Ok(false);
            }
        }
        Err(_) => {
            return Err(actix_web::error::ErrorInternalServerError("Internal Error"));
        }
    }
    let claim = format!("{}:{}", path, method);
    for i in 0..claims.claims.len() {
        if claims.claims[i] == claim {
            return Ok(true);
        }
    }
    Ok(false)
}

#[cfg(test)]
mod tests_get_claims {
    use super::*;
    use dotenv::dotenv;
    use jsonwebtoken::{encode, EncodingKey, Header};
    use std::time::{SystemTime, UNIX_EPOCH};

    fn new_token(claims: &claims::Claims) -> String {
        encode(
            &Header::new(Algorithm::RS256),
            &claims,
            &EncodingKey::from_rsa_pem(
                env::var("JWT_PRIVATE_KEY")
                    .expect("JWT_PRIVATE_KEY must be set")
                    .as_bytes(),
            )
            .unwrap(),
        )
        .unwrap()
    }

    fn test_get_claims(claims: &claims::Claims) {
        dotenv().ok();
        let result = get_claims(
            &new_token(claims),
            &env::var("JWT_KEY").expect("JWT_KEY must be set"),
        )
        .unwrap();
        assert_eq!(claims.sub, result.sub);
        assert_eq!(claims.exp, result.exp);
        assert_eq!(claims.claims.len(), result.claims.len());
        for i in 0..result.claims.len() {
            assert_eq!(claims.claims[i], result.claims[i]);
        }
        assert_eq!(false, true);
    }

    #[test]
    fn test_get_claims_for_valid_token() {
        test_get_claims(&claims::Claims {
            sub: "Jhon".to_string(),
            exp: SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .expect("To get system time since unix epoch")
                .as_millis()
                + 5 * 1000,
            claims: vec![
                "/api/clusters:GET".to_string(),
                "/api/clusters:HEAD".to_string(),
                "/api/clusters:POST".to_string(),
            ],
        })
    }
}

#[cfg(test)]
mod tests_is_valid {
    use super::*;
    use std::time::{SystemTime, UNIX_EPOCH};

    #[test]
    fn test_is_valid_with_match() {
        assert_eq!(
            true,
            is_valid(
                &claims::Claims {
                    sub: "Jhon".to_string(),
                    exp: SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .expect("To get system time since unix epoch")
                        .as_millis()
                        + 5 * 1000,
                    claims: vec![
                        "/api/clusters:GET".to_string(),
                        "/api/clusters:HEAD".to_string(),
                        "/api/clusters:POST".to_string()
                    ]
                },
                "/api/clusters",
                "GET"
            )
            .unwrap()
        );
    }

    #[test]
    fn test_is_valid_with_invalid_method() {
        assert_eq!(
            false,
            is_valid(
                &claims::Claims {
                    sub: "Jhon".to_string(),
                    exp: SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .expect("To get system time since unix epoch")
                        .as_millis()
                        + 5 * 1000,
                    claims: vec![
                        "/api/clusters:GET".to_string(),
                        "/api/clusters:HEAD".to_string()
                    ]
                },
                "/api/clusters",
                "POST"
            )
            .unwrap()
        );
    }

    #[test]
    fn test_is_valid_with_invalid_path() {
        assert_eq!(
            false,
            is_valid(
                &claims::Claims {
                    sub: "Jhon".to_string(),
                    exp: SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .expect("To get system time since unix epoch")
                        .as_millis()
                        + 5 * 1000,
                    claims: vec![
                        "/api/clusters:GET".to_string(),
                        "/api/clusters:HEAD".to_string(),
                        "/api/clusters:POST".to_string()
                    ]
                },
                "/api/cls",
                "GET"
            )
            .unwrap()
        );
    }

    #[test]
    fn test_is_valid_with_expired_token() {
        assert_eq!(
            false,
            is_valid(
                &claims::Claims {
                    sub: "Jhon".to_string(),
                    exp: SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .expect("To get system time since unix epoch")
                        .as_millis()
                        - 5 * 1000,
                    claims: vec![
                        "/api/clusters:GET".to_string(),
                        "/api/clusters:HEAD".to_string(),
                        "/api/clusters:POST".to_string()
                    ]
                },
                "/api/clusters",
                "GET"
            )
            .unwrap()
        );
    }
}
