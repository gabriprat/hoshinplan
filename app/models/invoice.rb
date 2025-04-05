class Invoice < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper

  hobo_model # Don't put anything above this

  fields do
    sage_one_invoice_id :string
    sage_active_invoice_id :string
    sage_active_operational_number :string, :unique, :index => true
    description :string, :required
    net_amount :decimal, :required, :precision => 8, :scale => 2
    tax_tpc :decimal, :required, :precision => 8, :scale => 2
    total_amount :decimal, :required, :precision => 8, :scale => 2
    timestamps
  end
  attr_accessible :id, :created_at, :description, :net_amount, :tax_tpc, :total_amount, :sage_active_invoice_id, :sage_one_invoice_id,
                  :billing_detail_id, :subscription_id, :sage_active_operational_number

  belongs_to :subscription, :inverse_of => :invoices
  belongs_to :billing_detail, :inverse_of => :invoices

  default_scope lambda {
    joins(:subscription)
  }

  def render_pdf(pdf)
    subscription = Subscription.unscoped.find(self.subscription_id)
    billing_detail = BillingDetail.unscoped.find(subscription.billing_detail)
    pdf.font "Helvetica"

    # Defining the grid
    # See http://prawn.majesticseacreature.com/manual.pdf
    pdf.define_grid(:columns => 5, :rows => 8, :gutter => 10)

    pdf.grid([0, 3.6], [1, 4]).bounding_box do
      pdf.text "Factura", :size => 16, :style => :bold, :color => "b9d9fd", :align => :right
      pdf.move_down 5
      pdf.text "<b>Fecha de factura</b> #{self.created_at.strftime('%d/%m/%Y')}", size: 9, align: :right, :inline_format => true
      pdf.text "<b>Plazo</b> #{(self.created_at.to_date >> 1).strftime('%d/%m/%Y')}", size: 9, align: :right, :inline_format => true
      pdf.text "<b>Su NIF</b> #{billing_detail.country} #{billing_detail.vat_number}", size: 9, align: :right, :inline_format => true
      pdf.text "<b>Código del cliente</b> HP-#{billing_detail.id}", size: 9, align: :right, :inline_format => true
      pdf.text "<b>Número de factura</b> #{self.sage_one_invoice_id}", size: 9, align: :right, :inline_format => true
    end

    pdf.grid([0, 0], [1, 1]).bounding_box do
      # Assign the path to your file name first to a local variable.
      logo_path = File.expand_path('../../../public/assets/hp-logo-wide.png', __FILE__)

      # Displays the image in your PDF. Dimensions are optional.
      pdf.image logo_path, :width => 147, :height => 45.75, :position => :left

      # Company address
      pdf.move_down 67
      pdf.text "Hoshinplan Strategy S.L.", size: 14.4, style: :bold, align: :left
      pdf.text "Sant Francesc, 4", size: 9, align: :left
      pdf.text "Cerdanyola del Vallès, 08320", size: 9, :align => :left
      pdf.move_down 5
      pdf.text "NIF ES B66985110", size: 9, :align => :left
      pdf.move_down 5
      pdf.text "hello@hoshinplan.com", size: 9, :align => :left
    end

    pdf.grid([1.2, 2.2], [1.4, 4]).bounding_box do
      pdf.stroke_color 'dddddd'
      pdf.line_width(0.5)
      pdf.dash 2, space: 1
      pdf.stroke_bounds
      pdf.undash
      pdf.stroke_color '000000'
      pdf.move_down 20
      pdf.indent(20) do
        pdf.text billing_detail.contact_name, style: :bold, size: 9, align: :left
        pdf.text billing_detail.company_name, size: 9, align: :left
        pdf.text billing_detail.address_line_1, size: 9, align: :left
        pdf.text billing_detail.address_line_2, size: 9, align: :left unless billing_detail.address_line_2.blank?
        pdf.text billing_detail.state, size: 9, align: :left
        pdf.text "#{billing_detail.zip} #{billing_detail.city}", size: 9, align: :left
      end
    end

    pdf.move_down 20
    items = [["Descripción", "Cant./Horas ", "Precio/unidad", "IVA %", "Base Imponible"]]
    items <<
        [
            self.description,
            number_with_precision(1, precision: 2, strip_insignificant_zeros: false),
            number_with_precision(self.net_amount, precision: 2, strip_insignificant_zeros: false),
            number_with_precision(self.tax_tpc, precision: 2, strip_insignificant_zeros: false),
            number_with_precision(self.net_amount, precision: 2, strip_insignificant_zeros: false),
        ]

    pdf.table items, :header => true,
              :width => 525,
              :column_widths => {1 => 60, 2 => 60, 3 => 30, 4 => 70}, :row_colors => ["FFFFFF"],
              :cell_style => {:borders => [:bottom], :border_width => 0.5, :size => 7.2} do
      style(columns([1, 2, 3, 4])) {|x| x.align = :right}
      style(rows(0)) {|x| x.border_color = 'b9d9fd'; x.font_style = :bold;}
      style(rows(1)) {|x| x.border_color = 'e2e3e5'; x.border_width = 1; x.height = 25; x.padding_top = 7.5;}
    end


    pdf.move_down 40

    pdf.grid([3.15, 0], [4, 1]).bounding_box do
      pdf.text "Notas", style: :bold, size: 9
      pdf.text "IBAN: ES69 0081 0056 9600 0229 2137", size: 7.5
      pdf.text "(SWIFT/BIC: BSABESBB) BANCO DE SABADELL, S.A.", size: 7.5
    end


    pdf.grid([3.15, 3.1], [4, 4]).bounding_box do

      items = [
          ["General #{self.tax_tpc}% - #{self.net_amount}", number_with_precision(self.net_amount * self.tax_tpc / 100.0, precision: 2, strip_insignificant_zeros: false)],
          ["Base imponible", number_with_precision(self.net_amount, precision: 2, strip_insignificant_zeros: false)],
          ["Importe de IVA", number_with_precision(self.net_amount * self.tax_tpc / 100.0, precision: 2, strip_insignificant_zeros: false)],
          ["Total", number_with_precision(self.total_amount, precision: 2, strip_insignificant_zeros: false) + ' €'],
          ["Importe pagado", number_with_precision(self.total_amount, precision: 2, strip_insignificant_zeros: false) + ' €'],
          ["Cantidad a pagar", number_with_precision(0, precision: 2, strip_insignificant_zeros: false) + ' €'],
      ]


      pdf.table items, :header => false,
                :column_widths => {0 => 122, 1 => 70}, :row_colors => ["FFFFFF"],
                :cell_style => {:borders => [], :border_width => 0.5, :size => 9, :align => :right, :font_style => :bold} do
        style(columns(1)) {|x| x.font_style = :normal;}
        style(rows(0)) {|x| x.borders = [:bottom]; x.border_color = 'e2e3e5'; x.font_style = :normal;}
        style(rows(3)) {|x| x.background_color = 'b9d9fd'; x.height = 30; x.font_style = :bold; x.padding_top = 9;}
      end
    end

    pdf.bounding_box([pdf.bounds.right - 20, pdf.bounds.bottom], :width => 60, :height => 20) do
      pdf.number_pages "<page> de <total>", size: 9
    end
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
