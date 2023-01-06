class Work < ApplicationRecord
  has_one_attached :data
  has_many_attached :pictures
  belongs_to :owner
  belongs_to :project
  belongs_to :design
  belongs_to :stage

  def attributes_with_references(name_only=false)
    self.attributes.to_a.map do |attr|
      if attr[0].match?("_id$")
        ref_name = attr[0].sub(/_id$/,'')
        if name_only
          [ref_name , self.instance_eval(ref_name).name]
        else
          [ref_name , self.instance_eval(ref_name)]
        end
      elsif attr[0].eql?("name")
        if name_only
          [attr[0], self.name]
        else
          [attr[0], self]
        end
      else
        attr
      end
    end.to_h
  end
end
