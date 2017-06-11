class SamlProvidersController  < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  def create
    self.this = new_for_create {}
    fail "No company" if  params[:saml_provider]._?[:company_id].blank?
    comp = Company.find(params[:saml_provider][:company_id])
    raise Hobo::PermissionDeniedError unless comp.update_permitted?
    self.this.metadata_xml = params[:metadata_xml].read.to_s
    self.this.email_domain ||= SecureRandom.uuid
    hobo_create
  end

  def update
    self.this = find_instance
    raise Hobo::PermissionDeniedError unless self.this.company.update_permitted?
    self.this.metadata_xml = params[:metadata_xml].read.to_s
    self.this.save!
    update_response
  end

end
