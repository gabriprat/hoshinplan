class CompaniesController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  autocomplete :users do
   render :json => find_instance.users.*.name
  end
  
  include RestController
    
  def first
    hobo_new
  end
  
  def update
    if params[:collaborators]
      error = false
      begin
        params[:collaborators].each_line do |email|
          email.squish! 
          user = User.where(:email_address => email).first
          if user.nil?
            user = User::Lifecycle.invite(:email_address => email)
            user.email_address = email
            user.save!(:validate => false)
          end
          uc = UserCompany.where(:company_id => params[:id], :user_id => user.id).first
          if uc.nil? 
            company = Company.find(params[:id])
            UserCompany::Lifecycle.invite(current_user, {:user => user, :company => company})
          end
        end
        redirect_to Company.find(params[:id]), :action => :edit unless error
        #rescue Exception => e
        #redirect_to Company.find(params[:id]), {:action => :edit, :error => e }
      end
    else
      hobo_update
    end
  end
  

end
