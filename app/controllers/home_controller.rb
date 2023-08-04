class HomeController < ApplicationController
  def show
    @latency = Latency.new

    if params[:latency]
      @latency.attributes = params.require(:latency).permit(:ms)
      @latency.sleep!
    end
  end
end
