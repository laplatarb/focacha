require 'minitest_helper'

describe Message do
  describe 'when text is blank' do
    it 'wont be valid' do
      message = Message.new
      message.wont_be :valid?
    end
  end
end
