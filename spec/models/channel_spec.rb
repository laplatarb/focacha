require 'minitest_helper'

describe Channel do
  describe 'when name is blank' do
    it 'wont be valid' do
      channel = Channel.new
      channel.wont_be :valid?
    end
  end

  describe 'when name is not unique' do
    it 'wont be valid' do
      channel = Channel.create name: Faker::Name.name

      new_channel = Channel.new
      new_channel.name = channel.name
      new_channel.wont_be :valid?
    end
  end
end
