module Webpack
  class Assets
    class NotPrecompiledError < RuntimeError; end
    class NotFoundError < RuntimeError; end

    class_attribute :_entries
    class_attribute :_loaded

    self._entries = Hash.new do |hash, entry|
      fail NotFoundError, "Unknown webpack entry: '#{entry}', the named entries from the generated 'manifest.json' are: #{hash.keys}. If you recently added this entry, you will need to restart the rails application."
    end

    def self.[](entry)
      return "" unless use_assets?

      unless _loaded
        load
        self._loaded = cache_entries?
      end

      _entries[entry]
    end

    def self.load
      unless File.exist?(webpack_entries_manifest_fullpath)
        fail NotPrecompiledError, "The webpack entries manifest doesn't exist. (Run webpack)"
      end

      self._entries = _entries.clear.merge(JSON.load(webpack_entries_manifest_fullpath))
    end

    def self.webpack_entries_manifest_fullpath
      Rails.root.join("public/assets/webpack/manifest.json")
    end

    def self.cache_entries?
      Rails.env.production? || Rails.env.staging?
    end

    def self.use_assets?
      !Rails.env.test?
    end
  end
end
