use crate::services::todo_service;
use actix_web::{get, HttpResponse, Responder};

#[utoipa::path(
    get,
    path = "/todos",
    responses(
        (status = 200, description = "Successful response", body = [Todo]),
    ),
    tag = "Todos"
)]
#[get("/todos")]
pub async fn get_todos() -> impl Responder {
    let todos: Vec<crate::models::todo::Todo> = todo_service::get_all_todos();
    HttpResponse::Ok().json(todos)
}
