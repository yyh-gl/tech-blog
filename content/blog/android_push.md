+++
author = "yyh-gl"
categories = ["Android", "Kotlin", "Firebase"]
date = "2019-05-30"
description = ""
title = "【Android + Kotlin + Firebase】Androidアプリにプッシュ通知を実装してみた"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/05/android_push/featured.png"
  alt = "featured"
  stretch = "stretchH"
+++


僕がひっかかった場所は 「つまづきポイント」 という章にまとめているので

なにか困ったときはそこを一度見てみてください。

# tl;dr
- Firebase使ってAndroidアプリにプッシュ通知を実装した
- フォアグラウンドとバックグラウンドで表示方法が異なる
- めちゃくちゃ簡単


# 開発環境
- macOS Mojave 10.14.4
- Android Studio 3.4.1
- Gradle 3.4.1
- Java 1.8.0_202
- Kotlin 1.3.21


# Firebaseに登録
Firebaseを使用するためには登録が必要です。

Googleアカウントを持っている方なら[公式サイト](https://firebase.google.com/?hl=ja)から簡単に登録できます


# Firebaseにプロジェクト作成
[プロジェクト登録ページ](https://console.firebase.google.com/)でプロジェクトを登録します。

プロジェクト名は特に指定はありません。ご自由にどうぞ。


# アプリ情報を登録する
プロジェクト選択後のホーム画面より 「Project Overview」 をクリック。

画面の指示に従って進めていてください。


## デバッグ用の署名証明書 SHA-1 の取得方法

1. 以下コマンドを実行

    Mac/Linux
    ```
    keytool -list -v \
    -alias androiddebugkey -keystore ~/.android/debug.keystore
    ```

    Windows
    ```
    keytool -list -v \
    -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore
    ```

1. パスワード入力

    パスワードは `android` です。

1. 表示される SHA-1 をメモ


<br>

---

ひととおり作業が進むと、↓このような画面が表示されます。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/android_push/app-registering-complete.png" width="750">

自分の環境では、登録したアプリがFirebaseと通信できているかのチェックに少し時間がかかりました。


エミュレータでもちゃんと通信してくれるか不安だったのですが大丈夫でした。


# Firebase 関連のライブラリを追加
アプリ情報の登録工程において、 `app/build.gradle` を触ったと思いますが、加えて、以下の追記が必要です。


```gradle
dependencies {
    // ... 省略

    implementation 'com.google.firebase:firebase-messaging:18.0.0'
}
```

バージョン17.1.0 以降に関して、 [こちらの記事](https://qiita.com/taki4227/items/9d292c3badd2c4015061)にあるとおり、大きな変更が加わっています。

注意しましょう。

# 通知時の見た目の設定（バックグラウンド動作時）
<u>PUSH通知の見た目はバックグラウンドとフォアグラウンドで違います。</u>

フォアグラウンドでのPUSH通知は自分のアプリの処理を通りますが、

バックグラウンドではアプリで定義した処理を通りません。


<br>

まずはバックグラウンドの見た目を設定していきます。

`AndroidManifest.xml` に下記のとおり追記してください。


```xml
<application
    // ... 省略

>

    // ... 省略

    <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="@string/channel_id"/>

    <meta-data
      android:name="com.google.firebase.messaging.default_notification_icon"
      android:resource="@drawable/ic_logo" />

    <meta-data
      android:name="com.google.firebase.messaging.default_notification_color"
      android:resource="@color/background" />
      
    // ... 省略
```

ここでチャンネルIDと通知アイコン、色を決定します。

各自で自由に設定してください。

> チャンネルID は Android 8.0（API レベル 26）以降で設定が必須となりました。

> チャンネルを指定することで、ユーザーが任意の通知チャンネルを無効にすることが可能になります。

> [参考サイト](https://developer.android.com/guide/topics/ui/notifiers/notifications#ManageChannels)

> ★ Android 8.0 未満であれば気にしなくて大丈夫です。

# 動作テスト
以上でバックグラウンドでの通知は受け取れるようになりました。

Cloud Messaging 画面に行き、「Send your first message」から通知を作成します。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/android_push/send_notification.png" width="750">

<br>

1. 通知のタイトルとメッセージを設定します。

    <img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/android_push/create_message.png" width="750">

1. ターゲットは自分のアプリを選択してください。

1. スケジュールは `Now` です。

1. 今回はコンバージョンイベントはなにも触りません。

1. その他のオプションはチャンネルIDだけ設定します（Android8.0以上の人のみ）

     <img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/android_push/other_option.png" width="750">

1. 「確認」 > 「公開」 で通知が送られます。


Android側で通知を受け取れているか確認しましょう。

注意としては、現状バックグラウンドでの処理しか記述していないので

アプリを開いていると通知を受け取れません。

アプリを閉じた状態で通知を送りましょう。

すると…

通知が来ましたね！ 音もついています。

<div style="display:inline-block">
    <img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/android_push/top.png" width="250">

    <img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/android_push/bar.png" width="250">
    
    <img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/android_push/notification_center.png" width="250">
</div>

ステータスバーにもアイコンが表示されています（鳥のマークです）。

でも、アプリ立ち上げた状態（フォアグラウンド）だと通知来ないですよね？

表示できるようにしていきましょう。

# 通知時の見た目の設定（フォアグラウンド動作時）
各自の適当な場所に以下の Service を作成してください。

```kotlin
package <パッケージ名>

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationCompat.PRIORITY_MAX
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import java.util.*

class PushNotificationListenerService: FirebaseMessagingService() {

  // 新しいトークンが生成された時の処理
  // 中でサーバにトークンを送信する処理などを定義
  override fun onNewToken(p0: String?) {
    super.onNewToken(p0)

    // チャンネルidを設定
    addChannelId()
  }

  // 通知を受信したときの処理
  override fun onMessageReceived(message: RemoteMessage?) {
    super.onMessageReceived(message)

    // 今回は通知からタイトルと本文を取得
    val title: String = message?.notification?.title.toString()
    val text: String = message?.notification?.body.toString()

    // 通知表示
    sendNotification(title, text)
  }

  // 通知表示 および 見た目の設定
  private fun sendNotification(title: String, text: String) {
    // 通知タップ時に遷移するアクティビティを指定
    val intent = Intent(this, AllTimelineActivity::class.java)
    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
    // 何度も遷移しないようにする（1度だけ！）
    val pendingIntent: PendingIntent = PendingIntent.getActivity(this,0, intent, PendingIntent.FLAG_ONE_SHOT)

    // 通知メッセージのスタイルを設定（改行表示に対応）
    val inboxStyle = NotificationCompat.InboxStyle()
    val messageArray: List<String> = text.split("\n")
    for (msg: String in messageArray) {
      inboxStyle.addLine(msg)
    }

    // 通知音の設定
    val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

    // 通知の見た目を設定
    val notificationBuilder
      = NotificationCompat.Builder(this, resources.getString(R.string.channel_id))
      .setContentTitle(title)
      .setContentText(text)
      // ステータスバーに表示されるアイコン
      .setSmallIcon(R.drawable.ic_notification_icon)
      // 上で設定したpendingIntentを設定
      .setContentIntent(pendingIntent)
      // 優先度を最大化
      .setPriority(PRIORITY_MAX)
      // 通知音を出すように設定
      .setSound(defaultSoundUri)

    // 通知を実施
    // UUIDを付与することで各通知をユニーク化
    val notificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    val uuid = UUID.randomUUID().hashCode()
    notificationManager.notify(uuid, notificationBuilder.build())

    // Android 8.0 以上はチャンネル設定 必須
    // strings.xml に channel_id を指定してください
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      notificationBuilder.setChannelId(resources.getString(R.string.channel_id))
    }
  }

  // チャンネルの設定
  private fun addChannelId() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
      // ヘッドアップ通知を出す場合はチャンネルの重要度を最大にする必要がある
      val channel = NotificationChannel(
        resources.getString(R.string.channel_id),
        resources.getString(R.string.channel_name),
        NotificationManager.IMPORTANCE_HIGH
      )

      // ロック画面における表示レベル
      channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
      // チャンネル登録
      manager.createNotificationChannel(channel)
    }
  }
}
```

上記コードは [本サイト](https://www.villness.com/2363) を参考にしました。

古いバージョンの情報部分を書き換えたりしています。


# AndroidManifest を修正
↑で実装した Service をマニフェストに登録し、使えるようにします。


`AndroidManifest.xml` に以下の設定を追記します。

```xml
<application
    // ... 省略
    >

    <service
      android:name=".PushNotificationListenerService">
      <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
      </intent-filter>
    </service>
    
    // ... 省略
</application>
```

`android:name` は各自のディレクトリ構成とファイル名に合わせて変更してください。


# 動作テスト
以上でフォアグラウンドにおける通知の設定が完了しました。

通知を受け取れるかテストしてみましょう。

バックグラウンドでのテストと同様の手順で Cloud Messaging から通知を送ります。

すると…


<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/android_push/foreground.png" width="280">

無事表示できましたね！

ステータスバーにもアイコンが出ています。

> アプリ画面は見せれないので隠しています

> ちょっとフォアグラウンドなのか分かりづらいと思いますが、 <u>フォアグラウンドです</u>。


# つまづきポイント
バックグラウンドとフォアグラウンドどちらにおいても、通知がうまく表示されないときがありました。

具体的には

1. そもそも通知がこない
2. フォアグラウンドにて画面上部から通知がぴこって出てこない

などです。

原因ですが、僕の結論は <u>エミュレータでテストしていたこと</u> です。

エミュレータで通知を受け取れない状況において、実機でも通知を受け取ってみたところ、

実機では正常に通知を受け取ることができました。

みなさんもエミュレータでテストするさいはお気をつけください。

（それにしてもなんで無理だったんだろうか… また調べてみよう）


# まとめ
PUSH通知実装いかかがだったでしょうか？

僕的にはとても簡単で驚きしかありませんでした。

Firebaseさまさまですね。

実際の業務に使えるかと言われると、また話が違ってくるのかもしれませんが、、、







# 参考サイト
- [公式ドキュメント](https://firebase.google.com/docs/cloud-messaging?hl=ja)
- [【Android】FCMを使ったpush通知の実装方法 - 株式会社Villness（ヴィルネス）](https://www.villness.com/2363)


