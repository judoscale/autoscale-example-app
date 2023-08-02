class HomeController < ApplicationController
  def show
    if latency = params[:latency]&.to_i
      sleep latency / 1000.0
    end
  end
end
