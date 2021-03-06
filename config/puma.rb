threads_count = Integer(ENV['MAX_THREADS'] || 5)
workers_count = Integer(ENV['WORKERS'] || 0)
threads threads_count, threads_count
workers workers_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Valid on Rails up to 4.1 the initializer method of setting `pool` size
  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['MAX_THREADS'] || 5
    ActiveRecord::Base.establish_connection(config)
  end
  
  ::Oboe.reconnect! if defined?(::Oboe)
end

on_worker_shutdown do
  ::Oboe.disconnect! if defined?(::Oboe)
end