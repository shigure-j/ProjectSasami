class Stage < ApplicationRecord
  has_many :formats
  has_many :works
  has_many :projects, through: :works
  has_many :designs, through: :works
  has_many :owners, through: :works
end
