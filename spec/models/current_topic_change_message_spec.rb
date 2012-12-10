require 'minitest_helper'

describe CurrentTopicChangeMessage do
  describe 'when text is blank' do
    it 'must be valid' do
      message = CurrentTopicChangeMessage.new
      message.must_be :valid?
    end
  end
end
