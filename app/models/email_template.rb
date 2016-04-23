require 'sendgrid4r'
require 'erb'
require 'ostruct'

class EmailTemplate
    
  TEMPLATES = {
    welcome_es: '1a343d96-92cf-4fb6-a75b-38724f9fcfaa', 
    welcome_en: '102c9d46-46ed-4e79-afdb-fc0838669509',
    activation_es: '2425713b-3a6d-45a6-b4f0-2e98e40afb0e',
    activation_en: 'cbb23ef8-77ed-4d95-8cae-bf341aabf980'
  }
  
  def initialize(template)
    @template = template
  end
  
  def self.find(template_id)
    Rails.cache.fetch(template_id, expires_in: 1.hour) do 
      client = SendGrid4r::Client.new(api_key: ENV['SENDGRID_API_KEY'])
      template = client.get_template(template_id: template_id)
      EmailTemplate.new(template)
    end
  end
  
  def render_content(vars)
    version = @template.versions.find { |v| v.active == 1 }
    ret = Mustache.render(version.html_content, vars)
    ret.sub("<%body%>","")
  end
  
  def render_subject(vars)
    version = @template.versions.find { |v| v.active == 1 }
    ret = Mustache.render(version.subject, vars)
    ret.sub("<%subject%>","")
  end
  
  #### Initialize template based on missing method name #####
  def self.method_missing(name, *args, &block)
    key = templates_key(name)
    super unless TEMPLATES.include? key
    find(TEMPLATES[key])
  end
  
  def self.respond_to?(method_name, include_private = false)
    TEMPLATES.include? templates_key(name) || super
  end
  
  private
  
  def self.templates_key(name)
    "#{name}_#{I18n.locale}".to_sym
  end
end

