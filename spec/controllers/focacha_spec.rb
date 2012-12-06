require 'minitest_helper'

describe Focacha::Application do
  include Rack::Test::Methods

  def app
    Focacha::Application
  end

  def session(data = {})
    sid = SecureRandom.hex(32)
    hsh = data.merge(session_id: sid)
    data = [Marshal.dump(hsh)].pack('m')
    secret = app.session_secret
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, secret, data)
    str = "#{data}--#{hmac}"
    set_cookie("rack.session=#{URI.encode_www_form_component(str)}")
  end

  def sign_in
    #User.create provider: 'twitter', uid: Random.new.rand(999), twitter_secret: Random.new.rand(999), twitter_token: Random.new.rand(999)
    user = User.create provider: 'test_provider', uid: Random.new.rand(999)
    session uid: user.uid
  end

  describe 'GET /' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      it 'must show all channels' do
        get '/'
        last_response.body.wont_match /Sign in with twitter/
      end
    end

    describe 'when the user is not authenticated' do
      it 'must show "Sign in with twitter" link' do
        get '/'
        last_response.body.must_match /Sign in with twitter/
      end
    end
  end

  describe 'GET /auth/:provider/callback' do
    it 'must have a real test' do
      skip 'Implement this test, please!'
    end
  end

  describe 'GET /auth/failure' do
    it 'must have a real test' do
      skip 'Implement this test, please!'
    end
  end

  describe 'DELETE /auth/destroy' do
    describe 'when the user is authenticated' do
      it 'must destroy the current session' do
        skip 'Implement this test, please!'
      end
    end

    describe 'when the user is not authenticated' do
      it 'must destroy the current session' do
        skip 'Implement this test, please!'
      end
    end
  end

  describe 'POST /channels' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      it 'wont create a channel if channel[name] is not present' do
        channels_count = Channel.count
        post '/channels', channel: { name: '' }
        last_response.status.must_equal 200
        Channel.count.must_equal channels_count
      end

      it 'wont create a channel if channel[name] is not unique' do
        user = User.create provider: 'test_provider', uid: Random.new.rand(999)
        channel = Channel.create name: Faker::Name.name, user: user
        channels_count = Channel.count
        post '/channels', channel: { name: channel.name }
        last_response.status.must_equal 200
        Channel.count.must_equal channels_count
      end

      it 'must create a channel' do
        channels_count = Channel.count
        post '/channels', channel: { name: Faker::Name.name }
        last_response.status.must_equal 301
        Channel.count.wont_equal channels_count
      end
    end

    describe 'when the user is not authenticated' do
      it 'wont create a channel if channel[name] is not present' do
        channels_count = Channel.count
        post '/channels', channel: { name: '' }
        last_response.status.must_equal 401
        Channel.count.must_equal channels_count
      end

      it 'wont create a channel if channel[name] is not unique' do
        channel = Channel.create name: Faker::Name.name
        channels_count = Channel.count
        post '/channels', channel: { name: channel.name }
        last_response.status.must_equal 401
        Channel.count.must_equal channels_count
      end

      it 'wont create a channel' do
        channels_count = Channel.count
        post '/channels', channel: { name: Faker::Name.name }
        last_response.status.must_equal 401
        Channel.count.must_equal channels_count
      end
    end
  end

  describe 'GET /channels/:id' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      it 'must show channel' do
        channel = Channel.create name: Faker::Name.name
        get "/channels/#{channel.id}"
        last_response.status.must_equal 200
      end
    end

    describe 'when the user is not authenticated' do
      it 'wont show channel' do
        channel = Channel.create name: Faker::Name.name
        get "/channels/#{channel.id}"
        last_response.status.must_equal 401
      end
    end
  end

  describe 'POST /channels/:id/messages' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      it 'wont create a message if message[text] is not present' do
        channel = Channel.create name: Faker::Name.name
        messages_count = channel.messages.count
        post "/channels/#{channel.id}/messages", message: { text: '' }
        last_response.status.must_equal 200
        channel.reload
        channel.messages.count.must_equal messages_count
      end

      it 'must create a message' do
        channel = Channel.create name: Faker::Name.name
        messages_count = channel.messages.count
        post "/channels/#{channel.id}/messages", message: { text: Faker::Lorem.paragraphs }
        last_response.status.must_equal 301
        channel.reload
        channel.messages.count.wont_equal messages_count
      end
    end

    describe 'when the user is not authenticated' do
      it 'wont create a message if message[text] is not present' do
        channel = Channel.create name: Faker::Name.name
        messages_count = channel.messages.count
        post "/channels/#{channel.id}/messages", message: { text: '' }
        last_response.status.must_equal 401
        channel.reload
        channel.messages.count.must_equal messages_count
      end

      it 'wont create a message' do
        channel = Channel.create name: Faker::Name.name
        messages_count = channel.messages.count
        post "/channels/#{channel.id}/messages", message: { text: Faker::Lorem.paragraphs }
        last_response.status.must_equal 401
        channel.reload
        channel.messages.count.must_equal messages_count
      end
    end
  end
end
