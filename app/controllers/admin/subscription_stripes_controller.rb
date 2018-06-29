class Admin::SubscriptionStripesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :edit, :destroy, :update, :show, :new, :create

  def show
    @this = SubscriptionStripe.unscoped.find(params[:id])
    hobo_show
  end

  def edit
    @this = SubscriptionStripe.unscoped.find(params[:id])
    hobo_edit
  end

  def update
    @this = SubscriptionStripe.unscoped.find(params[:id])
    hobo_update
  end

end