require 'socket'
class VectorClient
  def initialize(opt)
    @host = opt[:host]
    @port = opt[:port]
    @io = UDPSocket.new.tap do |socket|
      socket.connect(opt[:host], opt[:port])
    end
  end

  def info(hash)
    @io.write(hash.to_json)
  rescue StandardError => e
    puts e.message
  end
end
