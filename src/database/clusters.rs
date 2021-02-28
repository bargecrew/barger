use crate::database::models::Cluster;
use crate::diesel::*;
use diesel::pg::PgConnection;

pub fn get_clusters(connection: &PgConnection) -> Result<Vec<Cluster>, actix_web::Error> {
    use crate::schema::clusters::dsl::*;

    match clusters.load::<Cluster>(connection) {
        Ok(result) => Ok(result),
        Err(_) => Err(actix_web::error::ErrorInternalServerError("Internal Error")),
    }
}

pub fn create_cluster(
    connection: &PgConnection,
    cluster_name: &String,
) -> Result<Cluster, actix_web::Error> {
    use crate::schema::clusters::dsl::*;

    match diesel::insert_into(clusters)
        .values(name.eq(cluster_name))
        .get_result(connection)
    {
        Ok(cluster) => Ok(cluster),
        Err(_) => Err(actix_web::error::ErrorInternalServerError("Internal Error")),
    }
}
