class Contributor < ActiveRecord::Base
  belongs_to :project
  belongs_to :repo
  attr_accessible :avatar_url, :github_url, :last_contributed_at, :login, :name
  validates :login, :uniqueness => {:scope => :repo_id}
    # it's unlikely that someone using this would connect to a repo in
    # github.com AND a GitHub Enterprise install but if they do we could
    # end up with login conflicts if we don't constrain uniqueness 
    # to names within the same repo
end
