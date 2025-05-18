+++
title = "JavaのIntegerクラスがキャッシュする範囲"
author = "yyh-gl"
categories = ["Java"]
tags = ["Tech"]
date = 2025-05-18T22:30:08+09:00
description = "-128~127の範囲とは限らない"
type = "post"
draft = false
[[images]]
  src = "img/2025/05/java-integer-cache/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

# JavaのIntegerクラスにキャッシュがあることを知る

JetBrains公式アカウントで以下のクイズがポストされていた。<br>
解答の中に以下のツイートを発見。

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Not equal because they are greater than 127. 127 and below would use the integer cache and then they would be equal</p>&mdash; Simon Martinelli (@simas_ch) <a href="https://twitter.com/simas_ch/status/1923728106193322326?ref_src=twsrc%5Etfw">May 17, 2025</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

"Integer cache"なるものがあることを知る。

# Integerクラスのキャッシュとは

[ドキュメント](https://docs.oracle.com/en/java/javase/24/docs/api/java.base/java/lang/Integer.html#valueOf(int))
を見てみる。<br>
（Javaバージョン: 24）

<img src="https://tech.yyh-gl.dev/img/2025/05/java-integer-cache/docs.webp" width="600">

> This method will always cache values in the range -128 to 127, inclusive

-128~127の範囲は常にキャッシュされるとのこと。

> and may cache other values outside of this range.

ただし、範囲は-128~127ではないときもあるらしい。<br>
どういうときに範囲が変わるのか気になったので調べた↓

# キャッシュ範囲を深ぼる

[コード](https://github.com/openjdk/jdk/blob/jdk-24%2B36/src/java.base/share/classes/java/lang/Integer.java#L940-L953)
を見てみると以下のとおりだった。

```java
// high value may be configured by property
int h = 127;
String integerCacheHighPropValue =
    VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
if (integerCacheHighPropValue != null) {
    try {
        h = Math.max(parseInt(integerCacheHighPropValue), 127);
        // Maximum array size is Integer.MAX_VALUE
        h = Math.min(h, Integer.MAX_VALUE - (-low) -1);
    } catch( NumberFormatException nfe) {
        // If the property cannot be parsed into an int, ignore it.
    }
}
high = h;
```

`java.lang.Integer.IntegerCache.high`というプロパティで、
キャッシュ範囲の上限値だけは変更できる。

# 結論

Integerクラスのキャッシュ範囲は以下のとおり。

- デフォルトでは-128～127の範囲の値をキャッシュ
- `java.lang.Integer.IntegerCache.high`プロパティを設定することで、上限値（`high`）を127より大きい値に変更可能
- 下限値（`low`）は常に-128

このキャッシュ機構を理解しておくことで、
パフォーマンスだけでなくIntegerクラスの同一性（`==`による比較結果）の挙動についても正しく理解できる。
