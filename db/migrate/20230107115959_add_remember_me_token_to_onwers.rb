class AddRememberMeTokenToOnwers < ActiveRecord::Migration[7.0]
  def self.up
    add_column :owners, :remember_me_token, :string, :default => nil
    add_column :owners, :remember_me_token_expires_at, :datetime, :default => nil

    add_index :owners, :remember_me_token
  end

  def self.down
    remove_index :owners, :remember_me_token

    remove_column :owners, :remember_me_token_expires_at
    remove_column :owners, :remember_me_token
  end
end
