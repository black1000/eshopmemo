class FixItemsColumns < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:items, :name)
      remove_column :items, :name, :string
    end


    add_column :items, :title, :string unless column_exists?(:items, :title)
    add_column :items, :image_url, :string unless column_exists?(:items, :image_url)
    add_column :items, :tag_id, :bigint unless column_exists?(:items, :tag_id)
  end
end
