# pf-svn
## セットアップ
以下の手順に沿って、`pf-svn`を実行できる環境を構築してください。
```
git clone https://github.com/282Haniwa/pf-svn.git
cd pf-svn
mkdir ~/bin
cp pf-svn.sh ~/bin/pf-svn
chmod 755 ~/bin/pf-svn
echo "export PATH=$PATH:$HOME/bin" >> ~/.bash_profile
```

`pf-svn`を実行するとセットアップが実行されるので、セットアップに従ってワークディレクトリ、svn接続先のページターゲットとするsshポートフォワーディングのサーバー、ポートフォワーディングに使うポート番号、ポートフォワーディングが自動で切れるまでの時間を入力してください。

## コマンド内容
`pf-svn help`:
ヘルプを表示します。
このREADMEの内容をダウンロードして表示します。

`pf-svn setup`:
初回に実行した時と同じセットアップを実行します。

`pf-svn ssh`:
ターゲットサーバーへのsshを実行します。

`pf-svn pf`:
ポートフォワーディングを実行します。

`pf-svn open [page dir]`:
ターゲットのページもしくはワークディレクトリを開きます。

`pf-svn check`:
ポートフォワードされているかどうかを確認します。

`pf-svn svn`:
svnをwrapしたコマンドです。
ポートフォワードした後、svnコマンドを実行します。

`pf-svn kill`:
バックグラウンドで実行しているポートフォワードなどのプロセスをkillします。
