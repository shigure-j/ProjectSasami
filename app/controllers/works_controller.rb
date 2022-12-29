class WorksController < ApplicationController
  protect_from_forgery :except => [:create]

  def gen_works_summary(works)
    merge_table = works.map { |work| work.attributes_with_references true }
    format = Format.find_by(name: :work).get_format
    table_id = "dashboard_view"

    # Response
    common_col_opt = {
      filterControl: :select,
      sortable: true
    }
    columns = [{ field: nil, title: nil, checkbox: true }, { field: :id, title: :id, visible: false }]
    no = 0
    format.each do |key, value| 
      columns << { field: key, title: key, formatter: "cellFormatter#{table_id}#{no}" }.merge(common_col_opt)
      no += 1
    end
    respon_data = {columns: columns, data: merge_table}

    respond_to do |res|
      res.js { render 'dashboard/table', locals: {
          table_id: table_id, table_format: format,
          table_data: respon_data
        }
      }
    end
  end

  def gen_works_detail(works)
    works_data = works.map {|work| JSON.parse Zlib::inflate(work.data.download)}
    table_id = "work_table"

    # Get all index
    indexes = []
    merge_data = {}
    works.each_with_index do |work, index|
      work_data = works_data[index]
      work_data.each do |record|
        value = record.delete "value"
        indexes += record.keys
        if merge_data[record].nil? 
          merge_data[record] = {work.id => value}
        else
          merge_data[record][work.id] = value
        end
      end
    end
    indexes.uniq!
    indexes.delete("key")

    # Gen table
    merge_table = []
    merge_data.each do |record, values|
      merge_table << (record.merge values)
    end

    # Response
    common_col_opt = {
      filterControl: :select,
      sortable: true
    }
    columns = indexes.map { |idx| { field: idx, title: idx }.merge common_col_opt }
    columns << { field: :key, title: :key }.merge(common_col_opt)
    columns += works.map { |work| { field: work.id, title: work.name }.merge common_col_opt }
    respon_data = {columns: columns, data: merge_table}

    #render json: {columns: columns, data: merge_table}.to_json
    respond_to do |res|
      res.js { render 'dashboard/table', locals: {
          table_id: table_id, table_format: [],
          table_data: respon_data
        }
      }
    end
  end

  def data
    if params.key?(:works)
      @works = Work.find(params[:works].split(","))
      respon = gen_works_detail @works
    else
      #TODO
      @works = Work.all
      respon = gen_works_summary @works
    end
  end

  def show
    redirect_to "/detail?works=" + params[:id]
    #@work = Work.find(params[:id])
    #@format = Format.find_by(id: @work.stage.default_format) ; #TODO
  end

  def new
    @work = Work.new
  end

  def create
    i_params = work_params
    data_content = JSON.parse(work_params[:data].read)

    comp_file = Tempfile.new(encoding: 'ascii-8bit')
    comp_file.write Zlib::deflate(data_content.to_json)
    i_params[:data].tempfile = comp_file

    [Project, Owner, Stage].each do |obj_class|
      obj_class_name = obj_class.name.downcase
      n_obj_name = i_params[obj_class_name.to_sym]
      obj = obj_class.find_by name: n_obj_name
      if obj.nil?
        obj = obj_class.new(name: n_obj_name)
        obj.save
      end
      i_params[obj_class_name.to_sym] = obj
    end

    design = i_params[:project].designs.find_by name: i_params[:design]
    if design.nil?
      design = i_params[:project].designs.create(name: i_params[:design])
      design.save
    end
    i_params[:design] = design

    #if i_params[:stage].default_format.nil? 
    #  format_obj = i_params[:stage].formats.create(name: :default)
    #  format_obj.init_format_by(data_content)
    #  format_obj.save
    #  i_params[:stage].default_format = format_obj.id
    #  i_params[:stage].save
    #end

    @work = Work.new(i_params)

    if @work.save
      redirect_to @work
    else
      render :new, status: :unprocessable_entity
    end

    comp_file.close
  end

private
  def work_params
    params.require(:work).permit(:name, :design, :project, :path, :owner, :stage, :start_time, :end_time, :data)
  end

  def formatter(value, type, opt)
    case type
    when "int"
      value.to_i
    when "float"
      format("%.#{opt}f", value)
    when "datetime"
      Time.parse(value).strftime(opt) ; #"%Y/%m/%d %H:%M"
    when "path"
      '<button type="button" class="btn btn-secondary focus-popover" data-clipboard-action="copy" data-bs-container="body" data-bs-toggle="popover" data-bs-placement="top" data-bs-trigger="hover focus" data-clipboard-text="' + value + '" data-bs-content="' + value + '"> copy </button>'
    else
      value
    end
  end
end
