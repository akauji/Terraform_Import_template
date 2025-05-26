# Azure リソースと Terraform リソースのマッピング

このドキュメントでは、AzureリソースタイプとTerraformリソースタイプの対応関係、およびインポート時の注意事項を説明します。

## サポートされるリソースタイプ

### ネットワーク関連

| Azureリソースタイプ | Terraformリソースタイプ | インポート可能 | 注意事項 |
|-------------------|----------------------|-------------|---------|
| Microsoft.Network/virtualNetworks | `azurerm_virtual_network` | ✅ | - |
| Microsoft.Network/virtualNetworks/subnets | `azurerm_subnet` | ✅ | サブネットは個別にインポートが必要 |
| Microsoft.Network/networkSecurityGroups | `azurerm_network_security_group` | ✅ | セキュリティルールも含まれる |
| Microsoft.Network/publicIPAddresses | `azurerm_public_ip` | ✅ | - |
| Microsoft.Network/networkInterfaces | `azurerm_network_interface` | ✅ | IP設定も含まれる |
| Microsoft.Network/loadBalancers | `azurerm_lb` | ✅ | バックエンドプールは別途設定 |
| Microsoft.Network/applicationGateways | `azurerm_application_gateway` | ✅ | 複雑な設定のため要注意 |

### コンピューティング関連

| Azureリソースタイプ | Terraformリソースタイプ | インポート可能 | 注意事項 |
|-------------------|----------------------|-------------|---------|
| Microsoft.Compute/virtualMachines | `azurerm_virtual_machine` | ✅ | パスワードは取得不可 |
| Microsoft.Compute/virtualMachines | `azurerm_linux_virtual_machine` | ✅ | OS種別に応じて選択 |
| Microsoft.Compute/virtualMachines | `azurerm_windows_virtual_machine` | ✅ | OS種別に応じて選択 |
| Microsoft.Compute/disks | `azurerm_managed_disk` | ✅ | - |
| Microsoft.Compute/availabilitySets | `azurerm_availability_set` | ✅ | - |
| Microsoft.Compute/virtualMachineScaleSets | `azurerm_virtual_machine_scale_set` | ✅ | 複雑な設定のため要注意 |

### ストレージ関連

| Azureリソースタイプ | Terraformリソースタイプ | インポート可能 | 注意事項 |
|-------------------|----------------------|-------------|---------|
| Microsoft.Storage/storageAccounts | `azurerm_storage_account` | ✅ | アクセスキーは取得不可 |
| Microsoft.Storage/storageAccounts/blobServices/containers | `azurerm_storage_container` | ✅ | 個別にインポートが必要 |
| Microsoft.Storage/storageAccounts/fileServices/shares | `azurerm_storage_share` | ✅ | 個別にインポートが必要 |

### データベース関連

| Azureリソースタイプ | Terraformリソースタイプ | インポート可能 | 注意事項 |
|-------------------|----------------------|-------------|---------|
| Microsoft.Sql/servers | `azurerm_mssql_server` | ✅ | 管理者パスワードは取得不可 |
| Microsoft.Sql/servers/databases | `azurerm_mssql_database` | ✅ | - |
| Microsoft.DBforPostgreSQL/servers | `azurerm_postgresql_server` | ✅ | パスワードは取得不可 |
| Microsoft.DBforMySQL/servers | `azurerm_mysql_server` | ✅ | パスワードは取得不可 |
| Microsoft.DocumentDB/databaseAccounts | `azurerm_cosmosdb_account` | ✅ | キーは取得不可 |

### Web関連

| Azureリソースタイプ | Terraformリソースタイプ | インポート可能 | 注意事項 |
|-------------------|----------------------|-------------|---------|
| Microsoft.Web/serverFarms | `azurerm_app_service_plan` | ✅ | - |
| Microsoft.Web/sites | `azurerm_app_service` | ✅ | 設定値の一部は取得不可 |
| Microsoft.Web/sites | `azurerm_function_app` | ✅ | 関数アプリの場合 |

### セキュリティ関連

| Azureリソースタイプ | Terraformリソースタイプ | インポート可能 | 注意事項 |
|-------------------|----------------------|-------------|---------|
| Microsoft.KeyVault/vaults | `azurerm_key_vault` | ✅ | アクセスポリシーも含まれる |
| Microsoft.KeyVault/vaults/secrets | `azurerm_key_vault_secret` | ❌ | セキュリティ上の理由で不可 |
| Microsoft.KeyVault/vaults/keys | `azurerm_key_vault_key` | ❌ | セキュリティ上の理由で不可 |

### 管理関連

| Azureリソースタイプ | Terraformリソースタイプ | インポート可能 | 注意事項 |
|-------------------|----------------------|-------------|---------|
| Microsoft.Resources/resourceGroups | `azurerm_resource_group` | ✅ | - |
| Microsoft.Insights/components | `azurerm_application_insights` | ✅ | - |
| Microsoft.OperationalInsights/workspaces | `azurerm_log_analytics_workspace` | ✅ | - |

## インポート時の重要な注意事項

### 1. 機密情報の取り扱い

以下の情報はセキュリティ上の理由でインポートできません：

- **パスワード**: VM、SQL Server、PostgreSQL、MySQL等の管理者パスワード
- **アクセスキー**: ストレージアカウントのアクセスキー
- **接続文字列**: データベースやストレージの接続文字列
- **シークレット**: Key Vaultのシークレット、キー、証明書
- **APIキー**: 各種サービスのAPIキー

### 2. リソース固有の注意事項

#### Virtual Machines
```hcl
# パスワード認証を使用している場合
resource "azurerm_windows_virtual_machine" "example" {
  # ... 他の設定 ...
  
  # パスワードは手動で設定が必要
  admin_password = var.admin_password  # 変数で管理
  
  # または disable_password_authentication を適切に設定
}
```

#### Storage Accounts
```hcl
resource "azurerm_storage_account" "example" {
  # ... 他の設定 ...
  
  # アクセスキーは参照可能だが、実際の値は管理されない
  # 必要に応じて azurerm_storage_account_sas や
  # data.azurerm_storage_account_sas を使用
}
```

#### Key Vault
```hcl
resource "azurerm_key_vault" "example" {
  # ... 他の設定 ...
  
  # アクセスポリシーは完全にインポートされる
  access_policy {
    # 既存のポリシーがインポートされる
  }
  
  # ただし、シークレット等は別途管理が必要
}
```

### 3. 複雑なリソースの処理

#### Application Gateway
Application Gatewayは設定が複雑で、以下の点に注意が必要です：

- バックエンドプール設定
- リスナー設定
- ルーティングルール
- SSL証明書（Key Vaultから参照している場合）

#### Virtual Machine Scale Sets
VMSS（仮想マシンスケールセット）は以下の要素が含まれます：

- ネットワーク設定
- ストレージ設定
- 拡張機能設定
- 自動スケール設定

## インポート手順の詳細

### 1. 依存関係の考慮

リソースをインポートする際は、依存関係を考慮した順序で実行してください：

1. **Resource Group** → 最初にインポート
2. **Virtual Network** → ネットワークの基盤
3. **Subnet** → VNet後にインポート
4. **Network Security Group** → セキュリティ設定
5. **Storage Account** → 他のリソースが依存する可能性
6. **Public IP** → Load BalancerやVMが依存
7. **Network Interface** → VMが依存
8. **Virtual Machine** → 最後にインポート

### 2. インポートコマンドの例

#### Resource Group
```bash
terraform import azurerm_resource_group.main /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}
```

#### Virtual Network
```bash
terraform import azurerm_virtual_network.main /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}
```

#### Subnet
```bash
terraform import azurerm_subnet.main /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}
```

#### Storage Account
```bash
terraform import azurerm_storage_account.main /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Storage/storageAccounts/{storage-account-name}
```

### 3. インポート後の検証

インポート後は以下のコマンドで状態を確認してください：

```bash
# 全リソースの状態確認
terraform show

# 特定リソースの詳細確認
terraform show azurerm_resource_group.main

# 設定ファイルの妥当性確認
terraform validate

# 差分確認（0 changes が理想）
terraform plan
```

## トラブルシューティング

### よくあるエラーと解決方法

#### 1. リソースが見つからないエラー
```
Error: Cannot import non-existent remote object
```
**解決方法**: リソースIDが正しいか確認してください。

#### 2. 権限不足エラー
```
Error: authorization failed
```
**解決方法**: 適切な権限（Contributor以上）があることを確認してください。

#### 3. 既に存在するリソースエラー
```
Error: A resource with the ID already exists
```
**解決方法**: `terraform state list` で既存の状態を確認し、必要に応じて `terraform state rm` でリソースを削除してください。

#### 4. 設定の不一致エラー
```
Error: configuration does not match the actual resource
```
**解決方法**: `terraform show` の出力と設定ファイルを比較し、不一致箇所を修正してください。

## 推奨ワークフロー

1. **計画段階**
   - インポート対象リソースの特定
   - 依存関係の整理
   - 機密情報の管理方法決定

2. **準備段階**
   - バックアップの取得
   - 開発環境での検証
   - チームメンバーへの通知

3. **実行段階**
   - 段階的なインポート
   - 各段階での検証
   - エラー時の対応

4. **完了段階**
   - 最終検証
   - ドキュメント更新
   - チーム共有

この手順に従うことで、安全かつ効率的にAzureリソースをTerraformに移行できます。
