# This file contains a semi-hacky way of validating user-provided assessment
# information.  As of Terraform v1.3.x, there is no built-in way to validate
# one variable against another, as we need to do here.  Terraform input variable
# validation expressions can only refer to the variable being validated and no
# others.  For more, see
# https://developer.hashicorp.com/terraform/language/expressions/custom-conditions#input-variable-validation
#
# To work around this limitation, we use a null_resource with a lifecycle block
# that contains a precondition.  The precondition is evaluated at plan time, and
# if it fails, the plan will fail with the error message provided.

resource "null_resource" "validate_assessment_id" {
  lifecycle {
    precondition {
      condition     = length(regexall(var.valid_assessment_id_regex, var.assessment_id)) == 1
      error_message = "Invalid assessment identifier provided: ${var.assessment_id}.  Valid assessment identifiers must match this regular expression: ${var.valid_assessment_id_regex}"
    }
  }
}

resource "null_resource" "validate_assessment_type" {
  lifecycle {
    precondition {
      condition     = contains(var.valid_assessment_types, var.assessment_type)
      error_message = "Invalid assessment type provided: ${var.assessment_type}.  Valid types are: ${join(", ", var.valid_assessment_types)}"
    }
  }
}
