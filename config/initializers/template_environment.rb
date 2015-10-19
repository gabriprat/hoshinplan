module Dryml

class TemplateEnvironment
  
	def method_missing(name, *args, &b)
		if @view
      begin
			  @view.send(name, *args, &b)
      rescue NoMethodError => e
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