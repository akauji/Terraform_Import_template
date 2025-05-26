# クイックスタートガイド

既存のAzure環境を迅速にTerraformにインポートするための簡単な手順です。

## 🚀 5分でできるクイックスタート

### ステップ1: 設定ファイルの準備
```powershell
# 1. 開発環境用設定ファイルをコピー
cp environments\dev\terraform.tfvars.example environments\dev\terraform.tfvars

# 2. 設定ファイルを編集（実際の値に変更）
notepad environments\dev\terraform.tfvars
```

### ステップ2: Azure CLI認証
```bash
az login
az account set --subscription "your-subscription-id"
```

### ステップ3: リソース一覧の取得
```powershell
# リソースグループ内のリソースを確認
.\scripts\azure_resource_list.ps1 -SubscriptionId "your-sub-id" -ResourceGroupName "your-rg-name"
```

### ステップ4: インポートコードの生成
```powershell
# インポート用ファイルを自動生成
.\scripts\generate_import.ps1 -SubscriptionId "your-sub-id" -ResourceGroupName "your-rg-name" -GenerateImportScript -GenerateResourceDefinitions
```

### ステップ5: Terraformでインポート実行
```powershell
# 1. 初期化
terraform init

# 2. インポート実行
.\scripts\import_resources.ps1

# 3. 結果確認
terraform plan
```

## 📋 チェックリスト

- [ ] Azure CLI がインストール済み
- [ ] Terraform がインストール済み  
- [ ] PowerShell 7+ がインストール済み
- [ ] Azure サブスクリプションへのアクセス権限
- [ ] terraform.tfvars ファイルが設定済み
- [ ] リソースのバックアップが取得済み

## ⚠️ 重要な注意事項

1. **バックアップ必須**: 作業前に必ずリソースのバックアップを取得してください
2. **権限確認**: Contributor以上の権限が必要です
3. **機密情報**: パスワードやシークレットは手動設定が必要です
4. **チーム作業**: インポート中は他のメンバーの作業を停止してください

## 🔧 よくある問題と解決方法

### インポートに失敗する場合
```powershell
# 権限とリソースIDを確認
az resource show --ids "/subscriptions/xxx/resourceGroups/xxx/providers/xxx"
```

### terraform plan で差分が出る場合
```bash
# 現在の状態を確認
terraform show azurerm_resource_group.main

# 設定ファイルを調整後に再確認
terraform plan
```

## 📚 詳細な手順

詳細な手順については以下のドキュメントを参照してください：
- [インポート手順書](docs/import_guide.md)
- [リソースマッピング](docs/resource_mapping.md)

## 🆘 サポート

問題が発生した場合は、生成されたログファイル（import_log.txt）を確認してください。
