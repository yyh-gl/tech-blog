Vue.component('good-counter', {
  template: '<button v-on:click="addCount">\n' +
    '<i class="far fa-thumbs-up"></i> いいね　{{ good_count }}\n' +
    '</button>',
  data: function () {
    return {
      good_count: "-",
    }
  },
  mounted () {
    // URL から記事情報を取得
    let paths = location.pathname.split('/');
    // URL のタイトル部分のみを抽出し、リクエストURL を作成
    let reqUrl = 'https://super.hobigon.work/api/v1/blogs/' + paths[paths.length - 2];

    axios
      .get(reqUrl)
      .then(response => this.good_count = response.data.post.count)
  },
  methods: {
    addCount: function (event) {
      // URL から記事情報を取得
      let paths = location.pathname.split('/');
      // URL のタイトル部分のみを抽出し、リクエストURL を作成
      let reqUrl = 'https://super.hobigon.work/api/v1/blogs/' + paths[paths.length - 2] + '/good';

      if(event) {
        axios
          .post(reqUrl)
          .then(response => this.good_count = response.data.after)
      }
    }
  }
});

// root インスタンスを作成する
new Vue({
  el: '#GoodCounter',
});
