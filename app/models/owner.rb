class Owner < ApplicationRecord
  authenticates_with_sorcery!

  has_many :works
  has_many :projects, through: :works
  has_many :designs, through: :works
  has_many :stages, through: :works

  validates :signature, uniqueness: true
  validates :name, uniqueness: true
end
