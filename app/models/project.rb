class Project < ActiveRecord::Base
  belongs_to :repo
  has_many :contributers
  attr_accessible :name

  validates :name, :uniqueness => {:scope => :repo_id}
end
