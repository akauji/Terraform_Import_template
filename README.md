# Azure Terraform Import Template

このプロジェクトは、既存のMicrosoft Azure環境からTerraformコードを生成するためのテンプレートです。

## プロジェクト構成

```
Terraform_Import_template/
├── README.md                   # プロジェクト概要
├── main.tf                     # メインのTerraform設定
├── variables.tf                # 変数定義
├── outputs.tf                  # 出力定義
├── terraform.tf                # Terraformプロバイダー設定
├── .gitignore                  # Git除外設定
├── environments/               # 環境設定
│   └── dev/                   # 開発環境
│       ├── terraform.tfvars   # 環境変数
│       └── backend.tf         # バックエンド設定
├── modules/                    # 再利用可能なモジュール
├── scripts/                    # 自動化スクリプト
│   ├── import_resources.ps1   # リソースインポートスクリプト
│   ├── generate_import.ps1    # インポートコード生成スクリプト
│   └── azure_resource_list.ps1 # Azureリソース一覧取得
└── docs/                      # ドキュメント
    ├── import_guide.md        # インポート手順書
    └── resource_mapping.md    # リソースマッピング
```

## 前提条件

- Terraform >= 1.0
- Azure CLI
- PowerShell 7+
- 適切なAzureサブスクリプションへのアクセス権限

## 使用方法

### 1. 初期設定
```bash
# Azure CLIでログイン
az login

# Terraformプロバイダーの初期化
terraform init
```

### 2. 既存リソースの確認
```powershell
# Azureリソース一覧を取得
.\scripts\azure_resource_list.ps1 -SubscriptionId "your-subscription-id" -ResourceGroupName "your-rg-name"
```

### 3. インポートコードの生成
```powershell
# インポート用Terraformコードを生成
.\scripts\generate_import.ps1 -ResourceGroupName "your-rg-name"
```

### 4. リソースのインポート
```powershell
# 既存リソースをTerraform状態にインポート
.\scripts\import_resources.ps1
```

## 注意事項

- インポート前に必ずバックアップを取得してください
- リソースの依存関係を確認してからインポートを実行してください
- 機密情報（パスワード、シークレットなど）は手動で設定する必要があります

## サポートするAzureリソース

- Resource Groups
- Virtual Networks
- Subnets
- Network Security Groups
- Virtual Machines
- Storage Accounts
- App Services
- SQL Databases
- Key Vaults
- その他の主要なAzureリソース

## ライセンス

MIT License
