class HomeController < ApplicationController
  after_action :expose_request_metrics, only: :show

  def show
    @manager = RequestManager.new
    attrs = request_manager_attrs
    @manager.attributes = attrs if attrs.any?

    if attrs.key?("latency") || attrs.key?("sleep_percent")
      @manager.process!
    end
  end

  private

  def request_manager_attrs
    raw = if params[:request_manager].present?
      params.require(:request_manager).permit(:latency, :sleep_percent, :rps)
    else
      params.permit(:latency, :sleep_percent, :rps)
    end

    raw.to_h.compact_blank
  end

  def expose_request_metrics
    if (queue_time = request.env["judoscale.queue_time"])
      response.set_header("X-Queue-Time", queue_time.to_s)
    end

    if (request_start = request.headers["X-Request-Start"].presence)
      response.set_header("X-Request-Start", request_start)
    end
  end
end
