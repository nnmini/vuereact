const path = require('path');
const { VueLoaderPlugin } = require('vue-loader');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: {
    main: './src/index.js',
  },
  output: {
    filename: '[name].bundle.js', // This should generate main.bundle.js
    chunkFilename: '[name].bundle.js', // Dynamic naming for additional chunks
    path: path.resolve(__dirname, 'public'),
    publicPath: '/', // Ensure this is set correctly
    library: {
      name: '@my-app', // Ensure this matches the module name
      type: 'umd', // Universal Module Definition
    },
  },
  resolve: {
    extensions: ['.js', '.jsx', '.vue'],
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
      },
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: 'babel-loader',
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  plugins: [
    new VueLoaderPlugin(),
    new HtmlWebpackPlugin({
      template: './public/index.html',
    }),
  ],
  devServer: {
    historyApiFallback: true,
    static: path.join(__dirname, 'public'), // Ensure this is set correctly
    port: 8080,
  },
  optimization: {
    splitChunks: {
      chunks: 'all',
      // Optionally, customize the chunk naming strategy
      cacheGroups: {
        vendors: {
          test: /[\\/]node_modules[\\/]/,
          name(module) {
            // Get the name. E.g., node_modules/packageName
            const packageName = module.context.match(
              /[\\/]node_modules[\\/](.*?)([\\/]|$)/
            )[1];
            // NPM package names are URL-safe, but some servers don't like @ symbols
            return `vendors_${packageName.replace('@', '')}`;
          },
          chunks: 'all',
        },
      },
    },
  },
};