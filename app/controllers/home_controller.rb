class HomeController < ApplicationController
  attr_reader :geohash
  helper_method :geohash

  def show
    @geohash = params[:id]
  end
end