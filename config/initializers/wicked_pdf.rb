Rails.application.configure do
  config.middleware.use WickedPdf::Middleware, {}, except: [ %r[^/invoice] ]
end

WickedPdf.config = {
  :page_size => 'A4',
  :print_media_type => true,
  :orientation => 'Landscape'
}

WickedPdf.config[:exe_path] = '/usr/local/bin/wkhtmltopdf' unless Rails.env.production?
