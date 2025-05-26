# Import Resources Script
# このスクリプトは生成されたインポートコマンドを実行します

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ImportScriptPath = ".\import_commands.ps1",
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory = $false)]
    [switch]$ContinueOnError,
    
    [Parameter(Mandatory = $false)]
    [string]$LogFile = "import_log.txt"
)

# ログ関数
function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    $logEntry | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# Terraformが利用可能かチェック
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Log "Terraform が見つかりません。Terraform をインストールしてください。" "ERROR"
    exit 1
}

# インポートスクリプトの存在確認
if (-not (Test-Path $ImportScriptPath)) {
    Write-Log "インポートスクリプトが見つかりません: $ImportScriptPath" "ERROR"
    Write-Log "先に generate_import.ps1 を実行してインポートスクリプトを生成してください。" "ERROR"
    exit 1
}

Write-Log "インポートプロセスを開始します" "INFO"
Write-Log "インポートスクリプト: $ImportScriptPath" "INFO"
Write-Log "ドライラン: $DryRun" "INFO"
Write-Log "エラー時継続: $ContinueOnError" "INFO"

# Terraform初期化
Write-Log "Terraform を初期化中..." "INFO"
if (-not $DryRun) {
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Terraform 初期化に失敗しました。" "ERROR"
        exit 1
    }
}

# インポートスクリプトの内容を読み込み
$importCommands = Get-Content $ImportScriptPath | Where-Object { $_ -match "^terraform import" }

if ($importCommands.Count -eq 0) {
    Write-Log "インポートコマンドが見つかりません。" "ERROR"
    exit 1
}

Write-Log "発見されたインポートコマンド数: $($importCommands.Count)" "INFO"

# 進行状況カウンター
$currentCommand = 0
$successCount = 0
$failureCount = 0
$failedCommands = @()

foreach ($command in $importCommands) {
    $currentCommand++
    $progress = [math]::Round(($currentCommand / $importCommands.Count) * 100, 1)
    
    Write-Log "[$currentCommand/$($importCommands.Count)] ($progress%) 実行中: $command" "INFO"
    
    if ($DryRun) {
        Write-Log "[DRYRUN] $command" "INFO"
        $successCount++
    } else {
        try {
            # コマンドを実行
            Invoke-Expression $command
            
            if ($LASTEXITCODE -eq 0) {
                Write-Log "成功: $command" "SUCCESS"
                $successCount++
            } else {
                Write-Log "失敗: $command (終了コード: $LASTEXITCODE)" "ERROR"
                $failureCount++
                $failedCommands += $command
                
                if (-not $ContinueOnError) {
                    Write-Log "エラーのためインポートを中断します。" "ERROR"
                    break
                }
            }
        } catch {
            Write-Log "例外発生: $command - $($_.Exception.Message)" "ERROR"
            $failureCount++
            $failedCommands += $command
            
            if (-not $ContinueOnError) {
                Write-Log "例外のためインポートを中断します。" "ERROR"
                break
            }
        }
    }
    
    # 進行状況バーの表示
    Write-Progress -Activity "Terraformリソースインポート" -Status "$currentCommand/$($importCommands.Count) 完了" -PercentComplete $progress
}

# 完了メッセージ
Write-Progress -Activity "Terraformリソースインポート" -Completed

Write-Log "`n=== インポート結果サマリー ===" "INFO"
Write-Log "総コマンド数: $($importCommands.Count)" "INFO"
Write-Log "成功: $successCount" "SUCCESS"
Write-Log "失敗: $failureCount" "ERROR"

if ($failedCommands.Count -gt 0) {
    Write-Log "`n失敗したコマンド:" "ERROR"
    foreach ($cmd in $failedCommands) {
        Write-Log "  $cmd" "ERROR"
    }
}

if (-not $DryRun) {
    Write-Log "`n次の推奨手順:" "INFO"
    Write-Log "1. terraform show を実行してインポートされたリソースの詳細を確認" "INFO"
    Write-Log "2. .tf ファイルのリソース定義を実際の設定に合わせて更新" "INFO"
    Write-Log "3. terraform plan を実行して設定の差分がないことを確認" "INFO"
    Write-Log "4. 必要に応じて terraform apply を実行" "INFO"
    
    # terraform show の実行を提案
    $response = Read-Host "`nterraform show を実行してインポートされたリソースを確認しますか？ (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Log "terraform show を実行中..." "INFO"
        terraform show
    }
}

Write-Log "インポートプロセス完了" "INFO"

# 終了コードを設定
if ($failureCount -gt 0 -and -not $ContinueOnError) {
    exit 1
} else {
    exit 0
}
