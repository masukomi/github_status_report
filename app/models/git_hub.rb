class GitHub < ActiveRecord::Base
  attr_accessible :api_endpoint, :client_id, :client_secret, :domain, :name
end
