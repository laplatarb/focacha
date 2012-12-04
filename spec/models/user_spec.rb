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
end
