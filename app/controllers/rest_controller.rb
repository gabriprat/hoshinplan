module RestController 
  def hobo_show
         super do |format|
                 format.json { render :json => find_instance.to_json }
                 format.xml { render :xml => find_instance.to_xml }
                 format.html {super}
         end
   end
 
   def hobo_index(*args, &b)
          super do |format|
                  format.json { 
                      options = args.extract_options!
                      finder = args.first || model
                      self.this ||= find_or_paginate(finder, options)
                      render :json => self.this.to_json 
                  }
                  format.xml { 
                    options = args.extract_options!
                    finder = args.first || model
                    self.this ||= find_or_paginate(finder, options)
                    render :xml => self.this.to_xml
                  }
                  format.html {super}
          end
    end
    
    def render
      fail "hola"
    end
end