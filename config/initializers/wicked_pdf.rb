Rails.application.configure do
  config.middleware.use WickedPdf::Middleware, {}, except: [ %r[^/invoice] ]
end

WickedPdf.config = {
  page_size: 'A4',
  print_media_type: true,
  orientation: 'Landscape',
  no_outline: true,
  minimum_font_size: 6,
  exe_path: './vendor/bundle/bin/wkhtmltopdf',
}
