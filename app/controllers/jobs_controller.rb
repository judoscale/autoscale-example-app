require "sidekiq/api"

class JobsController < ApplicationController
  def new
    @manager = JobManager.new(params[:job_manager] && job_manager_params)
    @queues = Sidekiq::Queue.all

    respond_to do |format|
      format.html
      format.json do
        render json: @queues.map { |queue|
          {name: queue.name, size: queue.size, latency: queue.latency.round(2)}
        }
      end
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
end
