terraform {
  backend "gcs" {
    bucket = "rebrain-webinar-dataart-tfstate"
    prefix = "example-kubernetes"
  }
}