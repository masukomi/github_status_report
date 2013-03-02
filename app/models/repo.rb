class Repo < ActiveRecord::Base
  has_many :projects
  has_many :contributers
  attr_accessible :api_endpoint, :branch_naming_convention, :github_name, :host, :oauth_token, :ticket_url



  def get_closed_pull_requests
    response_c = Octokit.pull_requests(github_name, 'closed')

    closed_pull_request_data = JSON.parse(response_c)
    # an array of hashes
    # see http://developer.github.com/v3/pulls/
  end
end
