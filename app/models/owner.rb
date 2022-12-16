class Owner < ApplicationRecord
  has_many :works
  has_many :projects, through: :works
  has_many :designs, through: :works
  has_many :stages, through: :works
end
