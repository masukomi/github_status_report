class Repo < ActiveRecord::Base

  SECONDS_IN_A_DAY=60*60*24

  belongs_to :git_hub
  has_many :projects
  has_many :contributers

  validates_presence_of :git_hub

  #TODO add support for octokit proxy param
  attr_accessible :branch_naming_convention, 
                  :github_name, 
                  :oauth_token, 
                  :ticket_url



  # Public:  returns a sorted collection of pull RequestS
  #           TEMPORARILY limited to closed pull requests
  # options - options to control filtering of results
  #           :days - the number of days back to go. defaults to 7
  #           :include_unmerged - defaults to false
  #                     indicates if unmerged pull Requests 
  #                     should be included in the results.
  
  def get_sorted_pull_requests(options = {:include_unmerged=>false, :days=>7})
    cprs = get_closed_pull_requests(options)
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
  # options - options to control filtering of results
  #           :days - the number of days back to go
  #           :include_unmerged - defaults to false
  #                     indicates if unmerged pull Requests 
  #                     should be included in the results.
  def get_closed_pull_requests(options)
    raise "This repo has no GitHub object" if git_hub.nil?
    epoch_start_time = DateTime.now().to_time.to_i
    options[:days] = 7 unless options[:days]

    Octokit.configure do |config|

      config.login        = github_name.split('/')[0]
      config.web_endpoint = git_hub.domain
      config.oauth_token  = oauth_token
      #TODO add support for github_proxy
      #config.proxy        = github_proxy if github_proxy
      config.api_endpoint = git_hub.api_endpoint
    end

    closed_pull_requests_data = Octokit.pull_requests(github_name, 'closed')
    # an array of hashes
    # see http://developer.github.com/v3/pulls/

    closed_pull_requests = []
    closed_pull_requests_data.each do | cpr |
      pr = PullRequest.create_from_pull_and_repo(cpr, self)
      # skip unmerged unless options[:include_unmerged]
      next if (! options[:project_name].blank? and pr.project != options[:project_name])
      next if (! pr.merged_at and not options[:include_unmerged])
      # skip unless within past option[:days] days
      epoch_merged_date = pr.merged_at.to_time.to_i
      next if epoch_start_time - epoch_merged_date > options[:days] * SECONDS_IN_A_DAY
      next if options[:type] and pr.type != options[:type]
        # PullRequest guarantees they will be 'bug', 'add', or nil
      closed_pull_requests << pr
    end

    return closed_pull_requests
  end


end
