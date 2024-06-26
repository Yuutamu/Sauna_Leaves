# はじめに
### テントサウナのレンタルサービスとは？
- 一式購入するとなると30万近く費用を要するテントサウナをレンタルにてご利用いただけるサービスです。
- レンタルしてみて、気に入れば弊社定価からレンタル料金を差し引いた金額で購入が可能（→損しない料金プラン）

- テントサウナは楽しいので、みんなに利用して欲しい！楽しんでもらいたい！（→完全に趣味の延長のサービスです。レンタルしてくれる場合は、僕も一緒に連れてってほしいです(笑) 僕の特技は火打ち石から火を起こすことです！）

### サービスURL
（現在はβ版ということで、クローズドで運営しています。）
https://sauna-leaves.onrender.com/

# ざっくりと機能説明
- エンドユーザー向け機能
  - ユーザー認証
  - 商品閲覧、カート追加、購入
  - 決済機能（Stripeを利用）
  - メール送信機能

- 管理者画面（用途：運営スタッフ利用）
  - 商品登録、掲載
  - 在庫管理
  - 顧客ステータス管理（Stripeから怪しいユーザー検出された場合は、印を付けておく等）
  - 出荷/返送管理
  - 売上表示機能

# 画面遷移図（figma）
https://www.figma.com/design/BHzg3RYenNvqUUbCXc0Wze/SaunaLeaves_%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E5%9B%B3?node-id=0%3A1&t=RXCxmitysttMdm3Q-1

# 技術スタック

### 言語、フレームワーク
- Ruby
- Ruby on Rails
- TailWind CSS

### データベース
- PostgreSQL
- Redis

### 決済機能
- [Stripe](https://stripe.com/docs/api)
 決済ページもstripe webhook を用いて実装

### コード 品質管理
- Rubocop

### 非同期処理
- Sidekiq
顧客への注文確認メールの送信を非同期にて処理しています。
Sidekiq 選定理由：他サービスよりもメンテナンスがされてるいること、1個のプロセスで動作させられるのでメモリ使用量が少なく経済的ということから。

### メール送信機能
- Action Mailer

### アイコン
- [Google icons](https://fonts.google.com/icons)
- [Heroicons](https://heroicons.com/)

## 動かし方
注文するには、StripeのCLIをdocker上で立ち上げる必要があります。
（dockerfile でアクセス等を記載しておけば必要なし。）

以下のdockerを利用して作成しております。
https://github.com/nickjj/docker-rails-example

# 今後、特に手を加えたい箇所
## UI周り
- カートUI
- SVGアイコンの修正
- 注文後のサンクスページ
- Stripe のプランアップグレードして独自の決済ページ開発したい（UI・UX向上の為）
- ダークモードUIの実装

## バックエンド
- Stripe のプランアップグレードして注文時の配送日指定等の部分を実装したい
- 商品に関するDB構造のテコ入れ（ブランド、商品カテゴリ等を追加）
- 上記の商品カテゴリに対しする検索機能の導入

## その他
- Magagine としてテントサウナに関するWebメディアを作成予定なので、商品詳細ページ等へのリンクの設置と記事作成
