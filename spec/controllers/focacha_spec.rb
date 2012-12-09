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
    # do not use a real user!
    user = User.create provider: 'test_provider', uid: Random.new.rand(999)
    session uid: user.uid
  end

  describe 'GET /' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      it 'must redirect to /channels' do
        get '/'
        last_response.must_be :redirection?
        last_response.header['Location'].must_match '/channels'
      end
    end

    describe 'when the user is not authenticated' do
      it 'must halt with 401 status code' do
        get '/'
        last_response.status.must_equal 401
      end
    end
  end

  describe 'GET /auth/:provider/callback' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      it 'must have a real test' do
        skip 'Implement this test, please!'
      end
    end

    describe 'when the user is not authenticated' do
      it 'must have a real test' do
        skip 'Implement this test, please!'
      end
    end
  end

  describe 'GET /auth/failure' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      it 'must have a real test' do
        skip 'Implement this test, please!'
      end
    end

    describe 'when the user is not authenticated' do
      it 'must have a real test' do
        skip 'Implement this test, please!'
      end
    end
  end

  describe 'DELETE /auth/destroy' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      it 'must have a real test' do
        skip 'Implement this test, please!'
      end
    end

    describe 'when the user is not authenticated' do
      it 'must have a real test' do
        skip 'Implement this test, please!'
      end
    end
  end

  describe 'GET /channels' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      it 'must show all channels' do
        get '/channels'
        last_response.must_be :ok?
      end
    end

    describe 'when the user is not authenticated' do
      it 'wont show all channels' do
        get '/channels'
        last_response.status.must_equal 401
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
        last_response.must_be :ok?
        Channel.count.must_equal channels_count
      end

      it 'wont create a channel if channel[name] is not unique' do
        user = User.create provider: 'test_provider', uid: Random.new.rand(999)
        channel = Channel.create name: Faker::Name.name, user: user
        channels_count = Channel.count
        post '/channels', channel: { name: channel.name }
        last_response.must_be :ok?
        Channel.count.must_equal channels_count
      end

      it 'must create a channel' do
        channels_count = Channel.count
        post '/channels', channel: { name: Faker::Name.name }
        last_response.must_be :redirection?
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
        last_response.must_be :ok?
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

  describe 'PUT /channels/:id/change_current_topic' do
    describe 'when the user is authenticated' do
      before do
        sign_in
      end

      describe 'when current_topic is not provided' do
        it 'must unset channel\'s current topic' do
          channel = Channel.create name: Faker::Name.name
          messages_count = channel.messages.count
          put "/channels/#{channel.id}/change_current_topic", channel: { current_topic: '' }
          last_response.must_be :redirection?
          channel.reload
          channel.current_topic.must_be :blank?
          channel.messages.count.wont_equal messages_count
        end
      end

      describe 'when current_topic is provided' do
        it 'must set channel\'s current topic' do
          channel = Channel.create name: Faker::Name.name
          messages_count = channel.messages.count
          current_topic = Faker::Lorem.words
          put "/channels/#{channel.id}/change_current_topic", channel: { current_topic: current_topic }
          last_response.must_be :redirection?
          channel.reload
          channel.current_topic.must_equal current_topic
          channel.messages.count.wont_equal messages_count
        end
      end
    end

    describe 'when the user is not authenticated' do
      describe 'when current_topic is not provided' do
        it 'wont unset channel\'s current topic' do
          channel = Channel.create name: Faker::Name.name
          put "/channels/#{channel.id}/change_current_topic", channel: { current_topic: '' }
          last_response.status.must_equal 401
        end
      end

      describe 'when current_topic is provided' do
        it 'wont set channel\'s current topic' do
          channel = Channel.create name: Faker::Name.name
          current_topic = Faker::Lorem.words
          put "/channels/#{channel.id}/change_current_topic", channel: { current_topic: current_topic }
          last_response.status.must_equal 401
        end
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
        last_response.must_be :ok?
        channel.reload
        channel.messages.count.must_equal messages_count
      end

      it 'must create a message' do
        channel = Channel.create name: Faker::Name.name
        messages_count = channel.messages.count
        post "/channels/#{channel.id}/messages", message: { text: Faker::Lorem.paragraphs }
        last_response.must_be :redirection?
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
