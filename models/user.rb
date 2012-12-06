class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # associations
  has_many :channels

  # fields
  field :facebook_token
  field :provider
  field :uid
  field :twitter_secret
  field :twitter_token

  # validations
  validates :facebook_token, presence: true, uniqueness: true, if: Proc.new { |user| user.provider == 'facebook' }
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: true
  validates :twitter_secret, presence: true, if: Proc.new { |user| user.provider == 'twitter' }
  validates :twitter_token, presence: true, uniqueness: true, if: Proc.new { |user| user.provider == 'twitter' }

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      case user.provider
      when 'facebook'
        user.facebook_token = auth['credentials']['token']
      when 'twitter'
        user.twitter_secret = auth['credentials']['secret']
        user.twitter_token = auth['credentials']['token']
      end
    end
  end

  def name
    case provider
    when 'facebook'
      adapter['name']
    when 'twitter'
      adapter.name
    end
  end

  private

  def adapter
    case provider
    when 'facebook'
      graph = Koala::Facebook::API.new facebook_token
      graph.get_object 'me'
    when 'twitter'
      client = Twitter::Client.new oauth_token_secret: twitter_secret, oauth_token: twitter_token
      client.user(uid.to_i)
    end
  end
end
