class AddSavedToTransportsTable < ActiveRecord::Migration
  def change
    add_column :transports, :templ_saved, :boolean
  end
end
