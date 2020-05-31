# Splunk-COVID19-Japan

COVID19 Japan Dashboard for Splunk

"[Coronavirus Disease (COVID-19) Japan Tracker](https://covid19japan.com/)"、「[特設サイト 新型コロナウイルス 都道府県別の感染者数・感染者マップ｜NHK](https://www3.nhk.or.jp/news/special/coronavirus/data/)」、「[新型コロナウイルス 国内感染の状況 - 東洋経済オンライン](https://toyokeizai.net/sp/visual/tko/covid19/)」のデータを利用して Splunk のダッシュボードを作成しています。



## 対象プラットフォームと Requirements

* Linux のみを対象としています。
* シェルスクリプトを使用していますので、Windows ではデータの取得ができません。
* JSON データの取得には、wget コマンドを使用しています。



## インストール

`covid19-japan.spl` をインストールするか、`covid19-japan/` ディレクトリを `$SPLUNK_HOME/etc/apps/covid19-japan/` としてコピーしてください。

### I. (必須-選択) .spl ファイルによるインストール

* [Release](https://github.com/s-yamano/Splunk-COVID19-Japan/releases/latest) から covid19-japan.spl の最新版を取得します。

* Web UI からのインストール
	1. ログインします。
	2. 「App の管理]-[ファイルから App をインストール]  
		ファイルを選択し、[アップロード]でファイルをアップロードします。

* CUI からのインストール
	1. `$SPLUNK_HOME/bin/splunk install app covid19-japan.spl`  
		ユーザ認証が必要になります。

### I. (必須-選択) ディレクトリのコピーによるインストール

1. (管理者権限などで) cp -r covid19-japan/ $SPLUNK_HOME/etc/apps/

### II. (必須-共通) セットアップの実行

セットアップページは用意していませんので、コマンドラインで `setupSplunkDir.sh` を実行します。

1. `cd $SPLUNK_HOME/etc/apps/covid19-japan/`
2. `sudo bin/setupSplunkDir.sh`
3. debug/refresh で再読込するか、Splunk を再起動します。


### III. (オプション-共通) Alternative ページの利用

"[Coronavirus Disease (COVID-19) Japan Tracker](https://covid19japan.com/)" のデータは、JSON データを取得してダッシュボードを構成していますが、代替用に Web スクレイピングによるデータのダッシュボードを用意しています。

このダッシュボード (COVID19 Japan Alternative) を利用する場合には、スクリプトによるデータ入力を有効にします。

1. `cd $SPLUNK_HOME/etc/apps/covid19-japan/lib`
2. (書き込み権限のあるユーザで) `pip3 install -r requirements.txt -t .`
3. [設定]-[データ入力]-[スクリプト]  
	`$SPLUNK_HOME/etc/apps/covid19-japan/bin/updateCovid19JapanCSV.sh` を「有効」にします。

## ダッシュボード情報

1. COVID19 Japan  
	![Screenshot_2020-05-03 COVID19 Japan Splunk 8 0 3-320x729.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/555032/64fa87fa-7c04-ac16-8290-a82fad94fbb7.png)
	1. [Coronavirus Disease (COVID-19) Japan Tracker](https://covid19japan.com/) をもとにした、日本全国のダッシュボード
	
2. COVID19 Japan Analysis  
	![Screenshot_2020-05-03 COVID19 Japan Analysis Splunk 8 0 3-320x406.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/555032/be9a29d5-dbe0-452e-9682-e59c2186ddf2.png)
	1. 死亡率、回復率、男女比、年代比などの分析ダッシュボード
	
3. COVID19 Japan (specific prefecture)  
	![Screenshot_2020-05-03 COVID19 Japan (specific prefecture) Splunk 8 0 3-320x367.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/555032/dadd843f-14d7-27cd-50a9-5cb576cbe832.png)
	1. 各都道府県(選択) の個別ダッシュボード
	
4. COVID19 Japan NHK  
	![Screenshot_2020-05-04 COVID19 Japan NHK Splunk 8 0 3-320-546.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/555032/fda59013-6bd8-02a0-b0b4-a77f18fde6e1.png)
	1. [特設サイト 新型コロナウイルス 都道府県別の感染者数・感染者マップ｜NHK](https://www3.nhk.or.jp/news/special/coronavirus/data/) の非公式データを利用したダッシュボード

5. COVID19 Japan Toyo Keizai Online  
	![COVID19 Japan Toyo Keizai Online Screenshot](https://user-images.githubusercontent.com/62424650/81471263-e666cd00-922a-11ea-9fd0-059ef26a7777.png)
	1. [新型コロナウイルス 国内感染の状況](https://toyokeizai.net/sp/visual/tko/covid19/) のデータを用いて、同ページをエミュレートしたダッシュボード

## 制限/注意事項

1. 取得した JSON データと CSV データは、取得日時をファイル名に付加して `/var/local/COVID19/Japan/{csv_source,json_source,NHK}` ディレクトリ下に保存しています。  
	Splunk で読み込んだ後は不要になりますので、適宜、削除あるいはアーカイブしてください。(logrotate の設定は用意していません。)

2. セットアップページは用意していません。必ず `setupSplunkDir.sh` を実行してください。

3. JSON データをそのまま読み込んで Splunk で加工しています。  
	その際、JSON の構造により、メモリの消費量が大きくなるため、SavedSearch (アラート) で CSV ファイルに加工しています。

4. 最初のデータ取り込みが行われるまで、"COVID19 Japan Analysis" ダッシュボードの一部のパネルが表示されません。


## データソース

### COVID19 感染者データ

以下の二次データを利用しています。

* [Coronavirus Disease (COVID-19) Japan Tracker](https://covid19japan.com/)
	* [reustle/covid19japan-data - GitHub](https://github.com/reustle/covid19japan-data/)
		* [Full merged list of patient data for all of Japan.](https://data.covid19japan.com/patient_data/latest.json)
		* [Daily summary and Per-prefecture summary.](https://data.covid19japan.com/summary/latest.json)
		* [Tokyo per-ward/city summary.](https://data.covid19japan.com/tokyo/counts.json)
* [特設サイト 新型コロナウイルス 都道府県別の感染者数・感染者マップ｜NHK](https://www3.nhk.or.jp/news/special/coronavirus/data/)
	* [日本国内の感染確認者数の推移 累計値 (JSON)](https://www3.nhk.or.jp/news/special/coronavirus/data/47patients-data.json)
	* [日本国内の感染確認者数の推移 １日ごとの発表数 (JSON)](https://www3.nhk.or.jp/news/special/coronavirus/data/47newpatients-data.json)
* [新型コロナウイルス 国内感染の状況 - 東洋経済オンライン](https://toyokeizai.net/sp/visual/tko/covid19/)
	* [kaz-ogiwara/covid19 - GitHub](https://github.com/kaz-ogiwara/covid19/)

一次データについては、各サイトのページをご覧ください。

### マップデータ

* [NipponMap](https://cran.r-project.org/web/packages/NipponMap/index.html)
* [地理院タイル](https://maps.gsi.go.jp/development/ichiran.html)

### 緯度経度データ

* [位置参照情報ダウンロードサービス(GISホームページ) (国土交通省国土政策局国土情報課)](http://nlftp.mlit.go.jp/isj/index.html)
* [Google マップ](https://www.google.co.jp/maps/)

### 地方自治体データ

* [総務省｜電子自治体｜全国地方公共団体コード](https://www.soumu.go.jp/denshijiti/code.html)
* [J-LIS 地方公共団体コード住所](https://www.j-lis.go.jp/spd/code-address/jititai-code.html)
* [市区町村名・コード | 政府統計の総合窓口](https://www.e-stat.go.jp/municipalities/cities)
* [住民基本台帳に基づく人口、人口動態及び世帯数調査 調査の結果 年次 2019年 | ファイル | 統計データを探す | 政府統計の総合窓口](https://www.e-stat.go.jp/stat-search/files?page=1&layout=datalist&toukei=00200241&tstat=000001039591&cycle=7&year=20190&month=0&tclass1=000001039601&result_back=1)

これらの地方自治体データと緯度経度データを統合して利用しています。

* LocalGovernmentCode.csv  
	地方自治体コード(都道府県名、市区町村名、それぞれ、「漢字」「ｶﾅ」「カナ」「かな」の変換用)
* latlongJapan.csv  
	緯度経度データ (大字町丁目コード、緯度、経度)
* PrefecturesList.csv  
	都道府県データ (人口等を含む)
* CapitalJapan.csv  
	都道府県データ (都道府県庁所在地住所、緯度、経度、Googleマップ 緯度、経度)

今回のダッシュボード作成では全ては利用していませんが、有用なので残してあります。

### 人口データ

* [人口推計 010 都道府県，年齢（5歳階級），男女別人口－総人口，日本人人口 | データベース | 統計データを探す | 政府統計の総合窓口](https://www.e-stat.go.jp/stat-search/database?page=1&statdisp_id=0003412322)


* populationJapan.csv -> populationJapan-20191001.csv  
	「10万人当たりの7日間合計感染者数」に使用。


## 参考

* [「東京都 新型コロナウイルス感染症対策サイト」から派生した各ページとデータソースの状況 - Qiita](https://qiita.com/msi/items/fad800061808cc92060a)
* [Splunk による COVID19 日本の状況ダッシュボード - Qiita](https://qiita.com/msi/items/c4151dc2f6e6537e154a)
* 「実行再生産数」は簡易計算式 "(直近7日間の新規陽性者数 / その前7日間の新規陽性者数)^(平均世代時間 / 報告間隔)" を使用しています。  
	平均世代時間: 5, 報告間隔: 7 と仮定

## 変更履歴

|Version|Release Date|Description|
|:--|:--|:--|
|[v0.4.10](https://github.com/s-yamano/Splunk-COVID19-Japan/releases/tag/v0.4.10)	|2020/05/31	|"COVID19 Japan" ダッシュボードに実効再生産数グラフを追加<br />"COVID19 Japan (specific prefecture)" ダッシュボードに実効再生産数グラフを追加
|v0.4.9	|2020/05/26	|"COVID19 Japan Toyo Keizai Online" ダッシュボードの県別グラフを単一県表示に変更
|v0.4.8	|2020/05/26	|メモリ消費量を減らすため、mvexpand を置換 (一部残っている)
|v0.4.7	|2020/05/23	|東洋経済オンラインページに合わせて単一県の「実効再生産数」グラフを追加
|v0.4.6	|2020/05/21	|東洋経済オンラインページに合わせて「実効再生産数」グラフを追加
|v0.4.5.2|2020/05/19	|"COVID19 Japan (specific prefecture)" ダッシュボードに「10万人当たりの7日間合計感染者数」を追加。<br />"COVID19 Japan" ダッシュボードの「10万人当たりの7日間合計感染者数」配置を変更。
|0.4.4	|2020/05/17	|"COVID19 Japan" ダッシュボードに「10万人当たりの7日間合計感染者数」を追加。
|0.4.3	|2020/05/15	|東洋経済オンライン元データの CSV ヘッダ変更に対応。(県別テーブル)
|0.4.1	|2020/05/12	|東洋経済オンライン元データの CSV ヘッダ変更に対応。
|0.4.0	|2020/05/09	|東洋経済オンラインのエミュレート Dashboard を追加。
|0.3.5	|2020/05/09	|alternative Dashboard 情報元のデータ構造の変更に対応。
|0.3.4	|2020/05/08	|annotation を追加。対数軸等の修正を追加。
|0.3.3	|2020/05/05	|データ取得スクリプトで flock がない場合には lockf を使用するように修正
|0.3.2	|2020/05/05	|昨日公表分の日付表示不具合を修正
|0.3.1	|2020/05/04	|Saved Search による結果が 0 の場合に lookup テーブルのサイズが 0 になる不具合を修正
|[0.3.0](https://github.com/s-yamano/Splunk-COVID19-Japan/releases/tag/v0.3.0)	|2020/05/03	|Initial Release
