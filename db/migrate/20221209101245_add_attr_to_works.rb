class AddAttrToWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :works, :start_time, :datetime
    add_column :works, :end_time, :datetime
  end
end
