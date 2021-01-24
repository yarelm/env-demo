module "pubsub" {
  source  = "terraform-google-modules/pubsub/google"
  project_id   = var.project_id
  topic        = "payment-event"

  pull_subscriptions = [
    {
      name                 = "payment-event"
      ack_deadline_seconds = 10
    },
  ]
}
