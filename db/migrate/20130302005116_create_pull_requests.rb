class CreatePullRequests < ActiveRecord::Migration
  def change
    create_table :pull_requests do |t|
      t.string :title
      t.string :type
      t.string :ticket_id
      t.references :project
      t.references :contributor
      t.references :repo
      t.timestamps
    end
  end
end
