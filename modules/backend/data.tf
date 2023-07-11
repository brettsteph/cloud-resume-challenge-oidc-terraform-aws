# Install and use provider archive
data "archive_file" "lambda_functions" {
  type       = "zip"
  source_dir = "${path.module}/files/python"

  output_file_mode = "0666"
  output_path      = "${path.module}/files/put_function.zip"
}


