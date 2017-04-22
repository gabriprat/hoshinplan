class FayeAuthController < ApplicationController

  hobo_controller

  def faye_auth
    scope_current_user do
      response = params[:messages].values.map do |message|
        message.delete 'signature'
        if message['channel'] =~ /\/comment\/\w+\/\d+/
          model, id, comment_model = message['channel'].split('/').last(2)
          typed_id = "#{model.singularize}:#{id}"
          inst = Hobo::Model.find_by_typed_id(typed_id) rescue nil
          if inst
            inst.with_acting_user(current_user) do
              if inst.update_permitted?
                message['creatorId'] = current_user.id
                message['signature'] = Faye::Authentication.sign(message, ENV['WS_SECRET'])
              end
            end
          end
        end
        message['error'] = 'Forbidden' unless message['signature']
        message
      end
      render json: {signatures: response}
    end
  end
end