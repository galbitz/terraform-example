param(
    #[Parameter(Mandatory=$True)]
    [string]$subscriptionId = $env:ARM_SUBSCRIPTION_ID,
    #[Parameter(Mandatory=$True)]
    [string]$tenantId = $env:ARM_TENANT_ID,
    #[Parameter(Mandatory=$True)]
    [string]$appId = $env:ARM_CLIENT_ID,
    #[Parameter(Mandatory=$True)]
    [string]$password = $env:ARM_CLIENT_SECRET,
    [Parameter(Mandatory=$True)]
    [string]$ArtifactStagingDirectory,
    [Parameter(Mandatory=$True)]    
    [string]$StorageContainerName,
    [Parameter(Mandatory=$True)]  
    [string]$StorageAccountName
)

$secretPassword = $password | ConvertTo-SecureString -AsPlainText -Force
$azureCred = New-Object pscredential ($appId, $secretPassword)
Login-AzureRmAccount -ServicePrincipal -Credential $azureCred -TenantId $tenantId -SubscriptionId $subscriptionId
Select-AzureRmSubscription -SubscriptionID $subscriptionId

$StorageAccount = (Get-AzureRmStorageAccount | Where-Object{$_.StorageAccountName -eq $StorageAccountName})
$StorageAccountContext = $storageAccount.Context

$ArtifactFilePaths = Get-ChildItem $ArtifactStagingDirectory -Recurse -File | ForEach-Object -Process {$_.FullName}
foreach ($SourcePath in $ArtifactFilePaths) {
    $BlobName = $SourcePath.Substring($ArtifactStagingDirectory.length + 1)
    Set-AzureStorageBlobContent -File $SourcePath -Blob $BlobName -Container $StorageContainerName -Context $StorageAccountContext -Force
}

$ArtifactsLocationSasToken = New-AzureStorageContainerSASToken -Container $StorageContainerName -Context $StorageAccountContext -Permission r -ExpiryTime (Get-Date).AddHours(4)
$ArtifactsLocationSasToken | out-file -Encoding ASCII -FilePath "token.txt" -NoNewLine
# $ArtifactsLocationSasToken = ConvertTo-SecureString $ArtifactsLocationSasToken -AsPlainText -Force
# Write-Host $ArtifactsLocationSasToken
$StorageAccountContext.BlobEndPoint + $StorageContainerName | out-file -Encoding ASCII -FilePath "url.txt" -NoNewLine