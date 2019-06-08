Vue.component('good-counter', {
  template: '<button onclick="">\n' +
    '<i class="far fa-thumbs-up"></i> いいね　{{ good_count }}\n' +
    '</button>',
  data: function () {
    return {
      good_count: 9999
    }
  },
});

// root インスタンスを作成する
new Vue({
  el: '#GoodCounter',
});
