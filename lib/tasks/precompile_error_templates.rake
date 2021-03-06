require 'fileutils'

namespace :app do
  desc 'Compile the static html error templates.'
  task :precompile_error_templates => :environment do
    pages = {
        '/errors/file_not_found?locale=en' => '404.html',
        '/errors/unprocessable?locale=en' => '422.html',
        '/errors/internal_server_error?locale=en' => '500.html',
        '/errors/service_unavailable?locale=en' => '503.html',
    '/errors/maintenance?locale=en' => 'maintenance.html'
    }
    app = ActionDispatch::Integration::Session.new(Rails.application)

    pages.each do |route, output|
        puts "Generating #{output}..."
        outpath = File.join ([Rails.root, 'public', output])
        Hoshinplan::Application.config.secret_key_base = 'sadf'
        resp = app.get(route)
        if resp == output.to_i || output == 'maintenance.html'
            File.delete(outpath) unless not File.exists?(outpath)
            File.open(outpath, 'w') do |f|
                f.write(app.response.body)
            end
        else
            puts "Error generating #{output}!"
	    puts resp.to_yaml
        end
    end
  end
end
