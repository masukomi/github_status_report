class PullRequest < ActiveRecord::Base
  belongs_to :project
  belongs_to :contributor
  belongs_to :repo
  attr_accessible :ticket_id, :title, :type, :created_at

  def self.create_from_hash_and_repo(github_hash, repo) 
    # github_hash comes from the github pull request api
    # see http://developer.github.com/v3/pulls/
    
    # this object will NOT be saved
    pr = PullRequest.new(:repo=>repo)
    


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
end
