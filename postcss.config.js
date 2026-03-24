const purgecssPlugin = require('@fullhuman/postcss-purgecss')

module.exports = {
  plugins: [
    purgecssPlugin({
      content: [
        './layouts/**/*.html',
        './themes/hugo-future-imperfect-slim/layouts/**/*.html',
        './content/**/*.md',
        './static/js/**/*.js',
      ],
      defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || [],
      safelist: {
        // Fancybox が動的に付与するクラスを保持
        patterns: [/^fancybox/, /^is-/, /^has-/, /^fb-/],
      },
    }),
  ],
}
