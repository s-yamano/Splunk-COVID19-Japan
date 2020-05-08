# lib ディレクトリのセットアップ

##`GetCovid19Japan.py` の実行に必要なライブラリのインストール。

* GetCoivd19Japan.py は、"COVID19 Japan Alternative" で使用します。  
  "COVID19 Japan Alternative" を有効にしない場合には設定不要です。
* "COVID19 Japan Alternative" は、[COVID19Japan.com Data (2020-04-14) - Google ドライブ](https://docs.google.com/spreadsheets/d/e/2PACX-1vRj0RcpTglCmtDVP1RRx21ZwteYU2Y_8JExoeIVbMG1onsmHHah3DwI2HwunY8FOU3eqme82th_hYWF/pubhtml)  を Web スクレイピングによって取得したデータを用いています。
* `bin/updateCovid19JapanCSV.sh` によって各シートのデータを取得します。
* `bin/updateCovid19JapanCSV.sh` から `GetCoivd19Japan.py` を呼び出します。


## ライブラリのインストール

```
cd lib/		# このディレクトリ
pip3 install -r requirements.txt -t .
```

## COVID19 Japan Alternative の有効化

* [データ入力]-[スクリプト]  
   `$SPLUNK_HOME/etc/apps/covid19-japan/bin/updateCovid19JapanCSV.sh`  
   ステータスを [有効] にします。
