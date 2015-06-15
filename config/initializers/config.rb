CONFIG = YAML.load(ERB.new(File.new("#{::Rails.root}/config/config.yml").read).result).with_indifferent_access[::Rails.env]
