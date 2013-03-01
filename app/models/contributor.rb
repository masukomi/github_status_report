class Contributor < ActiveRecord::Base
  attr_accessible :avatar_url, :github_url, :last_contributed_at, :login, :name
end
