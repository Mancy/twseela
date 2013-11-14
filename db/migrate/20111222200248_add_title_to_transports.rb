class AddTitleToTransports < ActiveRecord::Migration
  def change
    add_column :transports, :title, :string
  end
end
