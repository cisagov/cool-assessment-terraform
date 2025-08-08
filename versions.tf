terraform {
  # If you use any other providers you should also pin them to the
  # major version currently being used.  This practice will help us
  # avoid unwelcome surprises.
  required_providers {
    # We have verified that our code works with version 6.7 of this
    # Terraform provider.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7"
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

  # This code uses the strcontains() function, which was introduced
  # in Terraform 1.5.0, so we require at least that version.
  required_version = "~> 1.5"
}
