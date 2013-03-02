class Contributor < ActiveRecord::Base
  belongs_to :project
  belongs_to :repo
  attr_accessible :avatar_url, :github_url, :last_contributed_at, :login, :name
end
