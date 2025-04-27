data "archive_file" "lambda_zip"{
    type="zip"
    source_file="${path.module}/lambda.py"
    output_path="${path.module}/lambda_function_payload.zip"
}


resource "aws_lambda_function" "test_lambda"{
    filename = "${path.module}/lambda_function_payload.zip"
    function_name = var.function_name
    role="${aws_iam_role.iam_for_lambda_tf.arn}"
    handler = "lambda.lambda_handler"
    runtime="python3.9"
    source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
}

data "local_file" "custom_policy"{
    filename = "${path.module}/role_policy.json"
}


resource "aws_iam_role" "iam_for_lambda_tf" {
    name="${var.function_name}_iam_for_lambda_tf"
    assume_role_policy=data.local_file.custom_policy.content
}

resource "aws_cloudwatch_event_rule" "lambda_trigger_rule" {
  name                = "${var.function_name}_lambda-trigger-rule"
  description         = "Triggers Lambda every 5 minutes"
  schedule_expression = "cron(0/5 * * * ? *)"
  event_bus_name      = "default"  # or your custom event bus name
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger_rule.name
  target_id = "TargetLambda"
  arn       = aws_lambda_function.test_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_trigger_rule.arn
}

output "lambda_function_details" {
  value = aws_lambda_function.test_lambda.arn
}
