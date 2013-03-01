class Repo < ActiveRecord::Base
  attr_accessible :api_endpoint, :branch_naming_convention, :github_name, :host, :oauth_token, :ticket_url
end
