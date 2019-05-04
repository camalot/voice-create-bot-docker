#!/usr/bin/env pwsh


param(
    [String] $ProjectName = "voice-create-bot-docker",
    [String] $DockerOrg = "camalot",
    [String] $Version = "latest"
)

$ENV_LIST = "";
# Load .env file
Get-Content .env | Where-Object { $_ -match "^([A-Z_]+)=(.*?)$" } | ForEach-Object {
    $VALS = $_.Split('=');
    New-Item -Name $VALS[0] -value $VALS[1] -ItemType Variable -Path Env: -Force | Out-Null;
    # Get-Item -Path "Env:$($VALS[0])";
    $ENV_LIST += "$($VALS[0])=`"$($VALS[1])`" ";
}

$RAND_ID = Get-Random -Maximum 9999;
$ProjectSlug = $ProjectName -replace "-", "";
$STORAGE_ACCOUNT_NAME = "$ProjectSlug";
$DNS_NAME_LABEL = "$ProjectName-$RAND_ID";
$AZ_LOCATION = "$($ENV:AZ_LOCATION)";
$AZ_RESOURCE_GROUP = "$($ENV:AZ_RESOURCE_GROUP)";

$EXISTING_STORAGE = (az storage account list --resource-group "$AZ_RESOURCE_GROUP" | ConvertFrom-Json | Where-Object {
        $_.Name -eq "$ProjectSlug";
    } | Select-Object -First 1);

if ( $null -eq $EXISTING_STORAGE ) {
    az storage account create `
        --resource-group "$AZ_RESOURCE_GROUP" `
        --name $STORAGE_ACCOUNT_NAME `
        --sku Standard_LRS `
        --location "$AZ_LOCATION" | Out-Null;
}

$AZURE_STORAGE_CONNECTION_STRING = (az storage account show-connection-string `
        --resource-group "$AZ_RESOURCE_GROUP" `
        --name $STORAGE_ACCOUNT_NAME `
        --output tsv)

New-Item -Name "AZURE_STORAGE_CONNECTION_STRING" -value "$AZURE_STORAGE_CONNECTION_STRING" -ItemType Variable -Path Env: -Force | Out-Null;

$EXISTING_SHARE = (az storage share list | ConvertFrom-Json | Where-Object {
        $_.Name -eq "$ProjectName";
    } | Select-Object -First 1);
if ( $null -eq $EXISTING_SHARE ) {
		az storage share create --name "$ProjectName" --verbose | Out-Null;
    az storage share policy create --permissions dlrw --verbose | Out-Null;
}
$STORAGE_KEY = (az storage account keys list `
        --resource-group "$AZ_RESOURCE_GROUP" `
        --account-name $STORAGE_ACCOUNT_NAME `
        --query "[0].value" `
        --output tsv);

"$DockerOrg/$($ProjectName):$Version";

az container create `
		--assign-identity `
		--memory 0.5 `
		--cpu 0.3 `
    --resource-group "$AZ_RESOURCE_GROUP" `
    --name "$ProjectName" `
    --image "$DockerOrg/$($ProjectName):$Version" `
    --dns-name-label $DNS_NAME_LABEL `
    --restart-policy OnFailure `
    --secure-environment-variables `
      DISCORD_BOT_TOKEN="$ENV:DISCORD_BOT_TOKEN" `
    --environment-variables `
      VCB_DB_PATH="$ENV:VCB_DB_PATH" `
    --os-type Linux `
    --location "$AZ_LOCATION" `
		--verbose;
    # --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME `
    # --azure-file-volume-account-key $STORAGE_KEY `
    # --azure-file-volume-share-name "$ProjectName" `
		# --azure-file-volume-mount-path "/data/" `
