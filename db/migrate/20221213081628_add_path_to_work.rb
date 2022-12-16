class AddPathToWork < ActiveRecord::Migration[7.0]
  def change
    add_column :works, :path, :string
  end
end
