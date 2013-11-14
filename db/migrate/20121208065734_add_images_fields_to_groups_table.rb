class AddImagesFieldsToGroupsTable < ActiveRecord::Migration
  def change
    add_column :groups, :small_image_url, :string
    add_column :groups, :image_url, :string
  end
end
