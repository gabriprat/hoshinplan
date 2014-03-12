class HoshinsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new]
  
  auto_actions_for :company, [:new, :create]
  
  include RestController
  
  cache_sweeper :hoshins_sweeper
  

end
