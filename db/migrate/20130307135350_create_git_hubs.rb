class CreateGitHubs < ActiveRecord::Migration
  def up
    create_table :git_hubs do |t|
      t.string :name
      t.string :domain
      t.string :api_endpoint
      t.string :client_id
      t.string :client_secret

      t.timestamps
    end

    # TODO: remove domain and api_endpoint from repo table
    remove_column :repos, :host if column_exists? :repos, :host
    remove_column :repos, :api_endpoint if column_exists? :repos, :api_endpoint
    add_column :repos, :git_hub_id, :integer unless column_exists? :repos, :git_hub_id
  end
  def down
    drop_table :git_hubs
    #er... this won't be good but not much we can do about it.
    add_column :repos, :host, :string unless column_exists? :repos, :host
    add_column :repos, :api_endpoint, :string unless column_exists? :repos, :api_endpoint
    remove_column :repos, :git_hub_id if column_exists? :repos, :git_hub_id
  end
end
