use lambda_runtime::{handler_fn, Context, Error};
use serde::{Serialize, Deserialize};
use serde_json::{json, Value};
use std::str;
use base64;

#[tokio::main]
async fn main() -> Result<(), Error>{
    let runtime_handler = handler_fn(echo);
    lambda_runtime::run(runtime_handler).await?;
    Ok(())
}

pub async fn echo(event: Value, _: Context) -> Result<Value, Error> {
    let request_body = event["body"].as_str().unwrap();
    let bytes = base64::decode(request_body).unwrap();
    let message = str::from_utf8(&bytes).unwrap();

    let response = RestApiResponse { 
                        isBase64Encoded: false,
                        statusCode: 200,
                        headers: json!({"Content-Type": "application/json" }),
                        body: format!("ECHO: {message}"),
                    };
    
    Ok(serde_json::to_value(&response).unwrap())
}

#[allow(non_snake_case)]
#[derive(Serialize, Deserialize, Debug)]
struct RestApiResponse {
    isBase64Encoded: bool,
    statusCode: u32,
    headers: Value,
    body: String,
}
