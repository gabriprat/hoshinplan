module SlimHelper
  
  def param(name, &default)
    content_for?(name) ? content_for(name)  : (capture(&default) if block_given?)
  end

  def full_title(page_title="")
    base_title = app_name
    if page_title.blank?
      base_title
    else
      "#{base_title} : #{page_title}"
    end
  end
   
  def model_name_human(model=@this, *attrs)
    model = model.class unless model.kind_of? Class
    model.model_name.human(*attrs)
  end
  
  def add_classes!(attributes, *classes)
    classes = classes.flatten.select{|x|x}
    current = attributes[:class]
    attributes[:class] = (current ? current.split + classes : classes).uniq.join(' ')
    attributes
  end
  
  def element(name, attributes, content=nil, escape = true, empty = false, &block)
    unless attributes.blank?
      attrs = []
      if escape
        attributes.each do |key, value|
          next unless value
          key = key.to_s.gsub("_", "-")

          value = if ActionView::Helpers::TagHelper::BOOLEAN_ATTRIBUTES.include?(key)
                    key
                  else
                    # escape once
                    value.to_s.gsub(/[\"><]|&(?!([a-zA-Z]+|(#\d+));)/) { |special| ERB::Util::HTML_ESCAPE[special] }
                  end
          attrs << %(#{key}="#{value}")
        end

      else
        attrs = options.map do |key, value|
          key = key.to_s.gsub("_", "-")
          %(#{key}="#{value}")
        end
      end
      attr_string = " #{attrs.sort * ' '}" unless attrs.empty?
    end
    content = capture { new_context &block } if block_given?
    if empty
      "<#{name}#{attr_string}#{scope.xmldoctype ? ' /' : ''}>".html_safe
    else
      "<#{name}#{attr_string}>".html_safe + content + "</#{name}>".html_safe
    end
  end
      
  def ha(attributes={})
    ajax_attrs, attributes = attributes.partition_hash(HoboRapidHelper::AJAX_ATTRS)
    unless ajax_attrs.blank?
      add_data_rapid!(attributes, "a", :ajax_attrs => ajax_attrs)
    end

    if attributes[:query_params]
      if  attributes[:query_params]==true ||  attributes[:query_params].blank?
         attributes[:query_params] = query_parameters_filtered
      else
         attributes[:query_params] = query_parameters_filtered(:only => comma_split(query_params))
      end
      params =  attributes[:query_params].merge( attributes[:params] || HashWithIndifferentAccess.new)
    end
    
    if attributes[:href] || attributes[:name]
      element(:a, attributes.update(:href => href), content)
    else
      url_options, attributes = attributes.partition_hash(%w(only_path protocol host subdomain domain tld_length port anchor trailing_slash))
      url_options[:subsite] = subsite
      params = url_options.merge(params || {})

      target = attributes[:to]

      if attributes[:method]!="get"
        # assume jquery-rails
        attributes['data-method']=attributes[:method]
        attributes['rel']='nofollow'
      end

      if target.nil?
        Dryml.last_if = false
        
      elsif attributes[:action] == "new"
        # Link to a new object form
        new_record = target.respond_to?(:build) ? target.build : target.new
        new_record.set_creator(current_user)
        href = object_url(target, "new", attributes[:params])

        if href && (attributes[:force] || can_create?(new_record))
          # Remove the object from memory after checking permissions
          target.delete(new_record) if new_record && target.respond_to?(:build)
          new_class_name = if target.respond_to?(:proxy_association)
                             target.proxy_association.reflection.klass.name
                           else
                             target.name
                           end

          add_classes!(attributes, "new-#{new_class_name.underscore}-link")
          content = "New #{new_class_name.titleize}" if content.blank?
          Dryml.last_if = true
          element(:a, attributes.update(:href => href), content)
        else
          Dryml.last_if = false
          ""
        end
      else
        # Link to an existing object

        content = block_given? ? yield : target.name

        href = object_url(target, attributes[:action], attributes[:params]) unless (attributes[:action].nil? && target.try.new_record?)
        if href.nil?
          # This target is registered with Hobo::Routes as not linkable
          yield
        else
          css_class = target.try.origin_attribute || target.class.name.underscore.dasherize
          add_classes!(attributes, "#{css_class}-link")

          # Set default link text if none given
          element(:a, attributes.update(:href => href), content)
        end
      end
    end
  end
end