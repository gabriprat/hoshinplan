class HoshinsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  auto_actions_for :company, [:new, :create]

end
