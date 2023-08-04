class Job
  include Sidekiq::Job

  def perform(latency)
    sleep latency.to_i / 1000.0
  end
end
