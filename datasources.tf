data "archive_file" "lambdazipfile" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda.zip"
}
