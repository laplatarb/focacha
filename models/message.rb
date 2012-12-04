class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  # associations
  belongs_to :user
  embedded_in :channel

  # fields
  field :text

  # validations
  validates :text, presence: true
end
