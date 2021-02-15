locals {
  payment_event_name = "payment-event"
}

module "pubsub" {
  source  = "terraform-google-modules/pubsub/google"
  project_id   = var.project_id
  topic        = local.payment_event_name

  pull_subscriptions = [
    {
      name                 = local.payment_event_name
      ack_deadline_seconds = 10
    },
  ]
}
