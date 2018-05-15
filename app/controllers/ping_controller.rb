class PingController < ApplicationController

  def ping
    render json: '{"pong": true}', status: :ok
  end

  def pingz
    if asset_exists?('zzzz.css')
      render json: '{"pong": true}', status: :ok and return if !pathname.nil?
    else
      render json: '{"pong": false}', status: :service_unavailable 
    end
  end

  protected

  def asset_exists?(path)
    begin
      pathname = Rails.application.assets.resolve(path)
      return !!pathname # double-bang turns String into boolean
    rescue Sprockets::FileNotFound
      return false
    end
  end


end
