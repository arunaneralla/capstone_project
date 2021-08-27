# Define AWS as our provider
provider "aws" {
  region = "${var.aws_region}"

  #tags required for eks can be applied to the vpc without changes to the vpc wiping them out.
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}