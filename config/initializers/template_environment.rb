module Dryml
   
  class TemplateEnvironment
  
  	def method_missing(name, *args, &b)
  		if @view
        begin
  			  @view.send(name, *args, &b)
        rescue NoMethodError => e
          Rails.logger.error "Clearing DRYML cache and precompiling taglibs again"
          Dryml::Template.clear_build_cache
          Dryml.clear_cache
          Dryml.precompile_taglibs
          fail e
        end
  		else
  			raise NoMethodError, name.to_s
  		end
  	end
  end

end

module ActionView
  # = Action View Template
  class Template
    alias_method :old_handle_render_error, :handle_render_error
    def handle_render_error(view, e)
      template = self
      unless template.source
        template = refresh(view)
        template.encode!
        template.compile!(view)
      end
      old_handle_render_error(view, e)
    end
  end
   
end