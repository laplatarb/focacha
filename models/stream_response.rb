class StreamResponse
  attr_accessor :type, :data
  
  def initialize(type, data)
    @type = type
    @data = data
  end
  
  def build(connection)
    connection << "event: #{@type}\n"
    connection << "data:  #{@data.to_json}\n\n"
  end
end