# Azure Resource List Script
# このスクリプトは指定されたリソースグループまたはサブスクリプション内のAzureリソースを一覧表示します

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "",
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFormat = "table",  # table, json, csv
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFile = ""
)

# Azure CLIが利用可能かチェック
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI が見つかりません。Azure CLI をインストールしてください。"
    exit 1
}

# サブスクリプションを設定
Write-Host "サブスクリプション $SubscriptionId を設定中..." -ForegroundColor Green
az account set --subscription $SubscriptionId

if ($LASTEXITCODE -ne 0) {
    Write-Error "サブスクリプションの設定に失敗しました。"
    exit 1
}

# リソース一覧を取得
if ($ResourceGroupName) {
    Write-Host "リソースグループ '$ResourceGroupName' のリソースを取得中..." -ForegroundColor Green
    $query = "az resource list --resource-group '$ResourceGroupName'"
} else {
    Write-Host "サブスクリプション内の全リソースを取得中..." -ForegroundColor Green
    $query = "az resource list"
}

# 出力形式に応じてクエリを調整
switch ($OutputFormat.ToLower()) {
    "json" {
        $resources = Invoke-Expression "$query --output json" | ConvertFrom-Json
    }
    "table" {
        $resources = Invoke-Expression "$query --output table"
    }
    "csv" {
        $resources = Invoke-Expression "$query --output json" | ConvertFrom-Json
    }
    default {
        $resources = Invoke-Expression "$query --output table"
    }
}

# 結果を表示
if ($OutputFormat.ToLower() -eq "csv") {
    # CSV形式で出力
    $csvData = $resources | Select-Object Name, Type, ResourceGroup, Location, @{Name='Tags'; Expression={($_.tags | ConvertTo-Json -Compress)}}
    $csvOutput = $csvData | ConvertTo-Csv -NoTypeInformation
    
    if ($OutputFile) {
        $csvOutput | Out-File -FilePath $OutputFile -Encoding UTF8
        Write-Host "結果を $OutputFile に保存しました。" -ForegroundColor Green
    } else {
        $csvOutput
    }
} elseif ($OutputFormat.ToLower() -eq "json") {
    # JSON形式で出力
    $jsonOutput = $resources | ConvertTo-Json -Depth 10
    
    if ($OutputFile) {
        $jsonOutput | Out-File -FilePath $OutputFile -Encoding UTF8
        Write-Host "結果を $OutputFile に保存しました。" -ForegroundColor Green
    } else {
        $jsonOutput
    }
} else {
    # テーブル形式で出力
    if ($OutputFile) {
        $resources | Out-File -FilePath $OutputFile -Encoding UTF8
        Write-Host "結果を $OutputFile に保存しました。" -ForegroundColor Green
    } else {
        $resources
    }
}

# リソースタイプ別の統計を表示
if ($OutputFormat.ToLower() -ne "table") {
    Write-Host "`n=== リソースタイプ別統計 ===" -ForegroundColor Yellow
    $typeStats = $resources | Group-Object Type | Sort-Object Count -Descending
    $typeStats | ForEach-Object {
        Write-Host "$($_.Name): $($_.Count) 個" -ForegroundColor Cyan
    }
    
    Write-Host "`n総リソース数: $($resources.Count)" -ForegroundColor Green
}

Write-Host "`nスクリプト実行完了" -ForegroundColor Green
