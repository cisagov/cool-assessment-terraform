terraform {
  # This code uses the strcontains() function, which was introduced
  # in Terraform 1.5.0, so we require at least that version.
  required_version = "~> 1.5"

  # If you use any other providers you should also pin them to the
  # major version currently being used.  This practice will help us
  # avoid unwelcome surprises.
  required_providers {
    # Version 3.38.0 of the Terraform AWS provider is the first
    # version to support default tags.
    # https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
