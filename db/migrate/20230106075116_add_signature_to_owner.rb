class AddSignatureToOwner < ActiveRecord::Migration[7.0]
  def change
    add_column :owners, :signature, :string
  end
end
