# Rust on Lambda and deploy with Terraform

The program just echo your message, appending "ECHO: "

You could reproduce all services if you configured aws cli properly.

## Quick start

I added three policies to my API user:

- AWSLambda_FullAccess
- IAMFullAccess
- AmazonAPIGatewayAdministrator
- CloudWatchFullAccess

```bash
./full_deploy.sh
```

Check:

```bash
curl -X POST \
    -d "Hello world" \
    "$(terraform output -raw base_url)/echo"
# ECHO: Hello world
```

## Build

```bash
rustup target add x86_64-unknown-linux-musl
cargo build --target x86_64-unknown-linux-musl --release
```

## Deploy

```bash
terraform apply
```

## Test

From local:

```bash
curl -X POST \
    -d "Hello world" \
    "$(terraform output -raw base_url)/echo"
# ECHO: Hello world
```

Test from AWS Web console.
Send "Hello world" as text:

```json
{"body": "SGVsbG8gd29ybGQ="}
```

## Referencees

- https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway
- https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-output-format