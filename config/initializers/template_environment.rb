module Dryml

  @semaphore ||= Mutex.new
   
  alias_method :old_precompile_taglibs, :precompile_taglibs

  def precompile_taglibs
    old_precompile_taglibs
  end
  
  def page_renderer(view, identifier, local_names=[], controller_path=nil, imports=nil)
      controller_path ||= view.controller.controller_path
      if identifier =~ /#{ID_SEPARATOR}/
        identifier = identifier.split(ID_SEPARATOR).first
        @cache[identifier] ||=  make_renderer_class("", "", local_names, taglibs_for(controller_path), imports_for_view(view))
        @cache[identifier].new(view)
      else
        mtime = File.mtime(identifier)
        renderer_class = @cache[identifier]
        # do we need to recompile?
        if (!renderer_class ||                                          # nothing cached?
            (local_names - renderer_class.compiled_local_names).any? || # any new local names?
            renderer_class.load_time < mtime)                           # cache out of date?
            Rails.logger.error "========= Compiling: " + identifier
          renderer_class = make_renderer_class(File.read(identifier), identifier,
                                               local_names, taglibs_for(controller_path),
                                               imports_for_view(view))
          renderer_class.load_time = mtime
          @cache[identifier] = renderer_class
        end
        renderer_class.new(view)
      end
    end
  
  
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