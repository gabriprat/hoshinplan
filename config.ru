# This file is used by Rack-based servers to start the application.

# --- Start of unicorn worker killer code ---

if ENV['RAILS_ENV'] == 'production' 
  require 'unicorn/worker_killer'

  max_request_min =  ENV['MAX_REQUEST_MIN'].to_i || 3072
  max_request_max =  ENV['MAX_REQUEST_MAX'].to_i || 4096

  # Max requests per worker
  use Unicorn::WorkerKiller::MaxRequests, max_request_min, max_request_max

  oom_min = ((ENV['OOM_MIN'].to_i || 192) * (1024**2))
  oom_max = ((ENV['OOM_MAX'].to_i || 256) * (1024**2))

  # Max memory size (RSS) per worker
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end

# --- End of unicorn worker killer code ---


require ::File.expand_path('../config/environment',  __FILE__)
run Hoshinplan::Application
