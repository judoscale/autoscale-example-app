class Latency
  include ActiveModel::API
  attr_accessor :ms

  def ms
    @ms ||= 1000
  end

  def sleep!
    sleep ms.to_i / 1000.0
  end
end
