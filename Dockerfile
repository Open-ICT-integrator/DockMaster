# syntax=docker/dockerfile:1.0

######################################################################
# Base Stage
######################################################################
FROM rust:latest AS base

# Set the working directory inside the container
WORKDIR /usr/src/app

EXPOSE 8080

######################################################################
# Development Stage
######################################################################
FROM base AS development

# Don't copy the files, just mount the volume with docker compose
# For more information look at the README.md file

# Install any tools that are needed for development
RUN rustup component add rustfmt
RUN rustup component add clippy
RUN cargo install cargo-checkmate && \
    cargo install diesel_cli --no-default-features --features postgres

######################################################################
# Builder Stage
######################################################################
FROM base AS builder

COPY . .

RUN cargo build --release

######################################################################
# Final Stage
######################################################################
FROM gcr.io/distroless/cc-debian12 AS final

COPY --from=builder /usr/src/app/target/release/dock_master .

EXPOSE 8080
ENTRYPOINT ["./dock_master"]