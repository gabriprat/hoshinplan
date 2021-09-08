class WebhookHeader < ApplicationRecord

  hobo_model # Don't put anything above this

  fields do
    key :string, null: false
    value :string, null: false
  end

  attr_accessible :key, :value

  belongs_to :webhook, null: false

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    self.new_record? || webhook.update_permitted?
  end

  def destroy_permitted?
    self.new_record? || webhook.destroy_permitted?
  end

  def view_permitted?(field)
    true
  end
end