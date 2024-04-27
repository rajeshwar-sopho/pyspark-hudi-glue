# variables.tf

# Declare variables
variable "REGION" {
  default     = "us-east-1"
  type        = string
}

variable "TAGS" {
  type = map(string)
  default = {}
}

variable "SRC_BUCKET" {
  type        = string
}

variable "LOCAL_SRC_DIR_PATH" {
  type        = string
}

variable "GLUE_SCRIPT_PYTHON_FILE_NAME" {
  type        = string
}

variable "GLUE_SCRIPTS_PATH" {
  type        = string
}

variable "JOB_NAME" {
  type        = string
}

variable "GLUE_ROLE_ARN" {
  type        = string
}

variable "TABLE_NAME" {
  type        = string
}

variable "GLUE_DB_NAME" {
  type        = string
}

variable "KINESIS_TABLE_NAME" {
  type        = string
}



