<div align="center">
<h1>Zenithal Math</h1>
</div>

## 概要
Zenithal Math (略称 ZenMath) は、[ZenML](https://github.com/Ziphil/Zenithal) ライクな文法で MathML をより簡潔に書けるようにしたマークアップ言語です。
人間が直接書くことを想定しています。

ZenMath はほとんど ZenML のサブセットになっています。
ZenML と異なるのは、一部の (マクロではない) 普通の要素が 2 つ以上の引数をもてるようになっている点のみです。

このリポジトリは、Ruby 実装の ZenML パーサーである `ZenithalParser` クラスを拡張した `ZenithalMathParser` クラスを提供します。
このクラスは通常の ZenML パーサーと同じように ZenML ドキュメントをパースしますが、引数の内容が ZenMath で書かれるマクロを処理できるようになっています。

## インストール
RubyGems からインストールできるようになる予定です。
```
gem install zenmath
```

## 使い方
`ZenithalMathParser` インスタンスを作成します。
`register_math_macro` メソッドを使うことで、引数の内容が ZenMath で書かれるマクロを登録することができます。
詳しくは以下のコードを参照してください。
```ruby
# ライブラリの読み込み
require 'rexml/document'
require 'zenml'
require 'zenmath'
include REXML
include Zenithal
# パーサーの作成
source = File.read("sample.zml")
parser = ZenithalMathParser.new(source)
# ZenMath マクロの登録
parser.register_math_macro("math") do |attributes, children_list|
  this = Nodes[]
  this << Element.build("inline-math") do |this|
    # children_list には ZenML ドキュメント上で該当マクロに渡された各引数を MathML に変換した要素が渡される
    # children_list の各要素は math 要素 1 つ
    this << children_list.first
  end
  next this
end
```
このようにすると、以下のような ZenML ドキュメントがパースできます。
```
\zml?|version="1.0"|>
\xml?|version="1.0",encoding="UTF-8"|>
\root<
  ## 登録した &math マクロ内に ZenMath が書ける
  2 次方程式 &math<a \sp<x><2> + bx + c = 0> は &math<\sp<b><2> - 4ac = 0> のとき重解をもち･･･。
>
```