data "archive_file" "lambda_zip"{
    type="zip"
    source_file="lambda.py"
    output_path="lambda_function_payload.zip"
}


resource "aws_lambda_function" "test_lambda"{
    filename = "lambda_function_payload.zip"
    function_name = var.function_name
    role="${aws_iam_role.iam_for_lambda_tf.arn}"
    handler = "lambda.lambda_handler"
    runtime="python3.9"
    source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
}

#data "local_file" "custom_policy"{
#    filename = "${path.module}/role_policy.json"
#}

data "local_file" "custom_policy"{
    filename = "role_policy.json"
}


resource "aws_iam_role" "iam_for_lambda_tf" {
    name="iam_for_lambda_tf"
    assume_role_policy=data.local_file.custom_policy.content
}

output "lambda_function_details" {
  value = aws_lambda_function.test_lambda
}
