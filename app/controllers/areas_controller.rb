class AreasController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :hoshin, [:new, :create]

end
