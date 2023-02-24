require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ProjectSasami
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # config.action_view.form_with_generates_remote_form = true

    # User
    config.x.global.name  = "ProjectSasami"
    config.x.global.title = "ProjectSasami"
    config.active_storage.variant_processor = :mini_magick
    config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick]
    config.hosts << "localhost"
    config.hosts << "127.0.0.1"
    #config.hosts << "server_ip" ;# Add your server IP here
    config.puma_ctrl_port  = nil ; # Set a port number if puma control needed
    config.puma_ctrl_token = nil ; # Set a token for puma control if puma_ctrl_port specified
  end
end
