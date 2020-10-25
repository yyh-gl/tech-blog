Vue.component('good-counter', {
  template: '<button v-on:click="addCount" v-bind:disabled="already">\n' +
    '<i class="far fa-thumbs-up"></i> いいね{{ this.already ? "済み" : ""}}　{{ good_count }}\n' +
    '</button>',
  data: function () {
    return {
      good_count: "-", // いいね数
      already: false,  // いいね済みかどうかのフラグ
    }
  },
  mounted () {
    // URLから記事情報を取得
    let paths = location.pathname.split('/');
    // ページカテゴリー取得（例：blog, about など）
    let page_category = paths[paths.length - 3]
    // URLのタイトル部分のみを抽出
    let title = paths[paths.length - 2]

    // blogページ&&titleの指定がある場合にのみいいね数を取得
    if (page_category !== 'blog') {
      return
    }
    
    // いいね数取得リクエストURLを作成
    let reqUrl = 'https://super.hobigon.work/api/v1/blogs/' + title;

    // いいね済みかどうか判定
    this.already = !!localStorage.getItem(`${title}`);

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
      // いいね+1リクエストURLを作成
      let reqUrl = 'https://super.hobigon.work/api/v1/blogs/' + title+ '/like';

      if(event) {
        axios
          .post(reqUrl)
          .then(response => {
            this.good_count = response.data.count;

            // ローカルストレージにいいねされたことを保存
            localStorage.setItem(`${title}`, 'like');
            this.already = true;
          })
      }
    }
  }
});

// root インスタンスを作成する
new Vue({
  el: '#GoodCounter',
});
