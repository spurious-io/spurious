require 'yaml'

module Spurious
  module Config

    CONFIG_LOCATION = 'config/containers.yaml'

    def self.app
      @@config ||= YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', CONFIG_LOCATION))
    end

  end
end
