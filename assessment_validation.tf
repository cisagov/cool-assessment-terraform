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

resource "null_resource" "validate_assessment_account_name_matches_workspace" {
  lifecycle {
    precondition {
      condition     = replace(replace(lower(var.assessment_account_name), "/[()]/", ""), " ", "-") == terraform.workspace
      error_message = "Assessment account name (${var.assessment_account_name}) does not align with the currently-selected workspace (${terraform.workspace}).  Are you sure that you are using the correct tfvars file?"
    }
  }
}

resource "null_resource" "validate_assessment_artifact_export_map" {
  lifecycle {
    precondition {
      condition     = length([for k in keys(var.assessment_artifact_export_map) : k if !contains(var.valid_assessment_types, k)]) == 0
      error_message = "Invalid assessment type(s) provided in assessment_artifact_export_map: ${join(", ", [for k in keys(var.assessment_artifact_export_map) : k if !contains(var.valid_assessment_types, k)])}.  Valid types are: ${join(", ", var.valid_assessment_types)}"
    }
  }
}

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
