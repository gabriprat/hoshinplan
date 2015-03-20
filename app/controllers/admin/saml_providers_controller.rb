class Admin::SamlProvidersController  < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all
  
  def create
    self.this = new_for_create {}
    self.this.metadata_xml = params[:metadata_xml].read.to_s
    hobo_create
  end

end
