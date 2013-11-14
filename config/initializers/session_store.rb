# Be sure to restart your server when you modify this file.

# Tawseela::Application.config.session_store :cookie_store, key: '_tawseela_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Tawseela::Application.config.session_store :active_record_store

require 'memcache'
CACHE = MemCache.new({
  :namespace => "tws_#{GIT_HEAD}"
})

CACHE.servers = MEMCACHE_SERVERS[Rails.env]
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      # We're in smart spawning mode.
      CACHE.reset
    end
  end
end

Tawseela::Application.config.session_store :mem_cache_store, key: '_tawseela_session', session_key: '_tawseela_session', :expire_after => 7.days
Tawseela::Application.config.session_options[:cache] = CACHE
