module Dryml

class TemplateEnvironment
  
	def method_missing(name, *args, &b)
		if @view
      begin
			  @view.send(name, *args, &b)
      rescue NoMethodError => e
        fail e.inspect + @view.inspect
      end
		else
			raise NoMethodError, name.to_s
		end
	end
end

end