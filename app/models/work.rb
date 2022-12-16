class Work < ApplicationRecord
  has_one_attached :data
  belongs_to :owner
  belongs_to :project
  belongs_to :design
  belongs_to :stage

  def attributes_with_references
    self.attributes.to_a.map do |attr|
      if attr[0].match?("_id$")
        ref_name = attr[0].sub(/_id$/,'')
        [ref_name , self.instance_eval(ref_name)]
      elsif attr[0].eql?("name")
        [attr[0], self]
      else
        attr
      end
    end.to_h
  end
end
