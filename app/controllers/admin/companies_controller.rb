class Admin::CompaniesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  autocomplete :name

  def index
    if params[:search].present?
      @companies = Hobo.find_by_search(params[:search], [Company.unscoped])[Company.name]
      @companies ||= Company.where('1=0')
    else
      @companies = Company.unscoped.all
    end

    sort = parse_sort_param(:name, :creator_id, :creator, :unlimited, :company_email_domains, :trial_ends_at, :credit, :payment_error, :subscriptions_count, :minimum_subscription_users, :partner, :partner_id)
    sort ||= '-id'
    @companies = @companies.order_by(sort).paginate(:page => params[:page], :per_page => 15).load
    hobo_index
  end

end
