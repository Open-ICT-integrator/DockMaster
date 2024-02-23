use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

#[derive(Serialize, Deserialize, ToSchema)]
pub struct Todo {
    pub id: i32,
    pub title: String,
    pub completed: bool,
}
