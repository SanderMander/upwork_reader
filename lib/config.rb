require 'yaml'

class Config
  PARSED_YAML = YAML.load File.open(ARGV.size == 1 ? ARGV[0] : 'config.yml')
  class << self
    PARSED_YAML.each do |key, value|
      define_method key do
        value
      end
    end

    def method_missing(name)
      Config.config[name.to_s]
    end
  end
end
