# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if defined?(PhusionPassenger)
  PhusionPassenger.advertised_concurrency_level = 0
end

run Hoshinplan::Application
