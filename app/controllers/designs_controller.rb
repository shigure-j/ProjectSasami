class DesignsController < ApplicationController
  include TableDataGen

  def associated_model
    Design
  end

  def show
    #@table_index = Work.attribute_names.dup.map {|n| n.sub(/_id$/, '')}
    work_table_by_category(associated_model.name.downcase.to_sym)
  end
end
