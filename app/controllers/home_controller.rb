class HomeController < ApplicationController
  def index
    @repos = Repo.all
  end
end
