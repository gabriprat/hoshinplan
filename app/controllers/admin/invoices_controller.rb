class Admin::InvoicesController  < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  def index
    if params[:search].present?
      @invoices = Hobo.find_by_search(params[:search], [Invoice.unscoped])[User.sage_active_operational_number]
      @invoices ||= Invoice.where('1=0')
    else
      @invoices = Invoice.unscoped.all
    end

    sort = parse_sort_param(:id, :created_at, :description, :net_amount, :tax_tpc, :total_amount, :sage_active_operational_number)
    sort ||= '-id'
    @invoices = @invoices.order_by(sort).paginate(:page => params[:page], :per_page => 15).load
    hobo_index
  end

  def show
    @this = Invoices.unscoped.find(params[:id])
    hobo_show
  end

  def edit
    @this = Invoices.unscoped.find(params[:id])
    hobo_edit
  end

  def update
    @this = Invoices.unscoped.find(params[:id])
    hobo_update
  end

end
