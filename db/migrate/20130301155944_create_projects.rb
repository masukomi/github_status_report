class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.references :repo
      t.timestamps
    end
    add_index :projects, :name
    add_index :projects, :repo_id
  end
end
