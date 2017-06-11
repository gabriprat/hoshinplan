prawn_document do |pdf|
  @invoice.render_pdf(pdf)
end