# AWSome Builder

Terraform manifests for provisioning the AWS infrastructure for the AWSome Builder programme.
The repository has the following structure:
```
|── modules
|       |── [MODULE 1]
|       |       |── README.md: Documents the module including input / output for the module
|       |       |── vars.tf: Defines the module's input variables
|       |       |── data.tf: Accesses Terraform data sources used by the module
|       |       |── main.tf: Provisions the infrastructure using the provided input variables
|       |       └── outputs.tf: Defines the output variables from the provisioned infrastructure
|       |       |── providers.tf: Initializes Terraform providers required by the module
|       |── [MODULE 2]
|       |       |── README.md: Documents the module including input / output for the module
|       |       |── ...
|       └── [MODULE N]
|               |── ...
|── environments
        |── dev
        |       |── backend.tf: Configures the back-end used by Terraform and defines the required providers
        |       |── main.tf: Provisions a new environment by executing the available modules
        |       |── vars.tf: Defines the default and required configurations for the environment
        |       └── terraform.tfvars: Defines the environment specific configuration
        |── test
        |       |── backend.tf: Configures the back-end used by Terraform and defines the required providers
        |       |── ...
        └── [ENVIRONMENT N]
                |── ...
```