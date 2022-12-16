class CreateFormats < ActiveRecord::Migration[7.0]
  def change
    create_table :formats do |t|
      t.string :name
      t.text :format
      t.references :stage, null: true, foreign_key: true

      t.timestamps
    end
  end
end
