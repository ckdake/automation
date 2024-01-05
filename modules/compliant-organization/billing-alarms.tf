resource "aws_budgets_budget" "account_auto_adjust" {
  for_each = toset(aws_organizations_organization.root.accounts[*].id)

  name = "budget-account-${each.key}-auto-adjust-monthly"

  cost_filter {
    name = "LinkedAccount"
    values = [
      each.value
    ]
  }

  budget_type  = "COST"
  limit_amount = "0.00"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  auto_adjust_data {
    auto_adjust_type = "HISTORICAL"
    historical_options {
      budget_adjustment_period = 1
    }
  }

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 110
    threshold_type      = "PERCENTAGE"
    notification_type   = "FORECASTED"
    subscriber_sns_topic_arns = [
      aws_sns_topic.cis_benchmark_alarms.arn # TODO(ckdake) better name for alarm channel
    ]
  }

  cost_types {
    include_credit             = false
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = true
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_blended                = false
  }

  lifecycle {
    ignore_changes = [
      limit_amount
    ]
  }
}
