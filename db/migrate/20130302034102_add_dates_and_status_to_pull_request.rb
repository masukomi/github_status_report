class AddDatesAndStatusToPullRequest < ActiveRecord::Migration
  def change
    add_column :pull_requests, :closed_at, :datetime
    add_column :pull_requests, :merged_at, :datetime
    add_column :pull_requests, :status, :string
  end
end
