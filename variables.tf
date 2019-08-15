variable "zip_name" {
  description = "zip name"
  default     = "lambda_function.zip"
}

variable "python_runtime" {
  description = "Python version"
  default     = "python3.6"
}

variable "handler" {
  description = "handler name for lambda"
  default     = "lambda_function.lambda_handler"
}