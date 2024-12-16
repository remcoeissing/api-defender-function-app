param($api)

"Onboarding $($api.resourceGroup)\$($api.apimResourceName)\$($api.apiCollectionName) - Current status: $($api.status)!"

if ($api.Status -ne 'Healthy')
{
    $onboardParameters = @{
        ResourceGroupName = $api.resourceGroup
        ServiceName = $api.apimResourceName
        ApiId = $api.apiCollectionName
        SubscriptionId = $api.subscriptionId
    }
    $onboardResult = Invoke-AzSecurityApiCollectionApimOnboard @onboardParameters
}