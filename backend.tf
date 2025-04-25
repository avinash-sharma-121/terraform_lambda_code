terraform {
    backend "s3" {
        bucket="my-s3-bucket-for-portfolio-8864"
        key="dev/terraform.tfstate"
        region="us-east-1"
    }
}