class Repo < ActiveRecord::Base
  has_many :projects
  has_many :contributers
  #TODO add support for octokit proxy param
  attr_accessible :api_endpoint, :branch_naming_convention, :github_name, :host, :oauth_token, :ticket_url



  # Public: gets all closed pull requests for this repo
  # 
  # include_unmerged - indicates if you want unmerged pull requests
  #                    included in the resulting data
  def get_closed_pull_requests(include_unmerged = false)

    Octokit.configure do |config|

      config.login        = github_name.split('/')[0]
      config.web_endpoint = host
      config.oauth_token  = oauth_token
      #TODO add support for github_proxy
      #config.proxy        = github_proxy if github_proxy
      config.api_endpoint = api_endpoint
    end

    closed_pull_requests_data = Octokit.pull_requests(github_name, 'closed')
    # an array of hashes
    # see http://developer.github.com/v3/pulls/

    closed_pull_requests = []
    closed_pull_requests_data.each do | cpr |
      pr = PullRequest.create_from_pull_and_repo(cpr, self)
      if (pr.merged_at or include_unmerged)
        closed_pull_requests << pr
      end
    end

    return closed_pull_requests
  end


end
