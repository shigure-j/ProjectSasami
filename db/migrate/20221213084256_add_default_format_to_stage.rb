class AddDefaultFormatToStage < ActiveRecord::Migration[7.0]
  def change
    add_column :stages, :default_format, :integer
  end
end
