class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.string :name
      t.string :login
      t.string :github_url
      t.string :avatar_url
      t.datetime :last_contributed_at
      t.references :repo, :project
      t.timestamps
    end
    add_index :contributors, :login
  end
end
