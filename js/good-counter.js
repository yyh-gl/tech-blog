Vue.component('good-counter', {
  props: ['relPermalink'],
  template: '<button v-on:click="addCount" v-bind:disabled="already">' +
    '<span v-html="display_button_name"></span>　{{ good_count }}' +
    '</button>',
  data: function () {
    return {
      display_button_name: '<i class="far fa-heart"></i>',
      good_count: 0,  // いいね数
      already: false, // いいね済みかどうかのフラグ
    }
  },
  mounted () {
    // Props経由で受け取ったPermalink（相対パス）からタイトル情報を取得
    const parts = this.relPermalink.split('/')
    let title = parts[parts.length - 2]
    // いいね数取得リクエストURLを作成
    let reqUrl = 'https://hobigon.yyh-gl.dev/api/v1/blogs/' + title;

    // ページカテゴリー取得（例：me, blog, category など）
    let pageCategory = parts[parts.length - 3]

    // いいね済みかどうか判定
    // （記事詳細画面以外では常にtrue）
    this.already = pageCategory !== "blog" || !!localStorage.getItem(`${title}`);
    if (this.already) {
      this.display_button_name = '<i class="fas fa-heart"></i>';
    }

    axios
      .get(reqUrl, {
        headers: {
          "Content-Type": "application/json",
        },
        data: {}
      })
      .then(response => {
        this.good_count = response.data.count;
      })
  },
  methods: {
    addCount: function (event) {
      if (this.already) {
        return
      }

      // URLから記事情報を取得
      let paths = location.pathname.split('/');
      // URLのタイトル部分のみを抽出
      let title = paths[paths.length - 2]

      // トップ画面ではAPIリクエストを実行しない
      if (!title) return

      // いいね+1リクエストURLを作成
      let reqUrl = 'https://hobigon.yyh-gl.dev/api/v1/blogs/' + title+ '/like';

      if(event) {
        axios
          .post(reqUrl)
          .then(response => {
            this.good_count = response.data.count;

            // ローカルストレージにいいねされたことを保存
            localStorage.setItem(`${title}`, 'like');
            this.already = true;
            this.display_button_name = '<i class="fas fa-heart"></i>';
          })
      }
    }
  }
});

// root インスタンスを作成する
new Vue({
  el: '#site-main',
});
