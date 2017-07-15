class PingController < ApplicationController

  def ping
    render json: '{"pong": true}', status: :ok
  end

end
