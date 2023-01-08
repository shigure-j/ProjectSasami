class WorksController < ApplicationController
  protect_from_forgery :except => [:create]

  def edit
    @message = []
    unless logged_in?
      @message << "You need login"
    else
      works = Work.find params[:works].split(",")
      other_works = works.select {|work| ! work.owner.eql? current_user}
      unless other_works.empty?
        @message << "Failed to edit #{other_works.size} works of others owners."
      end
      works -= other_works
      if works.empty?
        @message << "No works changed."
      else
        @message << "Changed #{works.size} works to #{params[:is_private].eql?("1") ? "private" : "public"}."
        works.each { |work| work.update is_private: params[:is_private] }
      end
    end

    render :result
  end

  def delete
    @message = []
    unless logged_in?
      @message << "You need login"
    else
      works = Work.find params[:works].split(",")
      other_works = works.select {|work| ! work.owner.eql? current_user}
      unless other_works.empty?
        @message << "Failed to delete #{other_works.size} works of others owners."
      end
      works -= other_works
      if works.empty?
        @message << "No works deleted."
      else
        @message << "deleted #{works.size} works."
        works.map(&:delete)
      end
    end

    render :result
  end

  def get_work
    public_works = Work.filter_by_owner (logged_in? ? current_user : nil)

    begin
      works = public_works.find params[:works].split(",")
    rescue
      #ActiveRecord::RecordNotFound
      render js: 'alert("Invalid request!");'
      return
    end

    works_data = works.map {|work| JSON.parse Zlib::inflate(work.data.download)}
    works_pics = works.map do |work|
      work.pictures.map do |pic| 
        view_context.image_tag pic, height: 80, onclick: "modalView('#{view_context.image_tag pic, id: "modal_view", class: "img-fluid"}')"
      end
    end
    table_id = "work_table"

    # Get all index
    indexes = []
    merge_data = {}
    works.each_with_index do |work, index|
      work_data = works_data[index]
      work_data.each do |record|
        value = record.delete "value"
        indexes += record.keys
        pic_flag, pic_no = value.split(":")
        if pic_flag.eql?("picture") && pic_no.match?(/[0-9]+/)
          value = works_pics[index][pic_no.to_i]
        end
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
    fix_cols = columns.size
    columns += works.map { |work| { field: work.id, title: work.name }.merge common_col_opt }
    #columns += works.map { |work| { field: work.id, title: work.name } }
    respon_data = {fixedColumns: true, fixedNumber: fix_cols, columns: columns, data: merge_table}

    #TODO
    #render json: {columns: columns, data: merge_table}.to_json
    respond_to do |res|
      res.js { render 'dashboard/table', locals: {
          table_id: table_id, table_format: [],
          table_data: respon_data, table_pictures: works_pics
        }
      }
    end
  end

  def get_summary
    #Parameters: {"search"=>"abc", "sort"=>"design", "order"=>"asc", "offset"=>"0", "limit"=>"10", "filter"=>"{\"name\":\"test\",\"project\":\"MC20\",\"design\":\"23\",\"stage\":\"44\"}", "_"=>"1672831883028", "work"=>{}}
    #
    #private_works = Work.where is_private: true
    #if logged_in?
    #  owner_works = private_works.where owner: current_user
    #  private_works.excluding! owner_works
    #end
    #public_works = Work.excluding private_works
    public_works = Work.filter_by_owner (logged_in? ? current_user : nil)
    # filter
    objs = {
      "project" => Project,
      "design" => Design,
      "stage" => Stage,
      "owner" => Owner
    }
    if params["filter"].nil?
      filtered_works = public_works
    else
      filter = {}
      JSON.parse(params["filter"]).each do |name, value|
        if objs.key?(name)
          id = objs[name].find_by(name: value)
          filter[name + "_id"] = id
        elsif name.match?("time")
          filter[name] = Time.parse(value)
        else
          filter[name] = value
        end
      end
      filtered_works = public_works.where filter
    end
    # search
    if params["search"].empty?
      works = filtered_works
    else
      works = []
      filtered_works.each do |work|
        works << work if work.name.match?(params["search"])
      end
    end
    # sort
    sort_obj = nil
    if params["sort"].nil?
      sort_key = "created_at"
      sort_order = "desc"
    else
      sort_key = params["sort"]
      sort_order = params["order"]
    end
    if objs.key?(sort_key)
      sort_obj = objs[sort_key]
    end
    works = works.sort_by do |work|
      if sort_obj.nil?
        work.attribute_in_database(sort_key)
      else
        work.instance_eval(sort_key).name
      end
    end
    if sort_order.eql?("desc")
      works.reverse!
    end
    # output
    total = Work.count
    count = works.size
    range = params["offset"].to_i...(params["offset"].to_i + params["limit"].to_i)
    target_works = works[range]
    merge_table = target_works.map { |work| work.attributes_with_references true }

    # Response
    respon_data = {rows: merge_table, total: count, totalNotFiltered: total}

    render json: respon_data
  end

  def show
    redirect_to "/detail?works=" + params[:id]
    #@work = Work.find(params[:id])
    #@format = Format.find_by(id: @work.stage.default_format) ; #TODO
  end

  def new
    @work = Work.new
    @owner = (logged_in? ? current_user : nil)
  end

  def create
    i_params = work_params
    data_content = JSON.parse(work_params[:data].read)

    comp_file = Tempfile.new(encoding: 'ascii-8bit')
    comp_file.write Zlib::deflate(data_content.to_json)
    i_params[:data].tempfile = comp_file

    unless i_params[:picture].nil?
      i_params[:pictures].shift
    end

    [Project, Stage].each do |obj_class|
      obj_class_name = obj_class.name.downcase
      n_obj_name = work_params[obj_class_name.to_sym]
      obj = obj_class.find_by name: n_obj_name
      if obj.nil?
        obj = obj_class.new(name: n_obj_name)
        obj.save
      end
      i_params[obj_class_name.to_sym] = obj
    end

    if work_params[:signature].nil?
      respond_to do |res|
        res.html { render :new, status: :unprocessable_entity }
        res.json { render json: {status: :failed, message: "No user signature"} }
      end
      return
    end

    signature = work_params[:signature].read
    owner = Owner.find_by(name: work_params[:owner])
    if owner.nil?
      owner = Owner.new name: work_params[:owner], signature: signature
    elsif !owner.signature.eql? signature
      respond_to do |res|
        res.html { render :new, status: :unprocessable_entity }
        res.json { render json: {status: :failed, message: "User name and signature mismatch"} }
      end
      return
    end
    i_params.delete :signature
    i_params[:owner] = owner

    design = i_params[:project].designs.find_by name: i_params[:design]
    if design.nil?
      design = i_params[:project].designs.create(name: i_params[:design])
      design.save
    end
    i_params[:design] = design

    if work_params[:is_private].nil?
      i_params[:is_private] = false
    end

    @work = Work.new(i_params)

    if @work.save
      respond_to do |res|
        res.html { redirect_to @work }
        res.json { render json: {status: :done, message: "Uploaed as #{@work.id}"} }
      end
    else
      respond_to do |res|
        res.html { render :new, status: :unprocessable_entity }
        res.json { render json: {status: :false, message: "Wrong work format"} }
      end
    end

    comp_file.close
  end

private
  def work_params
    params.require(:work).permit(:name, :design, :project, :path, :owner, :stage, :start_time, :end_time, :data, :signature, :is_private, pictures: [])
  end
end
