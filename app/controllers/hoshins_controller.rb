class HoshinsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index]
  
  auto_actions_for :company, [:new, :create]
  
  include RestController
  
  cache_sweeper :hoshins_sweeper
  
  def create
    if params["new-company-name"]
      company = Company.new
      company.name = params["new-company-name"]
      company.save!
      params["hoshin"]["company_id"] = company.id
    end
    hobo_create
  end

end
