class Admin::BillingDetailsController  < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  def index
    if params[:search].present?
      @billing_details = Hobo.find_by_search(params[:search], [BillingDetail.unscoped])[BillingDetail.company_name]
      @billing_details ||= BillingDetail.where('1=0')
    else
      @billing_details = BillingDetail.unscoped.all
    end

    sort = parse_sort_param(:id, :created_at, :description, :net_amount, :tax_tpc, :total_amount, :sage_active_operational_number)
    sort ||= '-id'
    @billing_details = @billing_details.order_by(sort).paginate(:page => params[:page], :per_page => 15).load
    hobo_index
  end

  def show
    @this = BillingDetail.unscoped.find(params[:id])
    hobo_show
  end

  def edit
    @this = BillingDetail.unscoped.find(params[:id])
    hobo_edit
  end

  def update
    @this = BillingDetail.unscoped.find(params[:id])
    hobo_update
  end

end
