class Partner < ApplicationRecord

  acts_as_paranoid

  include ModelBase

  hobo_model # Don't put anything above this

  fields do
    name :string
    slug :string
    companies_trial_days :integer, default: 90
    timestamps
    deleted_at :datetime
  end
  index [:deleted_at]

  has_attached_file :image, {
      :styles => {
          :logo => ["127x30>", :png],
          :logo2x => ["254x60>", :png]
      },
      :convert_options => {
          :logo => "-quality 99 -background none -gravity West -extent 127x30",
          :logo2x => "-quality 99 -background none -gravity West -extent 254x60"
      },
      :s3_headers => {
          'Cache-Control' => 'public, max-age=315576000',
          'Expires' => 10.years.from_now.httpdate
      },
      :default_style => :logo,
      :default_url => "/assets/hp-logo-white.png"
  }
  crop_attached_file :image, :aspect => "127:30"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  validates_attachment_size :image, :less_than => 10.megabytes

  has_attached_file :email_logo, {
      :styles => {
          :email_logo => ["173x47>", :png],
          :email_logo2x => ["346x94>", :png]
      },
      :convert_options => {
          :email_logo => "-quality 99 -background none -gravity West -extent 173x47",
          :email_logo2x => "-quality 99 -background none -gravity West -extent 346x94"
      },
      :s3_headers => {
          'Cache-Control' => 'public, max-age=315576000',
          'Expires' => 10.years.from_now.httpdate
      },
      :default_style => :email_logo,
      :default_url => "/assets/logo.png"
  }
  crop_attached_file :email_logo, :aspect => "173:47"
  validates_attachment_content_type :email_logo, :content_type => /\Aimage\/.*\Z/
  validates_attachment_size :email_logo, :less_than => 10.megabytes

  attr_accessible :name, :creator_id, :image, :slug, :email_logo

  belongs_to :creator, :class_name => "User", :creator => true

  has_many :users, :inverse_of => :partner

  has_many :companies, :inverse_of => :partner

  has_many :invitation_codes, :inverse_of => :partner

  children :users

  def email_logo_url
    self.email_logo.url(:email_logo)
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.administrator? || same_creator
  end

  def destroy_permitted?
    acting_user.administrator? || same_creator
  end

  def view_permitted?(field)
    self.new_record? || acting_user.administrator? || same_creator
  end

end
