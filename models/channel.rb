class Channel
  include Mongoid::Document
  include Mongoid::Timestamps

  # associations
  belongs_to :user
  embeds_many :messages

  # fields
  field :current_topic
  field :name

  # validations
  validates :name, presence: true, uniqueness: true
end
