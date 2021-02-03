use crate::models;

#[actix_web::get("/api/health/ready")]
async fn ready() -> actix_web::HttpResponse {
    actix_web::HttpResponse::Ok().json(models::responses::GetHealthReadyResponse{})
}

#[actix_web::get("/api/health/live")]
async fn live() -> actix_web::HttpResponse {
    actix_web::HttpResponse::Ok().json(models::responses::GetHealthLiveResponse{})
}