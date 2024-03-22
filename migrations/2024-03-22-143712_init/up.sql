-- Your SQL goes here
CREATE TABLE IF NOT EXISTS public.container
(
    id uuid NOT NULL PRIMARY KEY,
    image_id uuid NOT NULL,
    user_id uuid NOT NULL,
    container_stack_id uuid NOT NULL,
    container_config_id uuid NOT NULL,
    label_id uuid,
    network_id uuid,
    volume_id uuid,
    health_check_id uuid,
    container_name text COLLATE pg_catalog."default" NOT NULL,
    container_status boolean NOT NULL
);

CREATE TYPE public.deploy_mode AS ENUM
(
    'replicated',
    'global'
);

CREATE TYPE public.disk_type AS ENUM
(
    'ssd',
    'hdd'
);

CREATE TYPE public.endpoint_mode AS ENUM
(
    'vip',
    'dnsrr'
);

CREATE TABLE IF NOT EXISTS public.container_config
(
    id uuid NOT NULL PRIMARY KEY,

    -- No idea what the following columns are....
    -- config_key text COLLATE pg_catalog."default" NOT NULL,
    -- config_value text COLLATE pg_catalog."default" NOT NULL,

    -- limits
    cpu_limit float NOT NULL,
    memory_limit text NOT NULL,
    deploy_pids_limit smallint NOT NULL default 0,

    -- reservations
    cpu_reserved float NOT NULL,
    memory_reserved text NOT NULL,

    -- deploy mode
    deploy_mode public.deploy_mode NOT NULL,
    deploy_min_replicas smallint NOT NULL default 0,
    deploy_max_replicas smallint NOT NULL default 1,
    deploy_endpoint_mode public.endpoint_mode NOT NULL,

    -- placement constraints
    placement_constraints_disk_type public.disk_type NOT NULL,

    -- restart policy
    restart_policy_id uuid NOT NULL,

    -- rollback config
    rollback_config_id uuid NOT NULL,

    -- update config
    update_config_id uuid NOT NULL,

    created_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);

CREATE TYPE public.failure_action AS ENUM
(
    'pause',
    'continue'
);

CREATE TYPE public.rollback_order AS ENUM
(
    'start-first',
    'stop-first'
);

CREATE TABLE IF NOT EXISTS public.rollback_config
(
    id uuid NOT NULL PRIMARY KEY,
    parallelism smallint NOT NULL default 0,
    delay smallint NOT NULL default 0,
    failure_action public.failure_action NOT NULL,
    monitor smallint NOT NULL default 0,
    max_failure_ratio smallint NOT NULL default 0,
    rollback_order public.rollback_order NOT NULL
);

ALTER TABLE IF EXISTS public.container_config
    ADD CONSTRAINT container_config_rollback_config_id_fk FOREIGN KEY (rollback_config_id)
    REFERENCES public.rollback_config (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS rollback_config_id_index
    ON public.container_config(rollback_config_id);

ALTER TABLE IF EXISTS public.container_config
    ADD CONSTRAINT container_config_update_config_id_fk FOREIGN KEY (update_config_id)
    REFERENCES public.rollback_config (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS update_config_id_index
    ON public.container_config(update_config_id);

CREATE TYPE public.restart_condition AS ENUM
(
    'none',
    'on-failure',
    'always',
    'unless-stopped'
);

CREATE TABLE IF NOT EXISTS public.restart_policy
(
    id uuid NOT NULL PRIMARY KEY,
    condition public.restart_condition NOT NULL,
    delay smallint NOT NULL default 0,
    max_attempts smallint NOT NULL default 0,
    restart_window smallint NOT NULL default 0
);

CREATE TABLE IF NOT EXISTS public.devices
(
    id uuid NOT NULL PRIMARY KEY,
    device_name text NOT NULL,
    device_type text NOT NULL,
    device_id text NOT NULL,
    driver text NOT NULL,
    options_virtualization boolean NOT NULL default true
);

CREATE TABLE IF NOT EXISTS public.container_config_devices
(
    container_config_id uuid NOT NULL,
    device_id uuid NOT NULL,
    count smallint NOT NULL default 1,
    PRIMARY KEY (container_config_id, device_id)
);

ALTER TABLE IF EXISTS public.container_config
    ADD CONSTRAINT container_config_restart_policy_fk FOREIGN KEY (restart_policy_id)
    REFERENCES public.restart_policy (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS restart_policy_id_index
    ON public.container_config(restart_policy_id);

ALTER TABLE IF EXISTS public.container_config_devices
    ADD CONSTRAINT container_config_devices_container_config_id_fk FOREIGN KEY (container_config_id)
    REFERENCES public.container_config (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.container_config_devices
    ADD CONSTRAINT container_config_devices_device_id_fk FOREIGN KEY (device_id)
    REFERENCES public.devices (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;



CREATE TABLE IF NOT EXISTS public.container_stack
(
    id uuid NOT NULL PRIMARY KEY,
    user_id uuid NOT NULL
);

CREATE TABLE IF NOT EXISTS public.dependency
(
    container_id uuid NOT NULL,
    target_container_id uuid NOT NULL,
    PRIMARY KEY (container_id, target_container_id)
);

CREATE TABLE IF NOT EXISTS public.environment
(
    id uuid NOT NULL PRIMARY KEY,
    environment_name text COLLATE pg_catalog."default" NOT NULL,
    environment_value text COLLATE pg_catalog."default" NOT NULL,
    secret boolean NOT NULL default false
);

CREATE TABLE IF NOT EXISTS public.health_check
(
    id uuid NOT NULL PRIMARY KEY,
    check_type smallint NOT NULL,
    check_command text COLLATE pg_catalog."default",
    check_url text COLLATE pg_catalog."default",
    "interval" smallint NOT NULL,
    timeout smallint NOT NULL,
    retries smallint NOT NULL,
    start_period smallint NOT NULL
);

COMMENT ON COLUMN public.health_check.check_type
    IS 'Command or URL';

CREATE TABLE IF NOT EXISTS public.image
(
    id uuid NOT NULL PRIMARY KEY,
    registry_id uuid NOT NULL,
    image_name text COLLATE pg_catalog."default" NOT NULL,
    image_tag text COLLATE pg_catalog."default" NOT NULL,
    image_size text COLLATE pg_catalog."default" NOT NULL,
    image_status boolean NOT NULL,
    image_created date NOT NULL
);

CREATE TABLE IF NOT EXISTS public.label
(
    id uuid NOT NULL PRIMARY KEY,
    label_name text COLLATE pg_catalog."default" NOT NULL,
    label_value text COLLATE pg_catalog."default" NOT NULL
);

CREATE TABLE IF NOT EXISTS public.network
(
    id uuid NOT NULL PRIMARY KEY,
    container_stack_id uuid,
    label_id uuid NOT NULL,
    network_name text COLLATE pg_catalog."default" NOT NULL,
    network_subnet text COLLATE pg_catalog."default" NOT NULL,
    network_gateway text COLLATE pg_catalog."default" NOT NULL,
    network_driver text COLLATE pg_catalog."default" NOT NULL,
    network_scope text COLLATE pg_catalog."default" NOT NULL,
    network_internal boolean NOT NULL,
    network_attachable bigint NOT NULL,
    network_label text COLLATE pg_catalog."default",
    network_status boolean NOT NULL,
    network_created date NOT NULL
);

CREATE TABLE IF NOT EXISTS public.network_label
(
    network_id uuid NOT NULL,
    label_id uuid NOT NULL,
    PRIMARY KEY (network_id, label_id)
);

CREATE TABLE IF NOT EXISTS public.port
(
    id uuid NOT NULL PRIMARY KEY,
    container_id uuid NOT NULL,
    host_port smallint NOT NULL,
    target_port smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS public.registry
(
    id uuid NOT NULL PRIMARY KEY,
    user_id uuid NOT NULL,
    registry_url text COLLATE pg_catalog."default" NOT NULL,
    registry_username text COLLATE pg_catalog."default" NOT NULL,
    registry_password text COLLATE pg_catalog."default" NOT NULL
);

CREATE TABLE IF NOT EXISTS public.ssh_connection
(
    id uuid NOT NULL PRIMARY KEY,
    container_id uuid NOT NULL,
    user_id uuid NOT NULL,
    start_time timestamp(0) without time zone NOT NULL,
    end_time timestamp(0) without time zone NOT NULL,
    public_key text COLLATE pg_catalog."default" NOT NULL,
    connection_status boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS public."user"
(
    id uuid NOT NULL PRIMARY KEY,
    container_max smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS public.volume
(
    id uuid NOT NULL PRIMARY KEY,
    container_stack_id uuid,
    label_id uuid NOT NULL,
    volume_name text COLLATE pg_catalog."default" NOT NULL,
    volume_size integer NOT NULL,
    mount_point text COLLATE pg_catalog."default" NOT NULL,
    volume_status boolean NOT NULL,
    volume_created date NOT NULL
);

CREATE TABLE IF NOT EXISTS public.container_environment
(
    container_id uuid NOT NULL,
    environment_id uuid NOT NULL,
    PRIMARY KEY (container_id, environment_id)
);

CREATE TABLE IF NOT EXISTS public.container_network
(
    container_id uuid NOT NULL,
    network_id uuid NOT NULL,
    PRIMARY KEY (container_id, network_id)
);

CREATE TABLE IF NOT EXISTS public.container_label
(
    container_id uuid NOT NULL,
    label_id uuid NOT NULL,
    PRIMARY KEY (container_id, label_id)
);

CREATE TABLE IF NOT EXISTS public.container_volume
(
    container_id uuid NOT NULL,
    volume_id uuid NOT NULL,
    PRIMARY KEY (container_id, volume_id)
);

ALTER TABLE IF EXISTS public.container
    ADD CONSTRAINT container_container_config_id_foreign FOREIGN KEY (container_config_id)
    REFERENCES public.container_config (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS container_container_config_id_index
    ON public.container(container_config_id);


ALTER TABLE IF EXISTS public.container
    ADD CONSTRAINT container_container_stack_id_foreign FOREIGN KEY (container_stack_id)
    REFERENCES public.container_stack (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS container_container_stack_id_index
    ON public.container(container_stack_id);


ALTER TABLE IF EXISTS public.dependency
    ADD FOREIGN KEY (container_id)
    REFERENCES public.container (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.dependency
    ADD FOREIGN KEY (target_container_id)
    REFERENCES public.container (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.container
    ADD CONSTRAINT container_health_check_id_foreign FOREIGN KEY (health_check_id)
    REFERENCES public.health_check (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS container_health_check_id_index
    ON public.container(health_check_id);


ALTER TABLE IF EXISTS public.container
    ADD CONSTRAINT container_image_id_foreign FOREIGN KEY (image_id)
    REFERENCES public.image (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS container_image_id_index
    ON public.container(image_id);


ALTER TABLE IF EXISTS public.container
    ADD CONSTRAINT container_label_id_foreign FOREIGN KEY (label_id)
    REFERENCES public.label (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS container_label_id_index
    ON public.container(label_id);


ALTER TABLE IF EXISTS public.container
    ADD CONSTRAINT container_network_id_foreign FOREIGN KEY (network_id)
    REFERENCES public.network (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS container_network_id_index
    ON public.container(network_id);


ALTER TABLE IF EXISTS public.container
    ADD CONSTRAINT container_user_id_foreign FOREIGN KEY (user_id)
    REFERENCES public."user" (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS container_user_id_index
    ON public.container(user_id);


ALTER TABLE IF EXISTS public.container
    ADD CONSTRAINT container_volume_id_foreign FOREIGN KEY (volume_id)
    REFERENCES public.volume (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS container_volume_id_index
    ON public.container(volume_id);

ALTER TABLE IF EXISTS public.volume
    ADD FOREIGN KEY(container_stack_id)
    REFERENCES public.container (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.container_stack
    ADD CONSTRAINT container_stack_user_id_foreign FOREIGN KEY (user_id)
    REFERENCES public."user" (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS container_stack_user_id_index
    ON public.container_stack(user_id);


ALTER TABLE IF EXISTS public.image
    ADD CONSTRAINT image_registry_id_foreign FOREIGN KEY (registry_id)
    REFERENCES public.registry (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS image_registry_id_index
    ON public.image(registry_id);


ALTER TABLE IF EXISTS public.network
    ADD CONSTRAINT network_label_id_foreign FOREIGN KEY (label_id)
    REFERENCES public.label (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.network_label
    ADD CONSTRAINT network_label_label_id_foreign FOREIGN KEY (label_id)
    REFERENCES public.label (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.network_label
    ADD CONSTRAINT network_label_network_id_foreign FOREIGN KEY (network_id)
    REFERENCES public.network (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.port
    ADD FOREIGN KEY (container_id)
    REFERENCES public.container (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
CREATE INDEX IF NOT EXISTS port_container_id_index
    ON public.port(container_id);


ALTER TABLE IF EXISTS public.registry
    ADD CONSTRAINT registry_user_id_foreign FOREIGN KEY (user_id)
    REFERENCES public."user" (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS registry_user_id_index
    ON public.registry(user_id);


ALTER TABLE IF EXISTS public.ssh_connection
    ADD CONSTRAINT ssh_connection_container_id_foreign FOREIGN KEY (container_id)
    REFERENCES public.container (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS ssh_connection_container_id_unique
    ON public.ssh_connection(container_id);


ALTER TABLE IF EXISTS public.ssh_connection
    ADD CONSTRAINT ssh_connection_user_id_foreign FOREIGN KEY (user_id)
    REFERENCES public."user" (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.volume
    ADD CONSTRAINT volume_label_id_foreign FOREIGN KEY (label_id)
    REFERENCES public.label (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.container_environment
    ADD FOREIGN KEY (container_id)
    REFERENCES public.container (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.container_environment
    ADD FOREIGN KEY (environment_id)
    REFERENCES public.environment (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.container_network
    ADD FOREIGN KEY (container_id)
    REFERENCES public.container (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.container_network
    ADD FOREIGN KEY (network_id)
    REFERENCES public.network (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.container_label
    ADD FOREIGN KEY (container_id)
    REFERENCES public.container (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.container_label
    ADD FOREIGN KEY (label_id)
    REFERENCES public.label (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.container_volume
    ADD FOREIGN KEY (container_id)
    REFERENCES public.container (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.container_volume
    ADD FOREIGN KEY (volume_id)
    REFERENCES public.volume (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;