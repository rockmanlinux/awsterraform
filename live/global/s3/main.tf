provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "web-global-state"

    # Prevent accidental deleteion of this S3 bucket
    lifecycle {
        prevent_destroy = true
    }

    # Enable versioning so we can see the full revision history of our state files
    versioning {
        enabled = true
    }

    #Enable server-side encryption by default
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name                    = "web-global-locks"
    billing_mode            = "PAY_PER_REQUEST"
    hash_key                = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

terraform {
    backend "s3" {
        # Replace this with your bucket name
        bucket              = "web-global-state"
        key                 = "global/s3/terraform.tfstate"
        region              = "us-east-1"

        # Replace this with your DynamoDB table name!
        dynamodb_table      = "web-global-locks"
        encrypt             = true
    }
}


