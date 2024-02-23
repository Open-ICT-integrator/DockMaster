pub mod config;
pub mod controllers;
pub mod middlewares;
pub mod models;
pub mod services;
pub mod utils;

use crate::models::todo::Todo;

use actix_web::middleware::{Compress, Logger};
use actix_web::{App, HttpServer};
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

#[derive(OpenApi)]
#[openapi(
    paths(
        controllers::todo_controller::get_todos,
    ),
    components(schemas(Todo)),
    tags(
        (name = "Todos", description = "Operations about todos"),
    )
)]
struct ApiDoc;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(move || {
        let mut app = App::new()
            .wrap(Logger::default())
            .wrap(Compress::default())
            .service(controllers::todo_controller::get_todos);

        #[cfg(debug_assertions)]
        {
            app = app
                .service(SwaggerUi::new("/swagger/{_:.*}").url("/swagger.json", ApiDoc::openapi()));
        }

        app
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
