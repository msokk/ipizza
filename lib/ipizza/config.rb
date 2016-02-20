require 'yaml'

require './config/configuration_error'
require './config/bank'

module Ipizza
  module Config
    class << self
      attr_accessor :certs_root

      def load_from_file(yaml_path)
        @certs_root = File.dirname(yaml_path)

        @default_config = YAML.load_file(File.expand_path('./config/defaults.yml', __dir__))
        config = YAML::load_file(yaml_path)

        config.reject {|k| k =~ /^common$/ }.each do |bank, params|
          self.singleton_class.class_eval { attr_reader bank }

          bank_params = (@default_config[bank] || {}).merge(params)
          self.instance_variable_set("@#{bank}", Ipizza::Config::Bank.new(bank_params))
        end
      end

      def [](bank)
        self.send(bank)
      end

      def configure
        raise ConfigurationError.new('Configuration is not yet loaded') unless @default_config

        yield self
      end
    end
  end
end
