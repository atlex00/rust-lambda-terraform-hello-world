use lambda_runtime::{handler_fn, Context, Error};
use serde_json::{json, Value};

#[tokio::main]
async fn main() -> Result<(), Error>{
    let runtime_handler = handler_fn(echo);
    lambda_runtime::run(runtime_handler).await?;
    Ok(())
}


pub async fn echo(event: Value, _: Context) -> Result<Value, Error> {
    let message = event["message"].as_str().unwrap();
    
    Ok(json!(
        {"echo": format!("ECHO:, {}!", message)}
        )
    )
}
