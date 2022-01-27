# Hello world Rust on Lambda and deploy with Terraform

You could reproduce all process if you, configured aws cli properly.

## Build

```bash
rustup target add x86_64-unknown-linux-musl
cargo build --target x86_64-unknown-linux-musl --release
zip -r9 -j bootstrap.zip ./target/x86_64-unknown-linux-musl/release/bootstrap
```

## Deploy (no API Gateway)

I added two policies to my API user:

- AWSLambda_FullAccess
- IAMFullAccess

```bash
terraform apply
```

## Test

Test from AWS Web console.

Send:

```json
{
  "message": "Hi!"
}
```

Response:

```json
{
  "echo": "ECHO:, Hi!!"
}
```
