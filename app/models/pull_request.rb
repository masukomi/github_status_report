class PullRequest #< ActiveRecord::Base
  UNKNOWN_PROJECT_NAME='unknown'
  KNOWN_TYPES=['bug', 'add', nil]
  #belongs_to :project
  #belongs_to :contributor  # who created the pull request
  #belongs_to :repo
  attr_accessor :ticket_id,
  #attr_accessible :ticket_id, 
                  :repo,
                  :project,
                  :title, 
                  :type, 
                  :created_at, 
                  :closed_at, 
                  :merged_at, 
                  :status, 
                  :from_branch, 
                  :to_branch,
                  :creator, # (Contributor) who created the pull request
                  :assignee, # (Contributor) who's assigned to the pull request (reviewer)
                  :number, 
                  :raw_bn_data,
                  :url # links to this pull request's page 



  def self.create_from_pull_and_repo(pull_data, repo) 
    # pull_data is a hash that comes from the github pull request api
    # see http://developer.github.com/v3/pulls/

    project_names = repo.projects.collect(&:name)
    
    # this object will NOT be saved
    pr = PullRequest.new()
    pr.repo = repo
    pr.from_branch = self.get_branch_from_pull(pull_data, :from)
    pr.to_branch = self.get_branch_from_pull(pull_data, :to)
    #to_branch = get_branch_from_pull(p, :to)
    bnd = self.extract_data_from_branch_name(pr.from_branch, repo.branch_naming_convention)
      # bnd: Branch Name Data
    pr.raw_bn_data=bnd
    pr.ticket_id = bnd[:ticket]   #might be nil
    if KNOWN_TYPES.include? bnd[:type]
      pr.type = bnd[:type]          # might be nil
    else
      pr.type = nil
    end

    if project_names.size() == 0
      pr.project = bnd[:project]
    else
      if project_names.include? bnd[:project]
        pr.project = bnd[:project]
      else
        pr.project = UNKNOWN_PROJECT_NAME
      end
    end
    if pr.title != pr.from_branch.sub('_', ' ')
      pr.title = pull_data['title']
    else
      # if the user took the default, which just de-underscores 
      # the branch name, we'd rather use the extracted title
      # without the extraneous embeded data
      pr.title = bnd[:title]
    end

    #TODO make the Contributor model suck down all the pertinent info
    # and create a new object if one wasn't found with that login
    # *in that repo*
    creator = Contributor.new(
      :login=>pull_data['user']['login'],
      :github_url=>repo.git_hub.convert_api_url_to_web(
        pull_data['user']['url'], :user
      )
    )
    pr.creator = creator
    if (pull_data['assignee'] and pull_data['assignee'].size() > 0)
      assignee = Contributor.new(
        :login=>pull_data['assignee']['login'],
        :github_url=> repo.git_hub.convert_api_url_to_web(
        pull_data['assignee']['url'], :user
        )
      )
      pr.assignee = assignee
    end


    pr.created_at = pull_data['created_at'].nil? ? nil : Date.parse(pull_data['created_at'])
    pr.merged_at = pull_data['merged_at'].nil? ? nil : Date.parse(pull_data['merged_at']) 
    pr.closed_at = pull_data['closed_at'].nil? ? nil : Date.parse(pull_data['closed_at']) 

    pr.url = pull_data['url'].sub('/api/v3/repos', '').sub('pulls/', 'pull/')\
              .sub('api.github.com', 'github.com') # for those using the main one 
    pr.number =pull_data['number']

    return pr

  end

  # Public: extracts the data from the branch name
  #
  # branch_name - the name from which to extract data
  # branch_naming_convention - tells us how to parse the branch name
  def self.extract_data_from_branch_name(branch_name, branch_naming_convention)
    keys = branch_naming_convention.split('_').map{
      |key| key.start_with?(':') ? key[1..key.length] : key
    }
    # an array of the things that we need to look for in the name
    regexp_string = ('(.*?)_' * (keys.length() -1)) + "(.*)"

    data = {}
    m = /#{regexp_string}/.match(branch_name)
    unless m.nil?
      (1..keys.length).each do |idx|
        key = keys[idx - 1].to_sym
        data[key] = m[idx]
      end
    end
    return data
  end

  def self.get_branch_from_pull(pull, from_or_to)
    full_branch = nil
    if from_or_to == :from
      full_branch = pull['head']['label']
    elsif from_or_to == :to
      full_branch = pull['base']['label']
    else
      raise "Unexpected branch symbol"
    end
    return full_branch.sub(/.*?:/, '')
  end

  
end
