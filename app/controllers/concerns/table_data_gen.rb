module TableDataGen
  extend ActiveSupport::Concern

  def work_table_by_category(format_name)
    obj = associated_model.find(params[:id])
    works = obj.works
    @table_data = works.map(&:attributes_with_references)
    @table_format = Format.find_by(name: format_name)
    render "dashboard/show"
  end
end
