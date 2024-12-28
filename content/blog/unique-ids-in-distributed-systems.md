<!-- textlint-disable -->

+++
title = "分散システムにおけるID採番の勉強メモ"
author = "yyh-gl"
categories = ["分散システム", "勉強メモ"]
tags = ["Tech"]
date = 2024-12-28T20:08:33+09:00
description = ""
type = "post"
draft = true
[[images]]
  src = "img/2024/12/unique-ids-in-distributed-systems/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

<!-- textlint-enable -->

# はじめに

 分散システムにおいて重複しないID採番方法について気になったので調べたときのメモ。<br>
調査の中で興味出たのがSnowflakeだったので、ほぼSnowflakeの話。

# Snowflake

分散システムにおけるID採番方式として有名なもののひとつ。<br>
https://en.wikipedia.org/wiki/Snowflake_ID

64bitで構成されている。<br>
<img src="https://tech.yyh-gl.dev/img/2024/12/unique-ids-in-distributed-systems/format.webp" width="600">
<br>
（参照： https://en.wikipedia.org/wiki/Snowflake_ID ）

基本的に、上記のフォーマットで生成されたバイナリは10進数の数値に変換される。<br>
timestampを含むので、時刻情報に基づいたソートが可能。<br>
高い衝突体制を持つ。

<!-- textlint-disable ja-technical-writing/no-doubled-joshi -->
<!-- textlint-disable ja-technical-writing/sentence-length -->

timestampを含んでいることからも分かるとおり、SnowflakeはSystem Clockに依存している。<br>
よって、時間が巻き戻ったりするとIDが重複する可能性がある。<br>
ただし、時刻が巻き戻った場合にはID生成をストップする機構が組み込まれている。<br>
（最後に生成したIDが示す時刻を超えるまで生成ストップ）<br>
https://github.com/twitter-archive/snowflake/tree/snowflake-2010?tab=readme-ov-file#system-clock-dependency

<!-- textlint-enable ja-technical-writing/no-doubled-joshi -->
<!-- textlint-enable ja-technical-writing/sentence-length -->

Xでも使われている（[参考](https://developer.x.com/ja/docs/basics/twitter-ids)）。<br>
現行のコードではないもののコードは[こちら](https://github.com/twitter-archive/snowflake/tree/snowflake-2010)。<br>
今使われているのはSnowflakeの進化系？<br>
> The Snowflake we're using internally is a full rewrite and heavily relies on existing infrastructure at Twitter to run.

# Snowflakeとよく比較される対象

- UUID
- ULID
