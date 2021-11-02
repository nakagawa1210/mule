c-tcp-broker 
===================================

TCP/IP を用いてC言語 で作成したメッセージブローカ

# 各ファイルの説明

test.sh:引数にメッセージ送信回数とデータのサイズ(ｋB)，出力するファイルの名前，ウィンドウサイズ，ポート番号をとり，プログラムを実行するシェルスクリプト

recv_client.c:メッセージを受信し，測定した時刻を.log ファイルとしてlogディレクトリ以下に出力する．

send_client.c:メッセージをサーバに送信する．

server.c:メッセージを送受信するサーバ

ssh_test.sh:sshでhsc1に接続し，指定した回数 tcp_test.shを実行するシェルスクリプト

make_percent.sh:直前に実行したWSのメッセージブローカの割合を計算しファイルに出力するスクリプト

# 実行手順
(1) 以下のコマンドでクローンする．

$ git clone git@github.com:nakagawa1210/mule.git

(2) /mule/services/c-tcp-broker ディレクトリ以下でmakeを実行する．

$ make

(3) tcp_test.sh を実行する．以下のコマンドの場合送信メッセージ数100，データサイズ1KB，windowsize 10, ポート番号10000で実行し，logディレクトリ以下にログファイルが作成される．ファイル名は「test_100_1_10_<実行した年月日>_<実行した時間>.log」になる．

$ ./test.sh 100 1 10 test 10000

(4) make_percent.sh を実行する．以下のコマンドを実行すると直前に実行してlog/latest.log に記述されている実行履歴の割合を計算して一つのファイルにまとめて出力する．

$ ./make_percent.sh
