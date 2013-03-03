class Repo < ActiveRecord::Base
  has_many :projects
  has_many :contributers
  #TODO add support for octokit proxy param
  attr_accessible :api_endpoint, :branch_naming_convention, :github_name, :host, :oauth_token, :ticket_url



  # Public:  returns a sorted collection of pull RequestS
  #           TEMPORARILY limited to closed pull requests
  # include_unmerged - defaults to false
  def get_sorted_pull_requests(include_unmerged = false)
    cprs = get_closed_pull_requests(include_unmerged)
     #cprs = Closed Pull RequestS
    cpr_by_proj = {}
    cprs.each do |cpr| # Closed Pull Request
      temp_proj = cpr.project || '' # don't want nil
      unless cpr_by_proj.has_key? temp_proj
        cpr_by_proj[temp_proj] = {:bugs=>[], :adds=>[], :unknown=>[]}
      end
      type = cpr.type || 'unknown'
      if (cpr.type == 'bug')
        cpr_by_proj[temp_proj][:bugs] << cpr
      elsif cpr.type == 'add'
        cpr_by_proj[temp_proj][:adds] << cpr
      else
        cpr_by_proj[temp_proj][:unknown] << cpr
      end
    end
    
    cpr_by_proj.keys.each do |key|
      cpr_by_proj[key][:bugs].sort_by!(&:merged_at)
      cpr_by_proj[key][:adds].sort_by!(&:merged_at)
      cpr_by_proj[key][:unknown].sort_by!(&:merged_at)
    end

    return cpr_by_proj

  end


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
