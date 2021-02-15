# Personal Environments Terraform

Tested with Terraform v0.13.6

This terraform module is built as follows:
* `module/host` is the TF module for provisioning the single host project with the following infra components:
  * GKE private cluster
  * GCP network & subnetwork for GKE cluster
  * Cloud NAT for allowing the GKE cluster internet access
  * Cloud SQL PostgreSQL DB, peered to the GCP network created
  * PostgreSQL database and user per tenant
* `module/tenant` is the TF module for provisioning the per tenant project with the following infra components:
  * K8s namespace
  * GKE [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity) on the host project
  * IAM binding to the specific workload identity - allowing pubsub subscriber access to tenant project
  * pubsub resource
* `module/pubsub` is the TF module for provisioning pubsub topics and subscriptions relavant to our project
  

# How to run

* Provide the required inputs by running the following commands (replace values):
   * `export TF_VAR_billing_account=YOUR_BILLING_ACCOUNT_ID`
   * `export TF_VAR_folder_id=GCP_FOLDER_ID_TO_CREATE_PROJECTS`
   * `export TF_VAR_organization_id=GCP_ORGANIZATION_ID`
* Run `terraform init`
* Run `terraform apply -var-file=personal.tfvars`
* Go over and approve the pending changes
* Wait until it's over... (it can take a while.. If you encounter an error - in some rare cases it might be beneficial to re-run the apply procedure) :smiley:
