### AWS Lambda python　サンプル

PythonでAWS Lambdaを作成する

* 依存パッケージをLambdaレイヤーとして登録する
* 関数URLを設定する

### デプロイ方法

1. デプロイに必要な外部モジュールをrequirements.txtに書き込む

```
$ pip freeze > ./requirements.txt
```

2. デプロイ用パッケージ(.zip)を作成する

```
$ sh ./build.sh
```

スクリプトの実行によってソース(src/)とrequirements.txtで指示される依存パッケージが./buildの下に集められる

3. terraformでzipファイルにパッケージ化してlambda関数としてデプロイする
   
```
$ terraform plan

$ terraform apply

$ terraform destroy
```

