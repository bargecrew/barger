FROM rust:1.43.1 as build

RUN apt-get update
RUN apt-get install musl-tools -y
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app

COPY Cargo.lock .
COPY Cargo.toml .
COPY ./src ./src

RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl

FROM alpine:latest
RUN addgroup -g 1000 app
RUN adduser -D -s /bin/sh -u 1000 -G app app
WORKDIR /home/app/bin/
COPY --from=build /usr/src/app/target/x86_64-unknown-linux-musl/release/lobby ./app
RUN chown app:app app
USER app
CMD ["./app"]