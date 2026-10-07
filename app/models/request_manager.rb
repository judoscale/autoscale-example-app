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

  # Holds until +latency+ ms of wall-clock time have elapsed since +started+.
  # Burns the CPU share first, runs the action/render next, then sleeps any
  # remainder so total request duration tracks +latency+.
  def hold!(started: monotonic_now)
    total_seconds = latency.to_i / 1000.0
    deadline = started + total_seconds
    sleep_ratio = sleep_percent.to_i.clamp(0, 100) / 100.0
    cpu_deadline = started + (total_seconds * (1.0 - sleep_ratio))

    burn_cpu_until!([cpu_deadline, deadline].min)
    yield if block_given?

    leftover = deadline - monotonic_now
    sleep(leftover) if leftover > 0
  end

  private

  # Burn CPU in a forked child so work does not hold the MRI GIL and can run
  # in parallel across Puma threads. The child targets the same absolute
  # monotonic deadline as the parent, so fork overhead does not extend the
  # request. Parent wait is GIL-free. exit! skips Rails at_exit hooks.
  def burn_cpu_until!(finish)
    return if monotonic_now >= finish

    pid = fork do
      while Process.clock_gettime(Process::CLOCK_MONOTONIC) < finish
        Math.sqrt(rand)
      end
      exit!
    end

    Process.wait(pid)
  end

  def monotonic_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
