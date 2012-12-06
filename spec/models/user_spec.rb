require 'minitest_helper'

describe User do
  describe 'when provider and uid are blank' do
    it 'wont be valid' do
      user = User.new
      user.wont_be :valid?
    end
  end

  describe 'when uid is not unique' do
    it 'wont be valid' do
      user = User.create provider: 'twitter', uid: Random.new.rand(999)

      new_user = User.new
      new_user.provider = user.provider
      new_user.uid = user.uid
      new_user.wont_be :valid?
    end
  end

  describe 'create_with_omniauth' do
    describe 'auth hash has provider and uid' do
      it 'must create an user' do
        auth = { 'provider' => Faker::Name.name, 'uid' => Random.new.rand(999) }
        users_count = User.count
        User.create_with_omniauth(auth)
        User.count.wont_equal users_count
      end

      it 'must set facebook_token if provider == "facebook" and token is not blank' do
        auth = { 'provider' => 'facebook', 'uid' => Random.new.rand(999), 'credentials' => { 'token' => Random.new.rand(999).to_s } }
        users_count = User.count
        user = User.create_with_omniauth(auth)
        User.count.wont_equal users_count
        user.facebook_token.wont_be_empty
      end

      it 'wont set facebook_token if provider == "facebook" and token is blank' do
        auth = { 'provider' => 'facebook', 'uid' => Random.new.rand(999), 'credentials' => { 'token' => '' } }
        users_count = User.count
        Proc.new { User.create_with_omniauth(auth) }.must_raise Mongoid::Errors::Validations
        User.count.must_equal users_count
      end

      it 'must set twitter_token and twitter_secret if provider == "twitter", secret and token are not blank' do
        auth = { 'provider' => 'twitter', 'uid' => Random.new.rand(999), 'credentials' => { 'secret' => Random.new.rand(999).to_s, 'token' => Random.new.rand(999).to_s } }
        users_count = User.count
        user = User.create_with_omniauth(auth)
        User.count.wont_equal users_count
        user.twitter_secret.wont_be_empty
        user.twitter_token.wont_be_empty
      end

      it 'wont set twitter_token and twitter_secret if provider == "twitter", secret and token are blank' do
        auth = { 'provider' => 'twitter', 'uid' => Random.new.rand(999), 'credentials' => { 'secret' => '', 'token' => '' } }
        users_count = User.count
        Proc.new { User.create_with_omniauth(auth) }.must_raise Mongoid::Errors::Validations
        User.count.must_equal users_count
      end
    end

    describe 'auth hash has not provider and uid' do
      it 'wont create an user' do
        auth = {}
        users_count = User.count
        Proc.new { User.create_with_omniauth(auth) }.must_raise Mongoid::Errors::Validations
        User.count.must_equal users_count
      end
    end
  end

  describe 'name' do
    it 'must return the user name' do
      skip 'Implement this test, please!'
    end
  end

  describe 'adapter' do
    describe 'when provider == "facebook"' do
      it 'must return an instance of Hash' do
        skip 'Implement this test, please!'
      end
    end

    describe 'when provider == "twitter"' do
      it 'must return an instance of Twitter::User' do
        skip 'Implement this test, please!'
      end
    end
  end
end
