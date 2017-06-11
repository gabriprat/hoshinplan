class SamlProvidersController  < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  def create
    fail "No company" if Company.current_id.blank?
    self.this = new_for_create {}
    self.this.company_id = Company.current_id
    self.this.metadata_xml = params[:metadata_xml].read.to_s
    self.this.email_domain ||= SecureRandom.uuid
    hobo_create
  end

  def update
    self.this = find_instance
    self.this.metadata_xml = params[:metadata_xml].read.to_s
    self.this.save!
    update_response
  end

end
