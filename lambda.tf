data "archive_file" "lambda_zip"{
    type="zip"
    source_file="lambda.py"
    output_path="${path.module}/lambda_function_payload.zip"
}


resource "aws_lambda_function" "test_lambda"{
    filename = "lambda_function_payload.zip"
    function_name = "test_lambda"
    role="${aws_iam_role.iam_for_lambda_tf.arn}"
    handler = "lambda.lambda_handler"
    runtime="python3.9"
    source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"

}

data "local_file" "custom_policy"{
    filename = "${path.module}/role_policy.json"
}

resource "aws_iam_role" "iam_for_lambda_tf" {
    name="iam_for_lambda_tf"
    assume_role_policy=data.local_file.custom_policy.content
}

