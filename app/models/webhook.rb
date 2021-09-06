class Webhook < ApplicationRecord

  hobo_model # Don't put anything above this

  @queue = 'webhook'

  fields do
    name :string, null: false
    url :string, null: false
    request_method :string, default: 'post'
    headers :string, array: true
    timestamps
    deleted_at :datetime
  end
  index [:deleted_at]
  validates :request_method, inclusion: { in: %w(get post put delete head), message: "%{value} is not a valid request method" }

  attr_accessible :name, :url, :request_method, :headers, :company, :company_id

  belongs_to :company, null: false

  def self.put_or_post?(method)
    %w[put post].include? method
  end

  def self.api_call(method, url, **rest)
    ca_file = Rails.root.join('lib/cacert.pem').to_s
    RestClient::Request.execute(method: method, url: url, ssl_ca_file: ca_file, **rest)
  end

  def self.perform(company, typed_id, log)
    _, name, id = *typed_id.match(/^([^:]+)(?::([^:]+)(?::([^:]+))?)?$/)
    model_class = name.camelize.safe_constantize or raise ArgumentError.new("no such class in typed-id: #{typed_id}")
    return nil unless model_class && id
    obj = model_class.unscoped.find(id)
    payload = {type: obj.model_name, value: obj.as_json, operation: log['operation']}
    payload[:changes] = log['body'] if log['operation'] == 'update'
    wh = Webhook.find_by(company_id: company)
    return unless wh
    headers = wh.headers.inject({}) do |headers, h|
      key, value = h.split(':', 1)
      headers[key] = value
      headers
    end
    Rails.logger.error "=== Webhook request to: " + wh.url
    args = {url: wh.url, headers: headers}
    if Webhook.put_or_post?(wh.request_method)
      args[:payload] = JSON.generate(payload)
    end
    self.api_call(**args)
  end

  def self.send!(company, typed_id, event)
    Resque.enqueue(Webhook, company, typed_id, event)
  end

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end
end