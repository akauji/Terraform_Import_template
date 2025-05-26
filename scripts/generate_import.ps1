# Generate Terraform Import Code Script
# このスクリプトは既存のAzureリソースからTerraformのimportコードとリソース定義を生成します

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputDir = ".",
    
    [Parameter(Mandatory = $false)]
    [switch]$GenerateImportScript,
    
    [Parameter(Mandatory = $false)]
    [switch]$GenerateResourceDefinitions
)

# Azure CLIが利用可能かチェック
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI が見つかりません。Azure CLI をインストールしてください。"
    exit 1
}

# サブスクリプションを設定
Write-Host "サブスクリプション $SubscriptionId を設定中..." -ForegroundColor Green
az account set --subscription $SubscriptionId

# リソース一覧を取得
Write-Host "リソースグループ '$ResourceGroupName' のリソースを取得中..." -ForegroundColor Green
$resources = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json

if (-not $resources) {
    Write-Error "リソースが見つかりません。"
    exit 1
}

# リソースタイプとTerraformリソース名のマッピング
$resourceMapping = @{
    "Microsoft.Network/virtualNetworks" = "azurerm_virtual_network"
    "Microsoft.Network/virtualNetworks/subnets" = "azurerm_subnet"
    "Microsoft.Network/networkSecurityGroups" = "azurerm_network_security_group"
    "Microsoft.Network/publicIPAddresses" = "azurerm_public_ip"
    "Microsoft.Network/networkInterfaces" = "azurerm_network_interface"
    "Microsoft.Compute/virtualMachines" = "azurerm_virtual_machine"
    "Microsoft.Compute/disks" = "azurerm_managed_disk"
    "Microsoft.Storage/storageAccounts" = "azurerm_storage_account"
    "Microsoft.KeyVault/vaults" = "azurerm_key_vault"
    "Microsoft.Sql/servers" = "azurerm_mssql_server"
    "Microsoft.Sql/servers/databases" = "azurerm_mssql_database"
    "Microsoft.Web/serverFarms" = "azurerm_app_service_plan"
    "Microsoft.Web/sites" = "azurerm_app_service"
    "Microsoft.Resources/resourceGroups" = "azurerm_resource_group"
}

# インポートコマンドを生成
$importCommands = @()
$resourceDefinitions = @()

Write-Host "インポートコードを生成中..." -ForegroundColor Green

foreach ($resource in $resources) {
    $resourceType = $resource.type
    $resourceName = $resource.name
    $resourceId = $resource.id
    
    # リソース名をTerraform互換に変換（英数字とアンダースコアのみ）
    $terraformResourceName = $resourceName -replace '[^a-zA-Z0-9_]', '_'
    $terraformResourceName = $terraformResourceName.ToLower()
    
    if ($resourceMapping.ContainsKey($resourceType)) {
        $terraformResourceType = $resourceMapping[$resourceType]
        
        # インポートコマンドを生成
        $importCommand = "terraform import $terraformResourceType.$terraformResourceName `"$resourceId`""
        $importCommands += $importCommand
        
        # リソース定義の基本形を生成
        $resourceDef = @"
# Imported from: $resourceId
resource "$terraformResourceType" "$terraformResourceName" {
  # Configuration will be generated after import
  # Run 'terraform show' to see the current state
  # Then update this configuration to match
}

"@
        $resourceDefinitions += $resourceDef
        
        Write-Host "  追加: $terraformResourceType.$terraformResourceName" -ForegroundColor Cyan
    } else {
        Write-Warning "サポートされていないリソースタイプ: $resourceType ($resourceName)"
    }
}

# インポートスクリプトを生成
if ($GenerateImportScript -or (-not $GenerateResourceDefinitions)) {
    $importScriptPath = Join-Path $OutputDir "import_commands.ps1"
    $importScriptContent = @"
# Auto-generated Terraform import script
# Generated on: $(Get-Date)
# Resource Group: $ResourceGroupName
# Subscription: $SubscriptionId

Write-Host "Terraformインポートを開始します..." -ForegroundColor Green
Write-Host "リソースグループ: $ResourceGroupName" -ForegroundColor Yellow

# Terraform初期化
Write-Host "Terraform初期化中..." -ForegroundColor Green
terraform init

if (`$LASTEXITCODE -ne 0) {
    Write-Error "Terraform初期化に失敗しました。"
    exit 1
}

# インポートコマンド実行
"@

    foreach ($cmd in $importCommands) {
        $importScriptContent += @"

Write-Host "インポート中: $cmd" -ForegroundColor Cyan
$cmd
if (`$LASTEXITCODE -ne 0) {
    Write-Warning "インポートに失敗しました: $cmd"
}
"@
    }

    $importScriptContent += @"

Write-Host "インポート完了" -ForegroundColor Green
Write-Host "次の手順:" -ForegroundColor Yellow
Write-Host "1. terraform show を実行してリソースの現在の状態を確認"
Write-Host "2. リソース定義ファイルを現在の状態に合わせて更新"
Write-Host "3. terraform plan を実行して差分がないことを確認"
"@

    $importScriptContent | Out-File -FilePath $importScriptPath -Encoding UTF8
    Write-Host "インポートスクリプトを生成しました: $importScriptPath" -ForegroundColor Green
}

# リソース定義を生成
if ($GenerateResourceDefinitions -or (-not $GenerateImportScript)) {
    $resourceDefsPath = Join-Path $OutputDir "imported_resources.tf"
    $resourceDefsContent = @"
# Auto-generated Terraform resource definitions
# Generated on: $(Get-Date)
# Resource Group: $ResourceGroupName
# Subscription: $SubscriptionId

# NOTE: These are template definitions. You need to:
# 1. Run the import commands first
# 2. Use 'terraform show' to see the actual configuration
# 3. Update these definitions to match the current state

"@

    $resourceDefsContent += ($resourceDefinitions -join "`n")
    
    $resourceDefsContent | Out-File -FilePath $resourceDefsPath -Encoding UTF8
    Write-Host "リソース定義を生成しました: $resourceDefsPath" -ForegroundColor Green
}

# サマリーを表示
Write-Host "`n=== 生成サマリー ===" -ForegroundColor Yellow
Write-Host "総リソース数: $($resources.Count)" -ForegroundColor Green
Write-Host "インポート可能リソース数: $($importCommands.Count)" -ForegroundColor Green
Write-Host "サポート外リソース数: $($resources.Count - $importCommands.Count)" -ForegroundColor Red

if ($importCommands.Count -gt 0) {
    Write-Host "`n次の手順:" -ForegroundColor Yellow
    Write-Host "1. 生成されたインポートスクリプトを実行"
    Write-Host "2. terraform show でリソースの詳細を確認"
    Write-Host "3. リソース定義ファイルを実際の設定に合わせて更新"
    Write-Host "4. terraform plan で差分を確認"
}
