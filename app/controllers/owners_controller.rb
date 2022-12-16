class OwnersController < ApplicationController
  include TableDataGen

  def associated_model
    Owner
  end

  def show
    #@table_index = Work.attribute_names.dup.map {|n| n.sub(/_id$/, '')} ; # for format creation only
    work_table_by_category(associated_model.name.downcase.to_sym)
  end
end
