// @generated automatically by Diesel CLI.

pub mod sql_types {
    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "deploy_mode"))]
    pub struct DeployMode;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "disk_type"))]
    pub struct DiskType;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "endpoint_mode"))]
    pub struct EndpointMode;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "failure_action"))]
    pub struct FailureAction;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "restart_condition"))]
    pub struct RestartCondition;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "rollback_order"))]
    pub struct RollbackOrder;
}

diesel::table! {
    container (id) {
        id -> Uuid,
        image_id -> Uuid,
        user_id -> Uuid,
        container_stack_id -> Uuid,
        container_config_id -> Uuid,
        label_id -> Nullable<Uuid>,
        network_id -> Nullable<Uuid>,
        volume_id -> Nullable<Uuid>,
        health_check_id -> Nullable<Uuid>,
        container_name -> Text,
        container_status -> Bool,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::DeployMode;
    use super::sql_types::EndpointMode;
    use super::sql_types::DiskType;

    container_config (id) {
        id -> Uuid,
        cpu_limit -> Float8,
        memory_limit -> Text,
        deploy_pids_limit -> Int2,
        cpu_reserved -> Float8,
        memory_reserved -> Text,
        deploy_mode -> DeployMode,
        deploy_min_replicas -> Int2,
        deploy_max_replicas -> Int2,
        deploy_endpoint_mode -> EndpointMode,
        placement_constraints_disk_type -> DiskType,
        restart_policy_id -> Uuid,
        rollback_config_id -> Uuid,
        update_config_id -> Uuid,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}

diesel::table! {
    container_config_devices (container_config_id, device_id) {
        container_config_id -> Uuid,
        device_id -> Uuid,
        count -> Int2,
    }
}

diesel::table! {
    container_environment (container_id, environment_id) {
        container_id -> Uuid,
        environment_id -> Uuid,
    }
}

diesel::table! {
    container_label (container_id, label_id) {
        container_id -> Uuid,
        label_id -> Uuid,
    }
}

diesel::table! {
    container_network (container_id, network_id) {
        container_id -> Uuid,
        network_id -> Uuid,
    }
}

diesel::table! {
    container_stack (id) {
        id -> Uuid,
        user_id -> Uuid,
    }
}

diesel::table! {
    container_volume (container_id, volume_id) {
        container_id -> Uuid,
        volume_id -> Uuid,
    }
}

diesel::table! {
    dependency (container_id, target_container_id) {
        container_id -> Uuid,
        target_container_id -> Uuid,
    }
}

diesel::table! {
    devices (id) {
        id -> Uuid,
        device_name -> Text,
        device_type -> Text,
        device_id -> Text,
        driver -> Text,
        options_virtualization -> Bool,
    }
}

diesel::table! {
    environment (id) {
        id -> Uuid,
        environment_name -> Text,
        environment_value -> Text,
        secret -> Bool,
    }
}

diesel::table! {
    health_check (id) {
        id -> Uuid,
        check_type -> Int2,
        check_command -> Nullable<Text>,
        check_url -> Nullable<Text>,
        interval -> Int2,
        timeout -> Int2,
        retries -> Int2,
        start_period -> Int2,
    }
}

diesel::table! {
    image (id) {
        id -> Uuid,
        registry_id -> Uuid,
        image_name -> Text,
        image_tag -> Text,
        image_size -> Text,
        image_status -> Bool,
        image_created -> Date,
    }
}

diesel::table! {
    label (id) {
        id -> Uuid,
        label_name -> Text,
        label_value -> Text,
    }
}

diesel::table! {
    network (id) {
        id -> Uuid,
        container_stack_id -> Nullable<Uuid>,
        label_id -> Uuid,
        network_name -> Text,
        network_subnet -> Text,
        network_gateway -> Text,
        network_driver -> Text,
        network_scope -> Text,
        network_internal -> Bool,
        network_attachable -> Int8,
        network_label -> Nullable<Text>,
        network_status -> Bool,
        network_created -> Date,
    }
}

diesel::table! {
    network_label (network_id, label_id) {
        network_id -> Uuid,
        label_id -> Uuid,
    }
}

diesel::table! {
    port (id) {
        id -> Uuid,
        container_id -> Uuid,
        host_port -> Int2,
        target_port -> Int2,
    }
}

diesel::table! {
    registry (id) {
        id -> Uuid,
        user_id -> Uuid,
        registry_url -> Text,
        registry_username -> Text,
        registry_password -> Text,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::RestartCondition;

    restart_policy (id) {
        id -> Uuid,
        condition -> RestartCondition,
        delay -> Int2,
        max_attempts -> Int2,
        restart_window -> Int2,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::FailureAction;
    use super::sql_types::RollbackOrder;

    rollback_config (id) {
        id -> Uuid,
        parallelism -> Int2,
        delay -> Int2,
        failure_action -> FailureAction,
        monitor -> Int2,
        max_failure_ratio -> Int2,
        rollback_order -> RollbackOrder,
    }
}

diesel::table! {
    ssh_connection (id) {
        id -> Uuid,
        container_id -> Uuid,
        user_id -> Uuid,
        start_time -> Timestamp,
        end_time -> Timestamp,
        public_key -> Text,
        connection_status -> Bool,
    }
}

diesel::table! {
    user (id) {
        id -> Uuid,
        container_max -> Int2,
    }
}

diesel::table! {
    volume (id) {
        id -> Uuid,
        container_stack_id -> Nullable<Uuid>,
        label_id -> Uuid,
        volume_name -> Text,
        volume_size -> Int4,
        mount_point -> Text,
        volume_status -> Bool,
        volume_created -> Date,
    }
}

diesel::joinable!(container -> container_config (container_config_id));
diesel::joinable!(container -> container_stack (container_stack_id));
diesel::joinable!(container -> health_check (health_check_id));
diesel::joinable!(container -> image (image_id));
diesel::joinable!(container -> label (label_id));
diesel::joinable!(container -> network (network_id));
diesel::joinable!(container -> user (user_id));
diesel::joinable!(container_config -> restart_policy (restart_policy_id));
diesel::joinable!(container_config_devices -> container_config (container_config_id));
diesel::joinable!(container_config_devices -> devices (device_id));
diesel::joinable!(container_environment -> container (container_id));
diesel::joinable!(container_environment -> environment (environment_id));
diesel::joinable!(container_label -> container (container_id));
diesel::joinable!(container_label -> label (label_id));
diesel::joinable!(container_network -> container (container_id));
diesel::joinable!(container_network -> network (network_id));
diesel::joinable!(container_stack -> user (user_id));
diesel::joinable!(container_volume -> container (container_id));
diesel::joinable!(container_volume -> volume (volume_id));
diesel::joinable!(image -> registry (registry_id));
diesel::joinable!(network -> label (label_id));
diesel::joinable!(network_label -> label (label_id));
diesel::joinable!(network_label -> network (network_id));
diesel::joinable!(port -> container (container_id));
diesel::joinable!(registry -> user (user_id));
diesel::joinable!(ssh_connection -> container (container_id));
diesel::joinable!(ssh_connection -> user (user_id));
diesel::joinable!(volume -> label (label_id));

diesel::allow_tables_to_appear_in_same_query!(
    container,
    container_config,
    container_config_devices,
    container_environment,
    container_label,
    container_network,
    container_stack,
    container_volume,
    dependency,
    devices,
    environment,
    health_check,
    image,
    label,
    network,
    network_label,
    port,
    registry,
    restart_policy,
    rollback_config,
    ssh_connection,
    user,
    volume,
);
