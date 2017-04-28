class TaskTagsController < ApplicationController
  hobo_model_controller

  auto_actions_for :task, [:new, :create]

  autocomplete do
    ret = []
    render :json => ret
  end

  include RestController
end
