# main.tf
# manually create a table hudi_kinesis_clicks_stream_table with store type as kinesis in glue database
# create a glue hudi connector
# following article: https://aws.amazon.com/blogs/big-data/build-a-serverless-pipeline-to-analyze-streaming-data-using-aws-glue-apache-hudi-and-amazon-s3/

# Define the AWS provider
provider "aws" {
  region = var.REGION
}

# Create an S3 bucket
resource "aws_s3_bucket" "source_bucket" {
  bucket = var.SRC_BUCKET
  force_destroy = true
}

# resource "aws_s3_object" "upload_jar_files" {
#   for_each = fileset("${var.LOCAL_SRC_DIR_PATH}/${var.JARS_DIR_PATH}/", "*.*") 

#   bucket = aws_s3_bucket.source_bucket.bucket
#   key    = "${var.JARS_DIR_PATH}/${each.value}"
#   source = "${var.LOCAL_SRC_DIR_PATH}/${var.JARS_DIR_PATH}/${each.value}"
# }

resource "aws_s3_object" "upload_glue_file" {
  bucket = aws_s3_bucket.source_bucket.bucket
  key    = "${var.GLUE_SCRIPTS_PATH}/${var.GLUE_SCRIPT_PYTHON_FILE_NAME}"   
  source = "${var.LOCAL_SRC_DIR_PATH}/${var.GLUE_SCRIPTS_PATH}/${var.GLUE_SCRIPT_PYTHON_FILE_NAME}" 
}

resource "aws_glue_job" "hudi_job" {
  name        = var.JOB_NAME
  role_arn    = var.GLUE_ROLE_ARN
  glue_version= "4.0"
  worker_type = "G.025X"
  connections = [
    "hudi-connection"
  ]
  command {
    name        = "gluestreaming"
    script_location = "s3://${var.SRC_BUCKET}/${var.GLUE_SCRIPTS_PATH}/${var.GLUE_SCRIPT_PYTHON_FILE_NAME}"
    python_version = "3"
  }
  default_arguments = {    
    "--class": "GlueApp"
    "--database_name": var.GLUE_DB_NAME
    "--hudi_table_name": "hudi_streams_table"
    "--kinesis_table_name": var.KINESIS_TABLE_NAME
    "--s3_path_hudi": "s3://${var.SRC_BUCKET}/hudi_stuff/hudi_demo_table"
    "--s3_path_spark": "s3://${var.SRC_BUCKET}/spark_checkpoints"
    "--starting_position_of_kinesis_iterator": "LATEST"
    "--window_size": "10 seconds"
  }
  execution_property {
    max_concurrent_runs = 3
  }
  number_of_workers = 3
  timeout = 2880
  max_retries = 0

  tags = var.TAGS
}

resource "aws_kinesis_stream" "hudi_stream" {
  name             = "hudi-kinesis-stream"
  retention_period = 24 

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = var.TAGS
}

resource "aws_glue_catalog_database" "hudi_database" {
  name = var.GLUE_DB_NAME
}