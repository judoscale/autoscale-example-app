class HomeController < ApplicationController
  after_action :expose_request_metrics, only: :show

  def show
    @manager = RequestManager.new

    if params[:request_manager]
      @manager.attributes = params.require(:request_manager).permit(:latency)
      @manager.sleep!
    end
  end

  private

  def expose_request_metrics
    if (queue_time = request.env["judoscale.queue_time"])
      response.set_header("X-Queue-Time", queue_time.to_s)
    end

    if (request_start = request.headers["X-Request-Start"].presence)
      response.set_header("X-Request-Start", request_start)
    end
  end
end
