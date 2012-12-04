class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # associations
  has_many :channels

  # fields
  field :provider
  field :uid

  # validations
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: true
end
