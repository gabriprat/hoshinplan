
class HoshinCommentsController < ApplicationController
  hobo_model_controller

  auto_actions_for :hoshin, [:new, :create]

end