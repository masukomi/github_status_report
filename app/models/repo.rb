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

  def get_branch_name_keys()
    bnc = branch_naming_convention.nil? ? '' : branch_naming_convention
    return bnc.split('_').map{
      |key| key.start_with?(':') ? key[1..key.length].to_sym : key.to_sym
    }
  end

  # Public: returns a regular expression that will 
  #         match the branch naming convention 
  #         specified by the user
  # options  - options to control the output (default: {})
  #             :as_string by default it will return a RegExp object
  #             setting :as_string (symbol) to true will return 
  #             the raw string that would normally be 
  #             converted to the regexp. This is primarily
  #             to facilitate testing.
  #             :
  # 
  def get_regexp_for_branch_names(options={})
    options[:as_string] = false if options[:as_string].blank?
    options[:ignore_numeric] = false if options[:ignore_numeric].blank?
    keys = get_branch_name_keys()
    # an array of the things that we need to look for in the name
    regexp_string = nil
    if (numeric_tickets? and not options[:ignore_numeric])
      if keys.length > 1
        regexp_string = '^'
        (0...(keys.length)).each do |idx|
          if keys[idx] != :ticket || ! numeric_tickets
            regexp_string+='(.*?)'
          else
            regexp_string+='(\d+)'
          end
          if idx < (keys.length() -1)
            regexp_string +='_'
          end
        end
        if regexp_string.end_with? '(.*?)'
          regexp_string.sub!(/\(\.\*\?\)$/, '(.*)')
        end
      else
        regexp_string = "^(.*)"
      end
    else
      if keys.length > 1
        regexp_string = '^' + ('(.*?)_' * (keys.length() -1)) + '(.*)'
      else
        regexp_string = "^(.*)"
      end
    end
    return (options[:as_string] ? regexp_string : Regexp.new(regexp_string))
  end

  # Public: groups pull requests by day of creation
  #
  # pull_requests: An array of PullRequest objects.
  #                If it's a hash it will ignore the keys
  #                and assume the values are PullRequests
  #
  # returns: a hash of pull requests with the keys being the day
  #          they were created, and the values being a sorted 
  #          array of pull requests.
  def self.sort_pull_recs_by_day(pull_requests)
    if pull_requests.is_a? Hash
      pull_requests = pull_requests.values()
    elsif ! pull_requests.is_a? Array
      raise "Unexpected object type passed: #{pull_requests.class.name}"
    end

    response = {}
    pull_requests.each do |pr|
      pr_date = pr.created_at.at_beginning_of_day#.to_i
        # using epoch time so that we don't have to worry
        # about different date objects w/same time as keys 
      unless response.has_key? pr_date
        response[pr_date] = []
      end
      response[pr_date] << pr
    end
    response.keys.each do |date|
      response[date].sort_by!(&:created_at)
    end
    return response
  end

end
