require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PriceComparison
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil
    
    # [lib]以下を読み込み
    config.paths.add 'lib', eager_load: true

    config.before_configuration do
      
      # アプリIDなどの情報を読み込み
      env_file = Rails.root.join("config", 'rakuten_ecs.yml').to_s
      
      # 環境変数に設定
      if File.exists?(env_file)
        rakuten_yml = YAML.load_file(env_file)
        rakuten_yml.each do |key, value|
          ENV[key.to_s] = value
        end
      end
    end
  end
end
