class TasksController < ApplicationController

  hobo_model_controller

  auto_actions :all

  auto_actions_for :objective, [:new, :create]
  
end
