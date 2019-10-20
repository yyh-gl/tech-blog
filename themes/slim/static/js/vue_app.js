Vue.component('good-counter', {
  template: '<button v-on:click="addCount">\n' +
    '<i class="far fa-thumbs-up"></i> いいね　{{ good_count }}\n' +
    '</button>',
  data: function () {
    return {
      good_count: "-",
      already: false,
    }
  },
  mounted () {
    // URL から記事情報を取得
    let paths = location.pathname.split('/');
    // URL のタイトル部分のみを抽出し、リクエストURL を作成
    let reqUrl = 'https://super.hobigon.work/api/v1/blogs/' + paths[paths.length - 2];

    // いいね済みかどうか判定
    this.already = !!localStorage.getItem(`${paths[paths.length - 2]}`);

    axios
      .get(reqUrl, {
        headers: {
          "Content-Type": "application/json",
        },
        data: {}
      })
      .then(response => {
        this.good_count = response.data.count
      })
  },
  methods: {
    addCount: function (event) {
      // 既にいいね済みの場合はダイアログを出して終了
      if (this.already) {
        alert("いいねありがとうございます！\nただ、あなたは既にいいねされているみたいです😅");
        return
      }

      // URL から記事情報を取得
      let paths = location.pathname.split('/');
      // URL のタイトル部分のみを抽出し、リクエストURL を作成
      let reqUrl = 'https://super.hobigon.work/api/v1/blogs/' + paths[paths.length - 2]+ '/like';

      if(event) {
        axios
          .post(reqUrl)
          .then(response => {
            this.good_count = response.data.count;

            // ローカルストレージにいいねされたことを保存
            localStorage.setItem(`${paths[paths.length - 2]}`, 'like');
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
