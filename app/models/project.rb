class Project < ApplicationRecord
  has_many :works
  has_many :owners, through: :works
  has_many :designs
  has_many :stages, through: :works

  validates :name, presence: true, uniqueness: true
end
