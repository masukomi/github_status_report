class PullRequest #< ActiveRecord::Base
  UNKNOWN_PROJECT_NAME='unknown'
  KNOWN_TYPES=['bug', 'add', 'sec', nil]
  #belongs_to :project
  #belongs_to :contributor  # who created the pull request
  #belongs_to :repo
  attr_accessor :ticket_id,
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
                  :url, # links to this pull request's page 
                  :bad_ticket_id # sometimes there's a ticket id that's bad


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
    bnd = self.extract_data_from_branch_name(pr.from_branch, repo)
      # bnd: Branch Name Data
    pr.raw_bn_data=bnd
    pr.ticket_id = bnd[:ticket]   #might be nil
    pr.bad_ticket_id = bnd[:bad_ticket_id]
    if KNOWN_TYPES.include? bnd[:type]
      pr.type = bnd[:type]          # might be nil
    else
      pr.type = nil
    end

    project_name = nil
    if project_names.size() == 0
      project_name = bnd[:project]
    else
      if project_names.include? bnd[:project]
        project_name = bnd[:project]
      else
        project_name = UNKNOWN_PROJECT_NAME
      end
    end
    if project_names.include? project_name
      pr.project = repo.projects.reject{|p|p.name != project_name}.first
    else
      begin
        new_project = Project.create(:name=>project_name)
        new_project.repo = repo
        new_project.save!()
        pr.project = new_project
      rescue
        # this can happen in an extreme dev only
        # edge case that shouldn't ever happen
        Rails.logger.warning("Tried to create new project that already existed")
      end
      project_names << project_name
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
    
    if (pull_data['user'] and pull_data['user'].size() > 0)
      creator = Contributor.new(
        :login=>pull_data['user']['login'],
        :github_url=>repo.git_hub.convert_api_url_to_web(
          pull_data['user']['url'], :user
        )
      )
      pr.creator = creator
    end
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
  def self.extract_data_from_branch_name(branch_name, repo)
    regexp = repo.get_regexp_for_branch_names()
    keys = repo.get_branch_name_keys()
    data = {:bad_ticket_id=>false}
    m = regexp.match(branch_name)
    matched_with_number = repo.numeric_tickets? and ! m.nil?
    if m.nil? and repo.numeric_tickets?
      # the branch name not matching the expected pattern
      # is almost guaranteed to be because of not finding ticket info.
      regexp = repo.get_regexp_for_branch_names({:ignore_numeric=>true})
      m = regexp.match(branch_name)
      unless m.nil?
        data[:bad_ticket_id] = true
      end
    end

    unless m.nil?
      (1..keys.length).each do |idx|
        key = keys[idx - 1] # keys are symbols
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
