#!/bin/bash

rustup target add x86_64-unknown-linux-musl
cargo build --target x86_64-unknown-linux-musl --release
terraform apply -auto-approve