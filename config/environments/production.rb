Caball::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # config.middleware.use Rack::Auth::Basic, "Beta Access" do |username, password|
  #   'secret' == password
  # end

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = false

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "https://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com"
  # Development Cloudfront
  # config.action_controller.asset_host = "d1stg2u3ujiznp.cloudfront.net"
  # Production Cloudfront
  config.action_controller.asset_host =  "d3udb5q56169ms.cloudfront.net"
  # config.action_controller.asset_host = "cdn.filmzu.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)

  # Old Assets from Previous Site (Good list to start when I do the JS CSS cleanup)
  # config.assets.precompile += %w( admin/admin.css admin/*.js conversations/new.css users/users_manifest.js dashboard/dashboard.css dashboard/dashboard_manifest.js users/users.js signup.css signin.css
  #                               events_manifest.js events/manifest.css events/event_index.css events/events_manifest.js home_page.css
  #                               users/user_index.css application.js
  #                               projects/projects_manifest.js projects/manifest.css users/user_search.js projects/project_index.css
  #                               static_pages/our_story.css
  #                               users/users_manifest.js users/manifest.css users/show.css contact.js glossary.js static_pages/labs.css dashboard/introjs.css dashboard/intro.js)

  config.assets.precompile += %w(jquery-1.9.0.js jquery.min.js jquery.poptrox.min.js jquery-migrate-1.2.1.js jquery.fancybox.js jquery.colorbox.js jquery.uniform.js bootstrap.min.js waypoints.min.js
                                  effects.js style.css uniform.default.css step-slider.css colorbox.css bootstrap.min.css jquery.fancybox.css html5shiv.js respond.min.js animate.css jquery-ui.js
                                   jquery-ui-slider-pips.js jquery-ui-slider-pips.min.js draggable-0.1.js jquery.dependClass-0.1.js jquery.numberformatter-1.2.3.js tmpl.js respond.min.js jshashtable-2.1_src.js jquery-ui.css
                                   jquery_ui_slide_pips.css jslider.css jquery.slider.js caball.js prettify.js jquery_ujs.js project.css bootstrap-tagsinput.js bootstrap-tagsinput.css social-likes.min.js social-likes_flat.css
                                   bootstrap-slider.js balanced-1.1.js jquery.geocomplete.js select2.js select2.css projects_proposal.js jquery.compare.min.js active_admin.js alert.js active_admin.css.scss social-share-button.js static_pages/static_pages.css custom_select.css proposals.js proposals.css app.js popup.js)

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Change mail delvery to either :smtp, :sendmail, :file, :test
  config.action_mailer.delivery_method = :smtp

  ActionMailer::Base.smtp_settings = {
                     :address        => "smtp.gmail.com",
                     :port           => 587,
                     :authentication => :plain,
                     :user_name      => "notifications@filmzu.com",
                     :password       => "TheFilmzu1912",
                     :openssl_verify_mode  => 'none'
   }

  # Change when Push to the Website or will Error out
  # config.action_mailer.default_url_options = { :host => 'filmzu.com' }
  # config.action_mailer.default_url_options = { :host => 'development.filmzu.com' }
  config.action_mailer.default_url_options = { :host => 'filmzu-production-dcerm4y6yv.elasticbeanstalk.com/' }

  # Set EmberJS Variant
  config.ember.variant = :production

end
