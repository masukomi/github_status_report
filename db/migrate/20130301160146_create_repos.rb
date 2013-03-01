class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :github_name
      t.string :oauth_token
      t.string :host
      t.string :api_endpoint
      t.string :ticket_url
      t.string :branch_naming_convention

      t.timestamps
    end
  end
end
