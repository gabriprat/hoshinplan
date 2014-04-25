class AreasController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new]
  
  include RestController
  
  cache_sweeper :areas_sweeper
  
  
end
