class RequestManager
  include ActiveModel::API
  attr_accessor :latency, :rps, :sleep_percent

  def latency
    @latency ||= 1000
  end

  def rps
    @rps ||= 1
  end

  def sleep_percent
    @sleep_percent ||= 100
  end

  def process!
    total_seconds = latency.to_i / 1000.0
    sleep_ratio = sleep_percent.to_i.clamp(0, 100) / 100.0
    sleep_seconds = total_seconds * sleep_ratio
    cpu_seconds = total_seconds - sleep_seconds

    burn_cpu!(cpu_seconds) if cpu_seconds > 0
    sleep(sleep_seconds) if sleep_seconds > 0
  end

  private

  def burn_cpu!(duration_seconds)
    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC) + duration_seconds
    while Process.clock_gettime(Process::CLOCK_MONOTONIC) < finish
      Math.sqrt(rand)
    end
  end
end
