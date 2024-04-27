# main.tf

# Define the AWS provider
provider "aws" {
  region = var.REGION
}

# Create an S3 bucket
resource "aws_s3_bucket" "source_bucket" {
  bucket = var.SRC_BUCKET
  force_destroy = true
}

resource "aws_s3_object" "upload_jar_files" {
  for_each = fileset("${var.LOCAL_SRC_DIR_PATH}/${var.JARS_DIR_PATH}/", "*.*") 

  bucket = aws_s3_bucket.source_bucket.bucket
  key    = "${var.JARS_DIR_PATH}/${each.value}"
  source = "${var.LOCAL_SRC_DIR_PATH}/${var.JARS_DIR_PATH}/${each.value}"
}

resource "aws_s3_object" "upload_glue_file" {
  bucket = aws_s3_bucket.source_bucket.bucket
  key    = "${var.GLUE_SCRIPTS_PATH}/${var.GLUE_SCRIPT_PYTHON_FILE_NAME}"   
  source = "${var.LOCAL_SRC_DIR_PATH}/${var.GLUE_SCRIPTS_PATH}/${var.GLUE_SCRIPT_PYTHON_FILE_NAME}" 
}

resource "aws_glue_job" "hudi_job" {
  name        = var.JOB_NAME
  role_arn    = var.GLUE_ROLE_ARN
  glue_version= "3.0"
  worker_type = "G.1X"
  command {
    name        = "glueetl"
    script_location = "s3://${var.SRC_BUCKET}/${var.GLUE_SCRIPTS_PATH}/${var.GLUE_SCRIPT_PYTHON_FILE_NAME}"
    python_version = "3"
  }
  default_arguments = {
    "--jobBookmarkOption" = "job-bookmark-enable"
    "--base_s3_path" = "s3a://${var.SRC_BUCKET}"
    "--table_name" = var.TABLE_NAME
    "--additional-python-modules" = var.PYTHON_LIBS
    "--extra-jars" = "s3://${var.SRC_BUCKET}/${var.JARS_DIR_PATH}/${var.SPARK_AVRO_FILE_NAME},s3://${var.SRC_BUCKET}/${var.JARS_DIR_PATH}/${var.HUDI_SPARK_FILE_NAME}"
  }
  execution_property {
    max_concurrent_runs = 3
  }
  number_of_workers = 3
  timeout = 2880
  max_retries = 0
}
