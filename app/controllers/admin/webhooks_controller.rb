class Admin::WebhooksController  < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  autocomplete :company do
    ret = []
    companies = Company.unscoped.each { |c|
      ret << c.name.to_s + " (" + c.id.to_s + ")"
    }
    render :json => ret
  end

  def create
    if params[:webhook][:company].present?
      params[:webhook][:company_id] = params[:webhook][:company].match(/(\d+)\)$/)[1].to_i
      params[:webhook].delete(:company)
    end
    hobo_create
  end

  def update
    if params[:webhook][:company].present?
      params[:webhook][:company_id] = params[:webhook][:company].match(/(\d+)\)$/)[1].to_i
      params[:webhook].delete(:company)
    end
    hobo_update
  end
end
