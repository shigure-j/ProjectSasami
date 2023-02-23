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
    focus = params[:focus].nil? ? [] : params[:focus].split(",")
    parsed_table_param = parse_table_param params
    # Merge
    merge_result = Work.merge_works(
      works: @works,
      sub_tables: sub_tables,
      init_only: init_only,
      view_context: view_context,
      focus:  focus,
      sorter: parsed_table_param[:sorter],
      filter: parsed_table_param[:filter],
      search: parsed_table_param[:search],
      range:  parsed_table_param[:range]
    )

    # Response data
    common_col_opt = {
      filterControl: :select,
      sortable: true
    }
    columns = merge_result[:indexes].map do |idx|
      { field: idx, title: idx }.merge(common_col_opt).merge({
        filterData: "json:" + merge_result[:filter_data][idx].to_json,
        rowspan: (focus.empty? ? nil : 2)
      })
    end
    if focus.empty?
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
    else
      fix_cols = columns.size
      columns += @works.map { |work| {title: work.name, colspan: focus.size, align: :center} }
      columns = [columns] << @works.product(focus).map do |work, key|
        common_col_opt.merge({
          field: "#{work.id}.#{key}",
          title: key,
          filterControl: :input,
          align: :right
        })
      end
    end
    user_payload = {
      subs: merge_result[:sub_tables],
      keys: merge_result[:keys]
    }
    if init_only
      # Init for side page
      data_url = "/data/work?side=1&pagination=1&works=#{params[:works]}"
      data_url += "&sub=#{params[:sub]}" unless params[:sub].nil? 
      data_url += "&focus=#{params[:focus]}" unless params[:focus].nil?
      respon_data = {
        fixedColumns: true, fixedNumber: fix_cols, columns: columns,
        sidePagination: :server,
        pagination: true,
        url: data_url,
        userPayload: user_payload
      }
    elsif side_page
      # Data for side page
      respon_data = {rows: merge_result[:data], total: merge_result[:data_size]}
    else
      # Init + Data for client
      respon_data = {
        fixedColumns: true, fixedNumber: fix_cols, columns: columns,
        data: merge_result[:data],
        userPayload: user_payload
      }
    end

    # Response
    respond_to do |res|
      res.json { render json: respon_data }
    end
  end

  def export
    public_works = Work.filter_by_owner (logged_in? ? current_user : nil)

    # Work record
    begin
      @works = public_works.find params[:works].split(",")
    rescue
      #ActiveRecord::RecordNotFound
      render js: 'alert("Invalid request!");'
      return
    end

    # Param process
    sub_tables = params[:sub].nil? ? [] : params[:sub].split(",")
    @focus = params[:focus].nil? ? [] : params[:focus].split(",")
    parsed_table_param = parse_table_param params
    # Merge
    merge_result = Work.merge_works(
      works: @works,
      sub_tables: sub_tables,
      focus:  @focus,
      sorter: parsed_table_param[:sorter],
      filter: parsed_table_param[:filter],
      search: parsed_table_param[:search],
    )
    @data = merge_result[:data]
    @columns = merge_result[:indexes].map do |idx|
      [idx, idx]
    end
    if @focus.empty?
      @columns << [ "key", "key" ]
      @columns += @works.map do |work|
        [ work.id.to_s, work.name ]
      end
    else
      @columns += @works.product(@focus).map do |work, key|
        ["#{work.id}.#{key}", key]
      end
    end

    #render xlsx: "export"
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="export.xlsx"'
      }
    end
  end

  def get_summary
    #Parameters: {"search"=>"abc", "sort"=>"design", "order"=>"asc", "offset"=>"0", "limit"=>"10", "filter"=>"{\"name\":\"test\",\"project\":\"MC20\",\"design\":\"23\",\"stage\":\"44\"}", "_"=>"1672831883028", "work"=>{}}
    public_works = Work.filter_by_owner (logged_in? ? current_user : nil)

    # Param process
    parsed_table_param = parse_table_param params, sub_filter: {time: true, object: true}
    # up/down stream
    case parsed_table_param[:updown]
    when :up
      public_works = public_works.where id: (parsed_table_param[:updown_work].upstreams.map(&:id) << parsed_table_param[:updown_work].id)
    when :down
      public_works = public_works.where id: (parsed_table_param[:updown_work].downstreams.map(&:id) << parsed_table_param[:updown_work].id)
    end
    # default time sort
    if parsed_table_param[:sorter].empty?
      parsed_table_param[:sorter]["created_at"] = parsed_table_param[:updown].nil?
    end

    # output
    merge_result = Work.merge_summary(
      works:  public_works,
      sorter: parsed_table_param[:sorter],
      filter: parsed_table_param[:filter],
      search: parsed_table_param[:search],
      range:  parsed_table_param[:range]
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
    i_params.delete :owner
    i_params[:pictures].shift unless i_params[:picture].nil?
    i_params[:project]    = Project.find_or_create_by! name: work_params[:project]
    i_params[:stage]      = Stage.find_or_create_by! name: work_params[:stage]
    i_params[:design]     = Design.find_or_create_by! name: work_params[:design], project: i_params[:project]
    i_params[:upstream]   = Work.find_by id: work_params[:upstream].to_i unless work_params[:upstream].nil?
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
    if i_params[:owner].nil? 
      if (work_params[:owner].nil? || work_params[:signature].nil?)
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
    end

    @work = Work.new(i_params)
    @work.attach_datas data_content

    if @work.save
      respond_to do |res|
        res.html { redirect_to @work }
        res.json { render json: {status: :done, message: "Uploaed as #{@work.id}"} }
      end

      # Notifi
      NotificationChannel.broadcast_to (@work.is_private ? @work.owner : nil), {
        title: "New upload from #{@work.owner.name}",
        body: [
                "<span class='align-middle mx-2 h5'>#{@work.name}</span>",
                "<span class='align-middle mx-1 badge text-bg-primary'  >#{@work.project.name}</span>",
                "<span class='align-middle mx-1 badge text-bg-secondary'>#{@work.design.name} </span>",
                "<span class='align-middle mx-1 badge text-bg-info'     >#{@work.stage.name}  </span>",
                "<div class='d-flex justify-content-end mt-2 pt-2 border-top'>",
                (view_context.link_to "View", @work, class: "link-primary", data: {turbo: false}),
                "</div>"
              ].join,
        time: (Time.now.strftime "%a %m/%d %H:%M"),
        timeout: 0
      }
    else
      respond_to do |res|
        res.html { render :new, status: :unprocessable_entity }
        res.json { render json: {status: :false, message: "Failed to save work, check input"} }
      end
    end

  end

  def parse_table_param(params, sub_filter: {time: false, object: false})
    objs = sub_filter[:object] ? {
      "project" => Project,
      "design" => Design,
      "stage" => Stage,
      "owner" => Owner
    } : {}
    range = if params[:offset].nil? || params[:limit].nil?
              nil
            else
              params[:offset].to_i...(params[:offset].to_i + params[:limit].to_i)
            end
    filter = if params[:filter].nil?
                {}
             else
               JSON.parse(params[:filter]).map do |name, value|
                 if sub_filter[:object] && name.eql?("relationship")
                   ["upstream", {name: value}]
                 elsif sub_filter[:object] && objs.key?(name)
                   #[[name, :name].join("."), value]
                   [name, {name: value}]
                 elsif sub_filter[:object] && name.match?("created_at")
                   time_start, time_stop = value.split("~").map {|n| Time.parse n}
                   if time_stop.nil?
                     ["created_at", (time_start.midnight)..(time_start.end_of_day)]
                   else
                     ["created_at", time_start.midnight..time_stop.end_of_day]
                   end
                 else
                   [name, value]
                 end
               end.to_h
             end
    sorter =  if !params[:multiSort].nil?
                sorter = params[:multiSort].values.map do |n|
                  [n[:sortName], n[:sortOrder].eql?("desc")]
                end.to_h
              elsif !params[:sort].nil?
                { params[:sort] => params[:order].eql?("desc") }
              else
                {}
              end
    if !params[:upstreams_of].nil?
      updown_work = Work.find_by id: params[:upstreams_of]
      unless updown_work.nil?
        updown = :up
      end
    elsif !params[:downstreams_of].nil?
      updown_work = Work.find_by id: params[:downstreams_of]
      unless updown_work.nil?
        updown = :down
      end
    else
      updown_work = nil
      updown = nil
    end
    return {
      search: params[:search],
      filter: filter,
      sorter: sorter,
      range:  range,
      updown: updown,
      updown_work: updown_work
    }
  end

  #def gen_excel(datas)
  #  workbook  = RubyXL::Workbook.new
  #  worksheet = workbook.add_worksheet('table')
  #  datas[:indexes].each_with_index do |index, col_num|
  #    worksheet.add_cell(0, col_num, index)
  #  end
  #  datas[:data].each_with_index do |data, row_num|
  #    data.each do |index, value|
  #      col_num = datas[:indexes].find_index index
  #      worksheet.add_cell(row_num.next, col_num, value) unless col_num.nil?
  #    end
  #  end
  #end

private
  def work_params
    params.require(:work).permit(:name, :design, :project, :path, :owner, :stage, :start_time, :end_time, :data, :signature, :is_private, :upstream, pictures: [])
  end
end
