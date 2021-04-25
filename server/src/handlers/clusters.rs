use crate::database;
use crate::models;
use actix_web::web::Json;

#[actix_web::get("/api/clusters")]
async fn get() -> actix_web::HttpResponse {
    match database::clusters::get_clusters(&database::establish_connection()) {
        Ok(clusters) => {
            actix_web::HttpResponse::Ok().json(models::responses::GetClustersResponse {
                clusters: clusters
                    .into_iter()
                    .map(models::common::new_cluster)
                    .collect(),
            })
        }
        Err(err) => err.as_response_error().error_response(),
    }
}

#[actix_web::post("/api/clusters")]
async fn post(req: Json<models::requests::PostClustersRequest>) -> actix_web::HttpResponse {
    match database::clusters::create_cluster(&database::establish_connection(), &req.name) {
        Ok(cluster) => {
            actix_web::HttpResponse::Ok().json(models::responses::PostClustersResponse {
                cluster: models::common::new_cluster(cluster),
            })
        }
        Err(err) => err.as_response_error().error_response(),
    }
}
