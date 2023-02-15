class AddUpstreamToWork < ActiveRecord::Migration[7.0]
  def change
    add_reference :works, :upstream, null: true, foreign_key: { to_table: :works }
  end
end
