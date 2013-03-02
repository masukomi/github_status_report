class AddBranchNamesToPullRequest < ActiveRecord::Migration
  def change
    add_column :pull_requests, :from_branch, :string
    add_column :pull_requests, :to_branch, :string
  end
end
