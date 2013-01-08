class StreamResponse
  attr_accessor :type, :data
  
  def initialize(type, data)
    @type = type
    @data = data
  end
  
  def build
    ret = { type: @type, message: @data }
    
    "data: #{ret.to_json}\n\n"
  end
  
end