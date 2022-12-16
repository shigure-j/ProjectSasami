class AddRefToWorks < ActiveRecord::Migration[7.0]
  def change
    add_reference :works, :project, null: false, foreign_key: true
    add_reference :works, :owner, null: false, foreign_key: true
  end
end
