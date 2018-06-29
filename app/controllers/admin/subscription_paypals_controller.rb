class Admin::SubscriptionPaypalsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :edit, :destroy, :update, :show, :new, :create

  def show
    @this = SubscriptionPaypal.unscoped.find(params[:id])
    hobo_show
  end

  def edit
    @this = SubscriptionPaypal.unscoped.find(params[:id])
    hobo_edit
  end

  def update
    @this = SubscriptionPaypal.unscoped.find(params[:id])
    hobo_update
  end

end