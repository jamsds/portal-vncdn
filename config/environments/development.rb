Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # S3 Storage
  config.paperclip_defaults = {
    storage: :s3,
    s3_protocol: 'http',
    s3_credentials: {
      bucket: 'vncdn',
      access_key_id: 'BKIKJAA5BMMU2RHO6IBB',
      secret_access_key: 'V7f1CwQqAcwo80UEIJEjc5gVQUSSx5ohQ9GSrr12',
      s3_region: 'us-east-1',
      s3_host_name: 'http://103.90.220.124'
    },
    s3_options: {
      endpoint: "http://103.90.220.124",
      force_path_style: true
    },
    url: ':s3_host_name'
  }

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Use SMTP to sending mail
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
  :address              => "103.90.220.60",
  :port                 => 25,
  :domain               => "mail.vnetwork.vn",
  :user_name            => "no-reply@vnetwork.vn",
  :password             => "noreply123",
  :authentication       => false,
  :enable_starttls_auto => false }

  config.action_mailer.perform_caching = false

  # Devise Mailer
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { host: 'id.demo.vncdn.vn' }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
