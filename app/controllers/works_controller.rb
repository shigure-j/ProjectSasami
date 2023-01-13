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
        works.map(&:destroy)
      end
    end

    render :result
  end

  def get_work
    side_page = !params[:pagination].nil? && params[:pagination].eql?("1")
    init_only = side_page && params[:side].nil?
    public_works = Work.filter_by_owner (logged_in? ? current_user : nil)

    # Work record
    begin
      @works = public_works.find params[:works].split(",")
    rescue
      #ActiveRecord::RecordNotFound
      render js: 'alert("Invalid request!");'
      return
    end

    #Parameters: {"search"=>"abc", "sort"=>"design", "order"=>"asc", "offset"=>"0", "limit"=>"10", "filter"=>"{\"name\":\"test\",\"project\":\"MC20\",\"design\":\"23\",\"stage\":\"44\"}", "_"=>"1672831883028", "work"=>{}}
    #"multiSort"=>{"0"=>{"sortName"=>"key", "sortOrder"=>"asc"}, "1"=>{"sortName"=>"5", "sortOrder"=>"asc"}, "2"=>{"sortName"=>"4", "sortOrder"=>"asc"}}
    # Param process
    sub_tables = params[:sub].nil? ? [] : params[:sub].split(",")
    range = if params[:offset].nil? || params[:limit].nil?
              nil
            else
              params[:offset].to_i...(params[:offset].to_i + params[:limit].to_i)
            end
    filter = params[:filter].nil? ? {} : JSON.parse(params[:filter])
    sorter =  if !params[:multiSort].nil?
                sorter = params[:multiSort].values.map do |n|
                  [n[:sortName], n[:sortOrder].eql?("desc")]
                end.to_h
              elsif !params[:sort].nil?
                sorter = { params[:sort] => params[:order].eql?("desc") }
              else
                sorter = {}
              end

    # Merge
    merge_result = Work.merge_works(
      works: @works,
      sub_tables: sub_tables,
      filter: filter,
      search: params[:search],
      sorter: sorter,
      init_only: init_only,
      range: range,
      view_context: view_context
    )

    # Response data
    common_col_opt = {
      filterControl: :select,
      sortable: true
    }
    columns = merge_result[:indexes].map do |idx|
      { field: idx, title: idx }.merge(common_col_opt).merge({
        filterData: "json:" + merge_result[:filter_data][idx].to_json
      })
    end
    columns << { field: :key, title: :key }.merge(common_col_opt).merge({
      filterData: "json:" + merge_result[:filter_data]["key"].to_json
    })
    fix_cols = columns.size
    columns += @works.map do |work|
      common_col_opt.merge({
        field: work.id,
        title: work.name,
        filterControl: :input,
        align: :right
      })
    end
    if init_only
      respon_data = {
        fixedColumns: true, fixedNumber: fix_cols, columns: columns,
        sidePagination: :server,
        pagination: true,
        url: "/data/work?side=1&pagination=1&works=#{params[:works]}" + (params[:sub].nil? ? "" : "&sub=#{params[:sub]}")
      }
    elsif side_page
      respon_data = {rows: merge_result[:data], total: merge_result[:data_size]}
    else
      respon_data = {fixedColumns: true, fixedNumber: fix_cols, columns: columns, data: merge_result[:data]}
    end

    # Response
    respond_to do |res|
      res.js { render 'dashboard/table', locals: {
          table_id: "work_table", table_format: [],
          table_data: respon_data, sub_tables: merge_result[:sub_tables]
        }
      }
      res.json { render json: respon_data }
    end
  end

  def get_summary
    #Parameters: {"search"=>"abc", "sort"=>"design", "order"=>"asc", "offset"=>"0", "limit"=>"10", "filter"=>"{\"name\":\"test\",\"project\":\"MC20\",\"design\":\"23\",\"stage\":\"44\"}", "_"=>"1672831883028", "work"=>{}}
    public_works = Work.filter_by_owner (logged_in? ? current_user : nil)

    # Param process
    range = if params[:offset].nil? || params[:limit].nil?
              nil
            else
              params[:offset].to_i...(params[:offset].to_i + params[:limit].to_i)
            end
    # filter
    objs = {
      "project" => Project,
      "design" => Design,
      "stage" => Stage,
      "owner" => Owner
    }
    filter = {}
    unless params[:filter].nil?
      JSON.parse(params[:filter]).each do |name, value|
        if objs.key? name
          filter[name] = objs[name].find_by(name: value)
        elsif name.match?("time")
          filter[name] = Time.parse(value)
        else
          filter[name] = value
        end
      end
    end
    # sort
    if params[:sort].nil?
      sort_key = "created_at"
      sort_desc = true
    else
      sort_key = (objs.key? params[:sort]) ? objs[params[:sort]] : params[:sort]
      sort_desc = params[:order].eql?("desc")
    end

    # output
    merge_result = Work.merge_summary(
      works: public_works,
      filter: filter,
      search: params[:search],
      sort: sort_key,
      desc: sort_desc,
      range: range
    )

    # Response
    respon_data = {rows: merge_result[:data], total: merge_result[:total], totalNotFiltered: Work.count}

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

    # Param process
    i_params.delete :data
    i_params.delete :signature
    i_params[:pictures].shift unless i_params[:picture].nil?
    i_params[:project]    = Project.find_or_create_by! name: work_params[:project]
    i_params[:stage]      = Stage.find_or_create_by! name: work_params[:stage]
    i_params[:design]     = Design.find_or_create_by! name: work_params[:design], project: i_params[:project]
    i_params[:is_private] = false if work_params[:is_private].nil?
    i_params[:owner]      = current_user if logged_in?

    # Data check
    begin
      data_content = JSON.parse(work_params[:data].read)
    rescue
      respond_to do |res|
        res.html { render :new, status: :unprocessable_entity }
        res.json { render json: {status: :false, message: "Data json wrong format"} }
      end
    end

    # Owner check
    if i_params[:owner].nil? && work_params[:signature].nil?
      respond_to do |res|
        res.html { render :new, status: :unprocessable_entity }
        res.json { render json: {status: :failed, message: "Empty user name or signature"} }
      end
      return
    else
      i_params[:owner] = Owner.get_or_create name: work_params[:owner], signature: work_params[:signature].read
      if i_params[:owner].nil?
        respond_to do |res|
          res.html { render :new, status: :unprocessable_entity }
          res.json { render json: {status: :failed, message: "User name and signature mismatch"} }
        end
        return
      end
    end

    @work = Work.new(i_params)
    @work.attach_datas data_content

    if @work.save
      respond_to do |res|
        res.html { redirect_to @work }
        res.json { render json: {status: :done, message: "Uploaed as #{@work.id}"} }
      end
    else
      respond_to do |res|
        res.html { render :new, status: :unprocessable_entity }
        res.json { render json: {status: :false, message: "Failed to save work, check input"} }
      end
    end

  end

private
  def work_params
    params.require(:work).permit(:name, :design, :project, :path, :owner, :stage, :start_time, :end_time, :data, :signature, :is_private, pictures: [])
  end
end
