class AddGenderToSearchesTable < ActiveRecord::Migration
  def change
    add_column :searches, :gender, :integer
  end
end