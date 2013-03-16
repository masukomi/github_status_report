class AddNumericTicketsToRepo < ActiveRecord::Migration
  def change
    add_column :repos, :numeric_tickets, :boolean
  end
end
