class PullRequest < ActiveRecord::Base
  belongs_to :project
  belongs_to :contributor
  belongs_to :repo
  attr_accessible :ticket_id, :title, :type
end
