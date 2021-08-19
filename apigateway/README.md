# AWS Api Gateway module for lambda proxy integration

This module is designed to create an api gateway with lambda proxy integration, it includes the creation of the resources and the required http methods associated; it supports query strings parameters, request path parameters, custom authorizer, cache cluster for stage and logging to cloudwatch logs all request access to the apigateway.

---

## Usage

To use this module include something like the following in your terraform configuration:

```hcl
module "apigateway-pet-restfulapi" {
  source = "github.com/xerris/aws-modules//apigateway"
  
  env                = var.env
  apigateway_name    = "ApplicationRestful"
  stage_name         = var.env
  add_custom_auth    = false                         # If custom auth should be enabled
  apigw_enable_cache = false                         # If cache is enabled
  apigw_cache_size   = 0.5                           # Cache size (0.5 Gb Default)

  resources_path_details = [
    {
      resource_path    = "PetApplication"            # Resource path part
      integration_type = "AWS_PROXY"
      parent_resource  = "root"                      # Under which resource this path part will be created
      definitions      = [
        {
          id               = "1"                     # Unique id for the http method(s) associated
          http_method      = "POST"
          integration_uri  = module.event-lambda.this_lambda_arn
          lambda_name      = "PostPetLicenseApplication"
          status_code      = "200"
          request_querystring_params = {}            # A map of request parameters
        }
      ]
    }
  ]

  tags = {
    Owner       = "DevOps Team"
    Terraform   = "true"
    Environment = var.env
  }
}
```



---

## Full Example

This full example creates the following restfulapi structure:

``` 
/                                   # Root
 |-- /PetApplication                # Path part under / (root)
 |     |   |-- Post                 # HTTP Methods (POST, GET, DELETE)
 |     |   |-- Get
 |     |   |-- Delete
 |     |
 |     |-- /{dateapplied}            # Request path parameter under /PetApplication resouce
 |             |-- Get
 |
 |-- /SearchPetLicenseApplication    # Path part under / (root)
           |-- Get                   # HTTP Method with query string parameter
```

```hcl
module "apigateway-pet-restfulapi" {
  source = "github.com/xerris/aws-modules//apigateway"
  
  env                = var.env
  apigateway_name    = "PetLicenseApplicationRestful"
  stage_name         = var.env
  add_custom_auth    = false
  apigw_enable_cache = false
  apigw_cache_size   = 0.5

  resources_path_details = [
    {
      resource_path    = "PetApplication"
      integration_type = "AWS_PROXY"
      parent_resource  = "root"
      definitions      = [
        {
          id               = "1"
          http_method      = "POST"
          integration_uri  = data.aws_lambda_function.pet.invoke_arn
          lambda_name      = "PostPetLicenseApplication"
          status_code      = "200"
          request_querystring_params = {}
        },
        {
          id               = "2"
          http_method      = "GET"
          integration_uri  = data.aws_lambda_function.list-petapp.invoke_arn
          lambda_name      = "GetPetLicenseApplication"
          status_code      = "200"
          request_querystring_params = {}
        },
        {
          id               = "3"
          http_method      = "DELETE"
          integration_uri  = data.aws_lambda_function.delete-petapp.invoke_arn
          lambda_name      = "DeletePetLicenseApplication"
          status_code      = "200"
          request_querystring_params = {
            "method.request.querystring.id"          = true,
            "method.request.querystring.dateApplied" = true
          }
        }
      ]
    },
    {
      resource_path    = "{dateapplied}"
      integration_type = "AWS_PROXY"
      parent_resource  = "PetApplication"
      definitions      = [
        {
          id               = "4"
          http_method      = "GET"
          integration_uri  = data.aws_lambda_function.list-petapp.invoke_arn
          lambda_name      = "GetPetLicenseApplication"
          status_code      = "200"
          request_querystring_params = {}
        }
      ]
    },
    {
      resource_path    = "SearchPetLicenseApplication"
      integration_type = "AWS_PROXY"
      parent_resource  = "root"
      definitions      = [
        {
          id               = "5"
          http_method      = "GET"
          integration_uri  = data.aws_lambda_function.search-petapp.invoke_arn
          lambda_name      = "SearchPetLicenseApplication"
          status_code      = "200"
          request_querystring_params = {
            "method.request.querystring.id"          = true,
            "method.request.querystring.dateApplied" = true
          }
        }
      ]
    }
  ]


  tags = {
    Owner       = "DevOps Team"
    Terraform   = "true"
    Environment = var.env
  }
}
```



## Requirements

[Terraform 0.15.1](https://releases.hashicorp.com/terraform/0.15.1/) or above

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a     |
| <a name="provider_aws"></a> [aws](#provider\_aws)            | n/a     |

## Modules

No modules.

## Resources

| Name                                                         | Type        |
| ------------------------------------------------------------ | ----------- |
| [aws_api_gateway_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource    |
| [aws_api_gateway_authorizer.custom_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource    |
| [aws_api_gateway_deployment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource    |
| [aws_api_gateway_integration.apigw-integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource    |
| [aws_api_gateway_integration_response.integration-response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource    |
| [aws_api_gateway_method.gw-method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource    |
| [aws_api_gateway_method_response.method-response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource    |
| [aws_api_gateway_method_settings.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource    |
| [aws_api_gateway_resource.gw-resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource    |
| [aws_api_gateway_resource.pathparam-resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource    |
| [aws_api_gateway_rest_api.api-gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource    |
| [aws_api_gateway_stage.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource    |
| [aws_cloudwatch_log_group.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource    |
| [aws_iam_policy.api_gateway_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource    |
| [aws_iam_role.invocation_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource    |
| [aws_iam_role.lambda_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource    |
| [aws_iam_role.role_for_api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource    |
| [aws_iam_role_policy.invocation_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource    |
| [aws_iam_role_policy_attachment.gateway_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_lambda_function.function_custom_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource    |
| [aws_lambda_permission.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource    |
| [aws_lambda_permission.apigw_pathparam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource    |
| [archive_file.custom_auth_archived](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name                                                         | Description                                                  | Type           | Default                                                      | Required |
| ------------------------------------------------------------ | ------------------------------------------------------------ | -------------- | ------------------------------------------------------------ | :------: |
| <a name="input_access_log_format"></a> [access\_log\_format](#input\_access\_log\_format) | Access log format in Common Log Format (CLF)                 | `string`       | `"$context.requestId $context.identity.sourceIp $context.identity.userAgent $context.identity.caller $context.identity.user [$context.requestTime] $context.httpMethod $context.resourcePath $context.protocol $context.status $context.responseLength $context.awsEndpointRequestId $context.error.responseType $context.error.message "` |    no    |
| <a name="input_add_custom_auth"></a> [add\_custom\_auth](#input\_add\_custom\_auth) | Defines if custom auth should be added or not                | `bool`         | `false`                                                      |    no    |
| <a name="input_apigateway_name"></a> [apigateway\_name](#input\_apigateway\_name) | A unique name for your Lambda Function                       | `string`       | `""`                                                         |    no    |
| <a name="input_apigw_cache_size"></a> [apigw\_cache\_size](#input\_apigw\_cache\_size) | The size of the cache for the stage, if enabled.             | `number`       | `0.5`                                                        |    no    |
| <a name="input_apigw_enable_cache"></a> [apigw\_enable\_cache](#input\_apigw\_enable\_cache) | Enables or disables apigateway cache                         | `bool`         | `false`                                                      |    no    |
| <a name="input_endpoint_configuration_types"></a> [endpoint\_configuration\_types](#input\_endpoint\_configuration\_types) | A list of endpoint types                                     | `list(string)` | <pre>[<br>  "EDGE"<br>]</pre>                                |    no    |
| <a name="input_env"></a> [env](#input\_env)                  | Environment                                                  | `string`       | `"dev"`                                                      |    no    |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | The name of the runtime, Ex. python2.7, python3.7, nodejs10.x | `string`       | `"nodejs10.x"`                                               |    no    |
| <a name="input_logs_retention"></a> [logs\_retention](#input\_logs\_retention) | Defines the number of days to retain logs                    | `number`       | `7`                                                          |    no    |
| <a name="input_resources_path_details"></a> [resources\_path\_details](#input\_resources\_path\_details) | Details for your api resources path and http methods         | `list(any)`    | n/a                                                          |   yes    |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | A unique name for your Api Gateway Stage name                | `string`       | `""`                                                         |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)               | A mapping of tags to assign to all resources                 | `map(string)`  | `{}`                                                         |    no    |
| <a name="input_xray_tracing_enabled"></a> [xray\_tracing\_enabled](#input\_xray\_tracing\_enabled) | To enable XRay                                               | `bool`         | `false`                                                      |    no    |

## Outputs

| Name                                                         | Description          |
| ------------------------------------------------------------ | -------------------- |
| <a name="output_base_url"></a> [base\_url](#output\_base\_url) | API Gateway Endpoint |

---

## About Us

We are [Xerris](https://www.xerris.com/about-us/), cloud focused, remote first and digital by default