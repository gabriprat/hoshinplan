class Webhook < ApplicationRecord

  hobo_model # Don't put anything above this

  @queue = 'webhook'

  fields do
    name :string, null: false
    url :string, null: false
    request_method :string, default: 'post'
    timestamps
    deleted_at :datetime
  end
  index [:deleted_at]
  validates :request_method, inclusion: { in: %w(get post put delete head), message: "%{value} is not a valid request method" }

  attr_accessible :name, :url, :request_method, :webhook_headers, :webhook_header_ids, :company, :company_id

  has_many :webhook_headers, :accessible => true, :inverse_of => :webhook, :dependent => :destroy

  belongs_to :company, null: false

  def self.put_or_post?(method)
    %w[put post].include? method
  end

  def self.api_call(url:, method:, **rest)
    ca_file = Rails.root.join('lib/cacert.pem').to_s
    Rails.logger.error "======== api call to: " + url
    RestClient::Request.execute(method: method, url: url, ssl_ca_file: ca_file, :user_agent => "myagent", **rest)
  end

  def self.perform(company, typed_id, log)
    _, name, id = *typed_id.match(/^([^:]+)(?::([^:]+)(?::([^:]+))?)?$/)
    model_class = name.camelize.safe_constantize or raise ArgumentError.new("no such class in typed-id: #{typed_id}")
    return nil unless model_class && id
    obj = model_class.unscoped.find(id)
    payload = {type: obj.model_name, value: obj.as_json, operation: log['operation']}
    payload[:changes] = JSON.parse(log['body']) if log['operation'] == 'update'
    wh = Webhook.find_by(company_id: company)
    return unless wh
    headers = wh.webhook_headers.inject({user_agent: 'hoshinplan-webhook/1.0.1', content_type: :json, accept: :json}) do |headers, h|
      headers[h.key] = h.value
      headers
    end
    Rails.logger.error "=== Webhook request to: " + wh.url
    args = {url: wh.url, headers: headers, method: wh.request_method}
    if Webhook.put_or_post?(wh.request_method)
      args[:payload] = JSON.generate(payload)
    end
    self.api_call(**args)
  end

  def self.send!(company, typed_id, event)
    Resque.enqueue(Webhook, company, typed_id, event)
  end

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    self.new_record? || company.update_permitted?
  end

  def destroy_permitted?
    self.new_record? || company.destroy_permitted?
  end

  def view_permitted?(field)
    true
  end
end