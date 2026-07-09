const purgecssPlugin = require('@fullhuman/postcss-purgecss')

module.exports = {
  plugins: [
    purgecssPlugin({
      content: [
        './layouts/**/*.html',
        './content/**/*.md',
        './static/js/**/*.js',
      ],
      defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || [],
    }),
  ],
}
