class Design < ApplicationRecord
  has_many :works
  has_many :owners, through: :works
  has_many :stages, through: :works
  belongs_to :project

  validates :name, presence: true, uniqueness: { scope: :project_id }
end
