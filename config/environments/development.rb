Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end

PayPal::SDK.configure(
  mode: 'sandbox',
  client_id: 'AbPy-TXRln3F1b3vl52ENa6A8RQe7NHCYCGMAGO6479GINXG4FehZUzHfV5WHe_gl126dfM_c0Wx4ic3',
  client_secret: 'EIHo7p65fWq2CG6FlCWo4bfYNG2P6Xsxw3CZ45G2YGXvVF-B-8NL77fj_Hayl1Jr3wzV7bwgs8EsWDW4',
)
PayPal::SDK.logger = Rails.logger

PAYMENT_PROVIDER = PaymentProvider::PayPalProvider.new
