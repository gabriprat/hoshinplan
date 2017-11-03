require "bootstrap_pagination/version"

module AjaxPagination
  # Contains functionality shared by all renderer classes.
  module AjaxRenderer
    ELLIPSIS = "&hellip;"
    TemplateEnvironment = Dryml::TemplateEnvironment.new

    def to_html
      list_items = pagination.map do |item|
        case item
          when Fixnum
            page_number(item)
          else
            send(item)
        end
      end.join(@options[:link_separator])

      tag("ul", list_items, class: ul_class)
    end

    def container_attributes
      super.except(*[:link_options])
    end

    protected

    def page_number(page)
      link_options = @options[:link_options] || {}
      ajax_attrs, attributes = link_options.partition_hash(%w(update updates ajax))
      unless ajax_attrs.blank?
        data_rapid = ActiveSupport::JSON.decode(attributes["data_rapid"] || "{}")
        attributes["data-rapid"] = data_rapid.update(a: {ajax_attrs: ajax_attrs}).to_json
      end

      if page == current_page
        tag("li", tag("span", page), class: "active")
      else
        tag("li", link(page, page, attributes.merge(rel: rel_value(page))))
      end
    end

    def previous_or_next_page(page, text, classname)
      link_options = @options[:link_options] || {}
      ajax_attrs, attributes = link_options.partition_hash(%w(update updates ajax))
      unless ajax_attrs.blank?
        TemplateEnvironment.add_data_rapid!(attributes, "a", ajax_attrs: ajax_attrs)
        attributes = TemplateEnvironment.deunderscore_attributes(attributes)
      end

      if page
        tag("li", link(text, page, attributes), class: classname)
      else
        tag("li", tag("span", text), class: "%s disabled" % classname)
      end
    end

    def gap
      tag("li", tag("span", ELLIPSIS), class: "disabled")
    end

    def previous_page
      num = @collection.current_page > 1 && @collection.current_page - 1
      previous_or_next_page(num, @options[:previous_label], "prev")
    end

    def next_page
      num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
      previous_or_next_page(num, @options[:next_label], "next")
    end

    def ul_class
      ["pagination", @options[:class]].compact.join(" ")
    end
  end
end