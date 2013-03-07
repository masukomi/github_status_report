class HomeController < ApplicationController
  def index
    @repos = Repo.all
    @git_hubs_count = GitHub.count
  end
end
