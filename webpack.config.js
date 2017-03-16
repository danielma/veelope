const webpack = require("webpack")
const SaveAssetsJson = require("assets-webpack-plugin")
const path = require("path")
const railsRoot = path.join(__dirname, ".")

const config = {
  context: railsRoot,
  entry: "webpack.js",
  output: {
    library: "[name]",
    filename: "[name]-[chunkhash].js",
    path: path.join(railsRoot, "./public/assets/webpack"),
  },
  resolve: {
    root: [
      path.join(railsRoot, "./app/assets/javascripts"),
    ],
    extensions: ["", ".js"],
  },
  module: {
    loaders: [
      {
        test: /\.js?$/,
        exclude: [/node_modules/, /vendor/],
        loader: "babel-loader",
      },
    ],
  },
  cache: true,
  watchDelay: 0,
  devtool: "eval",
  plugins: [],
}

config.plugins.push(new SaveAssetsJson({
  path: config.output.path,
  filename: "manifest.json",
}))

if ("production" === process.env.NODE_ENV) {
  config.plugins.push(
    new webpack.optimize.UglifyJsPlugin({
      compressor: {
        pure_getters: true,
        screw_ie8: true,
        warnings: false,
      },
    }),
    new webpack.DefinePlugin({
      "process.env.NODE_ENV": '"production"',
    })
  )
  config.bail = true
  config.devtool = "source-map"
}

module.exports = config
