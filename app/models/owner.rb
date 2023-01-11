class Owner < ApplicationRecord
  authenticates_with_sorcery!

  has_many :works
  has_many :projects, through: :works
  has_many :designs, through: :works
  has_many :stages, through: :works

  validates :signature, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  def self.get_or_create(name: nil, signature: nil)
    begin
      Owner.find_or_create_by! name: name, signature: signature
    rescue
      nil
    end
  end
end
