class ErrorsController < ApplicationController
  hobo_controller
  # Do not require the user to be logged in
  skip_filter *_process_action_callbacks.map(&:filter)
  
  #Response
     respond_to :html, :xml, :json

   	#Dependencies
   	before_action :status, :app_name
   	after_action :store

     #Layout
     layout :layout_status

     ####################
     #      Action      #
     ####################

   	#Show
    def file_not_found
      respond_with status: @status
    end

    def unprocessable
      respond_with status: @status
    end

    def internal_server_error
      respond_with status: @status
    end

     ####################
     #   Dependencies   #
     ####################
  
  protected
  
      def store
        options = {
          :uri => request.url,
          :referrer => request.referrer,
          :request_params => request.params
        }
        NewRelic::Agent.notice_error(@exception, options)
      end

      #Info
      def status
        @exception  = env['action_dispatch.exception']
        @status     = ActionDispatch::ExceptionWrapper.new(env, @exception).status_code
        @response   = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]
      end

      #Format
      def details
        @details ||= {}.tap do |h|
          I18n.with_options scope: [:exception, :show, @response], exception_name: @exception.class.name, exception_message: @exception.message do |i18n|
            h[:name]    = i18n.t "#{@exception.class.name.underscore}.title", default: i18n.t(:title, default: @exception.class.name)
            h[:message] = i18n.t "#{@exception.class.name.underscore}.description", default: i18n.t(:description, default: @exception.message)
          end
        end
      end
      helper_method :details

      ####################
      #      Layout      #
      ####################

  private

      #Layout
      def layout_status
        return ExceptionHandler.config.exception_layout || 'error' if @status.to_s != "404"
        ExceptionHandler.config.error_layout || 'application'
      end

      #App
      def app_name
        @app_name = Rails.application.class.parent_name
      end
end