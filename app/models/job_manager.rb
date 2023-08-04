class JobManager
  include ActiveModel::API
  attr_accessor :latency, :jobs, :queue

  def latency
    @latency ||= 1000
  end

  def jobs
    @jobs ||= 10
  end

  def queue
    @queue ||= "default"
  end

  def enqueue!
    sidekiq_args = Array.new(jobs.to_i) { [latency.to_i] }
    Sidekiq::Client.push_bulk "class" => Job, "queue" => queue, "args" => sidekiq_args
  end
end
