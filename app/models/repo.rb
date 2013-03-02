class Repo < ActiveRecord::Base
  has_many :projects
  has_many :contributers
  attr_accessible :api_endpoint, :branch_naming_convention, :github_name, :host, :oauth_token, :ticket_url
end
