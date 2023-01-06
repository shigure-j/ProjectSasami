class DashboardController < ApplicationController
  def index
  end

  def summary
    @format = Format.find_by(name: :work).get_format
  end

  def detail
    @format = Format.find_by(name: :work).get_format
  end

  def sample
  end
end
