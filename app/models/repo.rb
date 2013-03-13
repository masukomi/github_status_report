class Repo < ActiveRecord::Base

  SECONDS_IN_A_DAY=60*60*24

  belongs_to :git_hub
  has_many :projects
  has_many :contributers

  validates_presence_of :git_hub

  #TODO add support for octokit proxy param
  #TODO validate :branch_naming_convention
  attr_accessible :branch_naming_convention, 
                  :github_name, 
                  :oauth_token, 
                  :ticket_url,
                  :numeric_tickets 
                    # boolean indicating if ticket ids are numeric or not.



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
      next if (! options[:project_name].blank? and pr.project.name != options[:project_name])
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
  
  # Public: extracts the "keys" from a branch name
  #         Keys being the named sections of the expected branch names.
  def get_branch_name_keys
    keys = branch_naming_convention.split('_').map{
      |key| key.start_with?(':') ? key[1..key.length] : key
    }
    return keys
  end


  # Public: returns a regular expression that will 
  #         match the branch naming convention 
  #         specified by the user
  # as_string - by default it will return a RegExp object
  #             passing true to as_string will return 
  #             the raw string that would normally be 
  #             converted to the regexp. This is primarily
  #             to facilitate testing.
  def get_regexp_for_branch_names(as_string = false)
    keys = get_branch_name_keys()
    # an array of the things that we need to look for in the name
    regexp_string = nil
    if (numeric_tickets?)
      if keys.length > 1
        regexp_string = ''
        (0...(keys.length)).each do |idx|
          if keys[idx] != 'ticket' || ! numeric_tickets
            regexp_string+='(.*?)'
          else
            regexp_string+='\d+'
          end
          if idx < (keys.length() -1)
            regexp_string +='_'
          end
        end
      else
        regexp_string = "(.*)"
      end
    else
      regexp_string = ('(.*?)_' * (keys.length() -1)) + "(.*)"
    end
    return (as_string ? regexp_string : Regexp.new(regexp_string))
  end

end
