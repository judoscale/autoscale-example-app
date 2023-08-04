class RequestManager
  include ActiveModel::API
  attr_accessor :latency

  def latency
    @latency ||= 1000
  end

  def sleep!
    sleep latency.to_i / 1000.0
  end
end
