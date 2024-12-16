# API Defender Onboarding Function App

As a part of the Defender for API onboarding process we need to onboard all APIs to Defender for API. This can of course be done manually through the Azure portal, but we can also automate this process using the Azure CLI or PowerShell. But as an API platform typically has a lot of APIs and changes, it can be a bit cumbersome to onboard all APIs manually.

## Function App

To automate the onboarding process we can create an Azure Function App that has a Durable Function that can onboard all APIs to Defender for API. This function can be triggered by a timer trigger, or by an HTTP trigger, or by any other trigger that fits your scenario.

This example has been written in PowerShell as getting APIs onboarded is typically tasked for an Azure Platform team or similar, and they might be more comfortable with PowerShell than with other languages.

## Deployment

The Function App is deployed with a Managed Identity. This Managed Identity is used to query the APIs in the API Management instances and to onboard the APIs to Defender for API. In order to do this it's required that this identity has the necessary permissions to do this. In order to this ensure that the Managed Identity has Contributor permissions on the API Management instances, it could also have these permissions in different subscriptions.

### Functions

The Function App has four functions; two functions, a timer triggered and http triggered, for starting the orchestration function for the onboarding process. One function for the orchestration function, and one function for onboarding the APIs.

- *ScanAPIsToOnboard*: Timer triggered function that starts the orchestration function. By default it runs every day at 3AM. You can adjust this by changing the cron expression in the `function.json` file.
- *ApiOnboardingStart*: HTTP triggered function that starts the orchestration function.
- *OnboardApiOrchestrator*: Orchestration function that orchestrates the onboarding process. It gets all the APIs that should be onboarded by querying Azure Resource Graph. For each API it calls the `OnboardApi` activity function.
- *OnboardApi*: Activity function that onboards the APIs to Defender for API.

## Query onboarding status

The onboarding status is queried by calling Azure Resource Graph with the following query:

```kusto
securityresources
| where type == "microsoft.security/assessments"
| extend assessmentKey = tostring(name)
| where assessmentKey == "1c0ba94f-e732-43c7-bf3a-05e80f45d642"
| where properties.status.code !~ "Healthy"
| project resourceGroup, apimResourceName = tostring(properties.additionalData.APIManagementResourceName), apiCollectionName = tostring(properties.additionalData.apiCollectionName)
```
