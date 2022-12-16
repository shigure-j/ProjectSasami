class AddDesignToWork < ActiveRecord::Migration[7.0]
  def change
    add_reference :works, :design, null: false, foreign_key: true
  end
end
