param($Context)

Import-Module Az.ResourceGraph

$apisToOnboard = Search-AzGraph -Query 'securityresources
| where type == "microsoft.security/assessments"
| extend assessmentKey = tostring(name)
| where assessmentKey == "1c0ba94f-e732-43c7-bf3a-05e80f45d642"
| project resourceGroup, apimResourceName = tostring(properties.additionalData.APIManagementResourceName), apiCollectionName = tostring(properties.additionalData.apiCollectionName), subscriptionId, status = tostring(properties.status.code)'

Write-Host "Number of APIs to onboard: $($apisToOnboard.Count)"

$output = @()

$retryParameters = @{
    FirstRetryInterval = [TimeSpan]::FromMinutes(2)
    MaxNumberOfAttempts = 5
}
$retryOptions = New-DurableRetryOptions @retryParameters

$tasks = @()
foreach ($api in $apisToOnboard) {
    $apiName = $api.apiCollectionName
    Write-Host "Onboarding $apiName"
    $output += "$apiName - "
    $tasks += Invoke-DurableActivity -FunctionName 'OnboardApi' -Input $api -NoWait -RetryOptions $retryOptions
}

$output = Wait-DurableTask -Task $tasks
Write-Host $output

return $tasks.Count