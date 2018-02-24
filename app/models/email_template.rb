require 'sendgrid4r'

class EmailTemplate

  TEMPLATES = {
      welcome_es: '1a343d96-92cf-4fb6-a75b-38724f9fcfaa',
      welcome_en: '102c9d46-46ed-4e79-afdb-fc0838669509',
      activation_es: '2425713b-3a6d-45a6-b4f0-2e98e40afb0e',
      activation_en: 'cbb23ef8-77ed-4d95-8cae-bf341aabf980',
      trial_ending_es: '0f140d29-e5f1-4969-8d25-0813df9e5634',
      trial_ending_en: 'c262611d-b702-4584-8e78-3c7d65fb0ce6',
      trial_ended_es: '965c4ef2-b92b-49f7-9ffe-d587edea4d80',
      trial_ended_en: '0ea51c05-edaa-40cc-a23b-7c0d8c79d026',
      assign_responsible_es: '8cce4e0a-18ad-4cf8-a6f6-1885d69542bb',
      assign_responsible_en: '4c556176-1775-4926-9e1c-ce3808d38ccb'
  }

  def initialize(template)
    @template = template
  end

  def self.find(name)
    template_id = get_template_id(name)
    fail "Template #{name} not found!" if template_id.nil?
    Rails.cache.fetch("template_#{template_id}", expires_in: 1.hour) do
      client = SendGrid4r::Client.new(api_key: ENV['SENDGRID_API_KEY'])
      template = client.get_template(template_id: template_id)
      ret = EmailTemplate.new(template)
    end
  end

  def render_content(vars, user)
    version = @template.versions.find {|v| v.active == 1}
    ret = Mustache.render(version.html_content, vars)
    ret.sub!("<%body%>", "")
    if (user._?.partner_id)
      ret.sub!(/https?:\/\/[^\/]+\/assets\/logo.png/, user.partner.email_logo.url('email_logo'))
      ret.sub!(/alt=.Hoshinplan./, "alt=#{user.partner.name}")
    end
    ret
  end

  def render_subject(vars)
    version = @template.versions.find {|v| v.active == 1}
    ret = Mustache.render(version.subject, vars)
    ret.sub("<%subject%>", "")
  end

  #### Initialize template based on missing method name #####
  def self.method_missing(method_name, *args, &block)
    get_template_id(method_name).present? ? find(method_name) : super
  end

  def self.respond_to?(method_name, include_private = false)
    get_template_id(method_name).present? || super
  end

  private

  def self.get_template_id(name, locale = I18n.locale)
    key = "#{name}_#{locale}".to_sym
    TEMPLATES[key] if TEMPLATES.include?(key)
  end
end

