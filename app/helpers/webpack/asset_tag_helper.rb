module Webpack
  module AssetTagHelper
    def webpack_include_tag(bundle, *options)
      built_name = Webpack::Assets[bundle]["js"]
      javascript_include_tag("/assets/webpack/#{built_name}", *options)
    end
  end
end
