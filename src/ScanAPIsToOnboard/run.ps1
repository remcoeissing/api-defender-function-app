using namespace System.Net

# Input bindings are passed in via param block.
param($Timer, $TriggerMetadata)

$unhealthyApis = Search-AzGraph -Query 'securityresources
| where type == "microsoft.security/assessments"
| extend assessmentKey = tostring(name)
| where assessmentKey == "1c0ba94f-e732-43c7-bf3a-05e80f45d642"
| where properties.status.code !~ "Healthy"
| project resourceGroup, apimResourceName = tostring(properties.additionalData.APIManagementResourceName), apiCollectionName = tostring(properties.additionalData.apiCollectionName)'

if($null -ne $unhealthyApis -and $unhealthyApis.Count -gt 0) {
    $InstanceId = Start-DurableOrchestration -FunctionName 'OnboardApiOrchestrator'
    Write-Host "Started orchestration with ID = '$InstanceId'"
} else {
    Write-Host "No unhealthy APIs found."
}