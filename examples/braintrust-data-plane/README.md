A standard Braintrust data plane deployment. Copy this directory to a new directory in your own repository and modify the files to match your environment.

* `provider.tf` should be modified to use your AWS account and region.
* `terraform.tf` should be modified to use the remote backend that your company uses. Typically this is an S3 bucket and DynamoDB table.
* `main.tf` should be modified to meet your needs for the Braintrust deployment. The defaults are sensible only for a small development deployment.

After applying this configuration, you will have a Braintrust data plane deployed in your AWS account. You can then run `terraform output` to get the API URL you need to enter into the Braintrust UI for your Organization.

If you are testing, it is HIGHLY recommended that you create a new Braintrust Organization for testing purposes. If you change your live Organization's API URL, you might break users who are currently using it.

To configure your Organization to use your new data plane, click your user icon on the top right > Settings > API URL.

![Setting the API URL in Braintrust](/assets/Braintrust-API-URL.png)

Paste the API URL into the text field and click Save. Click to copy the test ping command and run it in your terminal to verify that your data plane is working.

![Verifying the API URL in Braintrust](/assets/Braintrust-API-URL-2.png)
