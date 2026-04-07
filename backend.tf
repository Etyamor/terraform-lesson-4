terraform {
  backend "s3" {
    bucket         = "tf-state-mrutkovskyi-lesson89" # Назва S3-бакета
    key            = "final-project/terraform.tfstate" # Шлях до файлу стейту
    region         = "eu-central-1"                  # Регіон AWS
    dynamodb_table = "terraform-locks"               # Назва таблиці DynamoDB
    encrypt        = true                            # Шифрування файлу стейту
  }
}
