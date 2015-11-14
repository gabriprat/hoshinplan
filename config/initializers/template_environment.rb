module Dryml

class TemplateEnvironment
  
	def method_missing(name, *args, &b)
		if @view
      begin
			  @view.send(name, *args, &b)
      rescue ActionView::Template::Error => e
        Rails.logger.error "Clearing DRYML cache and precompiling taglibs again"
        Dryml.clear_cache
        Dryml.empty_page_renderer(@view)
        Dryml.precompile_taglibs
        fail e
      end
		else
			raise NoMethodError, name.to_s
		end
	end
end

end