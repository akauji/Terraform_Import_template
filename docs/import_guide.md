# Azure Terraform インポート手順書

このドキュメントでは、既存のAzure環境をTerraformでインポートする手順を説明します。

## 前提条件

### 必要なツール
- **Terraform** >= 1.0
- **Azure CLI** >= 2.0
- **PowerShell** 7+
- 適切なAzureサブスクリプションへのアクセス権限

### 権限要件
- Contributorまたは同等の権限
- Key Vaultアクセスポリシーの管理権限（Key Vaultをインポートする場合）

## ステップ1: 環境の準備

### 1.1 Azure CLIでのログイン
```bash
az login
az account set --subscription "your-subscription-id"
```

### 1.2 Terraformプロジェクトの初期化
```bash
cd Terraform_Import_template
terraform init
```

### 1.3 環境設定ファイルの準備
```bash
# 開発環境の場合
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
cp environments/dev/backend.tf.example environments/dev/backend.tf

# 設定ファイルを編集
# terraform.tfvars: 実際の値に更新
# backend.tf: 必要に応じてバックエンド設定を有効化
```

## ステップ2: 既存リソースの調査

### 2.1 リソース一覧の取得
```powershell
# 特定のリソースグループのリソースを取得
.\scripts\azure_resource_list.ps1 -SubscriptionId "your-sub-id" -ResourceGroupName "your-rg-name"

# JSON形式でファイルに出力
.\scripts\azure_resource_list.ps1 -SubscriptionId "your-sub-id" -ResourceGroupName "your-rg-name" -OutputFormat json -OutputFile "resources.json"
```

### 2.2 リソースの分析
- 取得したリソース一覧を確認
- インポート対象のリソースを特定
- 依存関係を把握

## ステップ3: インポートコードの生成

### 3.1 インポートスクリプトの生成
```powershell
# インポートコマンドとリソース定義を生成
.\scripts\generate_import.ps1 -SubscriptionId "your-sub-id" -ResourceGroupName "your-rg-name" -GenerateImportScript -GenerateResourceDefinitions
```

### 3.2 生成されたファイルの確認
- `import_commands.ps1`: インポートコマンドスクリプト
- `imported_resources.tf`: リソース定義テンプレート

## ステップ4: Terraformリソース定義の準備

### 4.1 既存の設定ファイルの更新
生成されたリソース定義を既存の`.tf`ファイルにマージするか、新しいファイルとして追加します。

### 4.2 変数の設定
`terraform.tfvars`ファイルで必要な変数を設定します：

```hcl
subscription_id     = "your-subscription-id"
resource_group_name = "your-rg-name"
location           = "Japan East"
# その他必要な変数...
```

## ステップ5: リソースのインポート実行

### 5.1 ドライランでの確認
```powershell
# ドライランで実行内容を確認
.\scripts\import_resources.ps1 -DryRun
```

### 5.2 実際のインポート実行
```powershell
# インポートを実行
.\scripts\import_resources.ps1

# エラーが発生しても継続する場合
.\scripts\import_resources.ps1 -ContinueOnError
```

## ステップ6: 設定の調整

### 6.1 現在の状態確認
```bash
# インポートされたリソースの詳細を確認
terraform show

# 特定のリソースのみ確認
terraform show azurerm_resource_group.main
```

### 6.2 リソース定義の更新
`terraform show`の出力を参考に、`.tf`ファイルのリソース定義を実際の設定に合わせて更新します。

### 6.3 設定の検証
```bash
# 設定の妥当性を確認
terraform validate

# 差分を確認（差分がなければ成功）
terraform plan
```

## ステップ7: 最終確認

### 7.1 プランの確認
```bash
terraform plan
```
**重要**: プランで変更が0件であることを確認してください。

### 7.2 状態ファイルのバックアップ
```bash
# 状態ファイルをバックアップ
cp terraform.tfstate terraform.tfstate.backup
```

## トラブルシューティング

### よくある問題と解決方法

#### 1. インポートに失敗する
- **原因**: リソースIDが正しくない、権限不足
- **解決**: Azure CLIで正確なリソースIDを確認、権限を確認

#### 2. terraform planで差分が表示される
- **原因**: リソース定義が実際の設定と一致していない
- **解決**: `terraform show`の出力と`.tf`ファイルを比較して調整

#### 3. 機密情報（パスワードなど）が表示される
- **原因**: Terraformは機密情報をインポートできない
- **解決**: 機密情報は手動で設定し、`sensitive = true`を使用

#### 4. 依存関係エラー
- **原因**: リソースの依存関係が正しく定義されていない
- **解決**: 依存関係を正しく設定、必要に応じて`depends_on`を使用

### ログとデバッグ

#### Terraformログの有効化
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
```

#### Azure CLIデバッグ
```bash
az configure --defaults group=your-rg-name
az resource list --debug
```

## ベストプラクティス

### 1. 段階的なインポート
- 小さなリソースグループから開始
- 依存関係の少ないリソースから実施
- 一度に多くのリソースをインポートしない

### 2. バックアップとテスト
- 実行前に必ずバックアップを取得
- 開発環境で手順を検証
- 状態ファイルのバージョン管理

### 3. チーム作業
- インポート作業は一人が実施
- 作業中は他のメンバーの変更を避ける
- 完了後にチーム全体に共有

### 4. ドキュメント化
- インポートしたリソースのリストを記録
- 手動で調整した箇所を文書化
- 今後の運用手順を整備

## 注意事項

1. **機密情報**: パスワード、シークレットキーなどはインポートされません
2. **一方向性**: 一度インポートしたリソースは元に戻せません
3. **状態の整合性**: チーム全体で状態ファイルを同期してください
4. **権限**: 適切な権限がないとインポートに失敗します
5. **コスト**: インポート作業自体に追加コストは発生しませんが、設定ミスによる意図しないリソース変更にご注意ください
