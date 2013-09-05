APP_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]

puts "APP_CONFIG: " + APP_CONFIG.to_json
