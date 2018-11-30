class Admin::SubscriptionsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :index, :edit, :destroy, :update, :show, :new, :create

  autocomplete :user do
    ret = []
    users = User.unscoped.each { |user|
      ret << user.name.to_s + " (" + user.email_address.to_s + ")"
    }
    render :json => ret
  end

  autocomplete :company do
    ret = []
    companies = Company.unscoped.each { |c|
      ret << c.name.to_s + " (" + c.id.to_s + ")"
    }
    render :json => ret
  end

  def show
    @this = Subscription.unscoped.find(params[:id])
    hobo_show
  end

  def edit
    @this = Subscription.unscoped.find(params[:id])
    hobo_edit
  end

  def update
    @this = Subscription.unscoped.find(params[:id])
    hobo_update
  end

  def index
    if params[:search].present?
      begin
        bdIds = Hobo.find_by_search(params[:search], [BillingDetail.unscoped])[BillingDetail.name].*.id
        @subscriptions = Subscription.where(billing_detail_id: bdIds)
      rescue
      end
      @subscriptions ||= Subscription.where('1=0')
    else
      @subscriptions = Subscription.unscoped.all
    end

    sort = parse_sort_param(:status, :plan_name, :id, :created_at, :amount_value, :monthly_value, :last_payment_at, :next_payment_at, :per_user, :status)
    sort ||= 'status, next_payment_at'
    @subscriptions = @subscriptions.order_by(sort).paginate(:page => params[:page], :per_page => 15).load
    hobo_index
  end

end