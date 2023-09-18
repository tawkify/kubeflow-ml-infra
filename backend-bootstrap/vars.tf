variable "key" {
  type    = string
  default = "global/s3/terraform.tfstate"

}

variable "bucket" {
  type = string
}

variable "dynamodb_table" {
  type = string
}


variable "region" {
  type    = string
  default = "us-west-2"
}


variable "role_name" {
  type = string
}

variable "env_name" {
  type = string
}
