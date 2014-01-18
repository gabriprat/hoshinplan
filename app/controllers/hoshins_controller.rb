class HoshinsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  auto_actions_for :company, [:new, :create]
  
  include RestController

end
