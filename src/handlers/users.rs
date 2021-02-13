use crate::models;

#[actix_web::get("/api/users")]
async fn get() -> actix_web::HttpResponse {
    actix_web::HttpResponse::Ok().json(models::responses::GetUsersResponse{
        users: Vec::new(),
    })
}
