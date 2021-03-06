terraform {
  # We want to hold off on 0.13 until we have tested it.
  required_version = "~> 0.12.0"

  # If you use any other providers you should also pin them to the
  # major version currently being used.  This practice will help us
  # avoid unwelcome surprises.
  required_providers {
    aws       = "~> 3.0"
    cloudinit = "~> 2.0"
    null      = "~> 3.0"
  }
}
