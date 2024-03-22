use crate::models::todo::Todo;

pub fn get_all_todos() -> Vec<Todo> {
    vec![
        Todo {
            id: 1,
            title: "Learn Rust".into(),
            completed: false,
        },
        Todo {
            id: 2,
            title: "Build an API".into(),
            completed: false,
        },
    ]
}
