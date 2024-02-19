use actix_web::middleware::{Compress, Logger};
use actix_web::{get, post, App, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};
use utoipa::{OpenApi, ToSchema};
use utoipa_swagger_ui::SwaggerUi;

#[derive(Serialize, Deserialize, ToSchema)]
pub struct EchoResponse {
    message: String,
}

#[utoipa::path(
    get,
    path = "/",
    responses(
        (status = 200, description = "Returns a greeting", body = String),
    ),
)]
#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello world!")
}

#[utoipa::path(
    post,
    path = "/echo",
    request_body = String,
    responses(
        (status = 200, description = "Echoes the request body", body = EchoResponse),
    ),
)]
#[post("/echo")]
async fn echo(req_body: String) -> impl Responder {
    HttpResponse::Ok().json(EchoResponse { message: req_body })
}

#[derive(utoipa::OpenApi)]
#[openapi(paths(hello, echo), components(schemas(EchoResponse)))]
struct ApiDoc;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let openapi: utoipa::openapi::OpenApi = ApiDoc::openapi();

    HttpServer::new(move || {
        let mut app = App::new()
            .wrap(Logger::default())
            .wrap(Compress::default())
            .service(hello)
            .service(echo);

        #[cfg(debug_assertions)]
        {
            app = app.service(SwaggerUi::new("/swagger/{_:.*}").url("/swagger.json", openapi.clone()));
        }

        app
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
