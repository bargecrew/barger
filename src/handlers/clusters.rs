use crate::models;

#[actix_web::get("/api/clusters")]
async fn get() -> actix_web::HttpResponse {
    actix_web::HttpResponse::Ok().json(models::responses::GetClustersResponse { clusters: vec![] })
}
