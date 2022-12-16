class AddStageToWork < ActiveRecord::Migration[7.0]
  def change
    add_reference :works, :stage, null: false, foreign_key: true
  end
end
