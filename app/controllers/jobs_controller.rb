require "sidekiq/api"

class JobsController < ApplicationController
  def new
    @manager = JobManager.new(params[:job_manager] && job_manager_params)
    @queues = queue_stats

    respond_to do |format|
      format.html
      format.json { render json: @queues }
    end
  end

  def create
    @manager = JobManager.new(job_manager_params)
    @manager.enqueue!

    redirect_to new_job_path(job_manager: job_manager_params)
  end

  private

  def job_manager_params
    params.require(:job_manager).permit(:latency, :jobs, :queue)
  end

  def queue_stats
    busy_by_queue = Hash.new(0)
    Sidekiq::WorkSet.new.each do |_process, _thread, work|
      busy_by_queue[work["queue"]] += 1
    end

    Sidekiq::Queue.all.map do |queue|
      {
        name: queue.name,
        size: queue.size,
        busy: busy_by_queue[queue.name],
        latency: queue.latency.round(2)
      }
    end
  end
end
