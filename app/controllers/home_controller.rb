class HomeController < ApplicationController
  def show
    @manager = RequestManager.new

    if params[:request_manager]
      @manager.attributes = params.require(:request_manager).permit(:latency)
      @manager.sleep!
    end
  end
end
