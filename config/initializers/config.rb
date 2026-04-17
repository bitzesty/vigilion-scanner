config_yaml = ERB.new(File.read(Rails.root.join("config/config.yml"))).result

CONFIG = YAML.safe_load(
  config_yaml,
  aliases: true,
  permitted_classes: [Symbol]
).with_indifferent_access.fetch(Rails.env)
