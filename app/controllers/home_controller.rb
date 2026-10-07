class HomeController < ApplicationController
  # Prepend so the latency deadline wraps other before/after filters
  # (e.g. authenticity, importmap, propshaft), not just the action body.
  prepend_around_action :enforce_latency, only: :show
  after_action :expose_request_metrics, only: :show

  def show
    # Load-test requests skip the HTML body so response rendering does not
    # compete with CPU-burn work on other threads.
    head :ok if load_test_request?
  end

  private

  def enforce_latency
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    @manager = RequestManager.new
    attrs = request_manager_attrs
    @manager.attributes = attrs if attrs.any?

    if load_test_request?(attrs)
      @manager.hold!(started: started) { yield }
    else
      yield
    end
  end

  def load_test_request?(attrs = request_manager_attrs)
    attrs.key?("latency") || attrs.key?("sleep_percent")
  end

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
