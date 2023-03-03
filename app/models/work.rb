class Work < ApplicationRecord
  has_many_attached :datas
  has_many_attached :pictures
  belongs_to :owner
  belongs_to :project
  belongs_to :design
  belongs_to :stage
  has_many  :downstreams, class_name: "Work", foreign_key: "upstream_id"
  belongs_to  :upstream,  class_name: "Work", optional: true

  def attributes_with_references(name_only: false, with_relationshiop: true, access_owner: nil)
    (with_relationshiop ? {relationship: relationship(access_owner)} : {}).merge(
      self.attributes.to_a.map do |attr|
        if attr[0].match?("_id$")
          ref_name = attr[0].sub(/_id$/,'')
          if name_only
            [ref_name , (self.instance_eval(ref_name).name rescue nil)]
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
    )
  end

  def self.filter_by_owner(owner=nil)
    private_works = Work.where is_private: true
    unless owner.nil?
      owner_works = private_works.where owner: owner
      private_works.excluding! owner_works
    end
    public_works = Work.excluding private_works
  end

  def self.merge_summary(works: [], filter: {}, search: nil, sorter: {}, range: nil, access_owner: nil)
    # filter
    unless filter.empty?
      join_table = filter.keys.map(&:to_sym).intersection [:project, :design, :owner, :stage, :upstream]
      works = if join_table.empty?
                works.where filter
              else
                works.joins(join_table).where filter
              end
    end

    # search
    unless search.nil?
      works = works.select do |work|
                work.name.match?(search)
              end
    end

    # sort
    sort, desc = sorter.first
    works = works.sort_by do |work|
      if sort.is_a?(Class)
        work.instance_eval(sort.name.downcase).name
      elsif sort.eql?("is_private")
        work.attribute_in_database(sort).to_s
      else
        work.attribute_in_database(sort)
      end
    end
    works.reverse! if desc

    # range
    total = works.size
    works = works[range] unless range.nil?
    
    # output
    {
      data: works.map { |work| work.attributes_with_references(name_only: true, access_owner: access_owner) },
      total: total
    }
  end

  def self.merge_works(works: [], sub_tables: [], focus: [], filter: {}, search: nil, sorter: {}, init_only: false, range: nil, view_context: nil, access_owner: nil)
    # sub_tables
    works_sub_tables = works.map {|work| work.query_sub_table}.flatten.uniq.map {|n| [n, false]}.to_h
    sub_tables.each do |sub_table|
      works_sub_tables[sub_table] = true if works_sub_tables.key? sub_table
    end
    unless works_sub_tables.value? true
      works_sub_tables[works_sub_tables.keys.first] = true
    end
    multi_subs = works_sub_tables.values.select{|i| i}.size > 1
    sub_table_column = "table"

    # pictures
    works_pics = works.map do |work|
      work.pictures.map do |pic| 
        #W/A to avoid full url
        #view_context.image_tag pic, height: 80, onclick: "modalView('#{view_context.image_tag pic, id: "modal_view", class: "img-fluid"}')"
        if view_context.nil?
          pic
        else
          pic_path = view_context.rails_blob_path pic, only_path: true
          view_context.image_tag pic_path, height: 80, onclick: "modalView('#{view_context.image_tag pic_path, id: "modal_view", class: "img-fluid"}')"
        end
      end
    end

    # Get all index & filter & search
    indexes = []
    merge_data = {}
    filter_data = {}
    keys = []
    data_size = 0
    works.each_with_index do |work, index|
      works_sub_tables.select {|k, v| v}.keys.each do |sub_table|
        sub_table_data = work.query_sub_table sub_table
        next if sub_table_data.nil?
        work_data = JSON.parse Zlib::inflate(sub_table_data.download)
        work_data.each do |record|
          record = {sub_table_column => sub_table}.merge record if multi_subs
          record_key = focus.empty? ? record["key"] : record.delete("key")
          keys << record_key
          # focus
          next unless focus.empty? || focus.include?(record_key)
          # search 
          next unless search.nil? || record.to_s.match?(search)
          # filter
          pass_flag = true
          filter.each do |filter_key, filter_value|
            if filter_key.eql?(work.id.to_s) && !record["value"].to_s.match?(filter_value)
              pass_flag = false
              break
            elsif (record.key? filter_key) && !record[filter_key].to_s.eql?(filter_value)
              pass_flag = false
              break
            elsif !focus.empty? && 
                  filter_key.eql?("#{work.id.to_s}.#{record_key}") &&
                  !record["value"].to_s.match?(filter_value)
              pass_flag = false
              break
            end
          end
          next unless pass_flag

          value = record.delete "value"
          # filter data
          record.each do |key, value|
            filter_data[key] = {} unless filter_data.key? key
            filter_data[key][value] = value
          end
          # indexes
          indexes += record.keys
          # skip data if init only
          next if init_only

          # data
          pic_flag, pic_no = value.split(":")
          if pic_flag.eql?("picture") && pic_no.match?(/[0-9]+/)
            value = works_pics[index][pic_no.to_i]
          end
          merge_data[record] = {} if merge_data[record].nil? 
          if focus.empty?
            merge_data[record][work.id.to_s] = value
          else
            merge_data[record]["#{work.id}.#{record_key}"] = value
          end
        end
      end
    end
    indexes.uniq!
    keys.uniq!
    indexes.delete("key")

    # Gen table
    field_filterd = filter.keys
    merge_table = []
    merge_data.each do |record, values|
      record.merge! values
      next unless (field_filterd - record.keys).empty?
      merge_table << record
    end
    # Sort
    unless sorter.empty? || merge_table.empty?
      # Sort
      merge_table.sort! do |a, b|
        res = 0
        sorter.each do |type, desc|
          res = if a[type].nil? && b[type].nil?
                  0
                elsif a[type].nil?
                  1
                elsif b[type].nil?
                  -1
                else
                  (Float(a[type]) rescue a[type]) <=> (Float(b[type]) rescue b[type])
                end

          if !res.zero?
            res = - res if desc
            break
          end
        end
        res
      end
    end
    data_size = merge_table.size
    # Page
    unless range.nil? || merge_table.empty?
      merge_table = merge_table[range]
    end

    # Return
    {
      data: merge_table,
      data_size: data_size,
      filter_data: filter_data,
      keys: keys,
      indexes: indexes,
      sub_tables: works_sub_tables,
      summary: Work.merge_summary(works: works, range: nil, access_owner: access_owner)[:data]
    }
  end

  def self.merge_chart(works: [], access_owner: nil)
    head_works =  works.map do |work|
      (work.get_upstreams(access_owner) << work).first
    end.uniq

    designs = {}
    projects = {}
    head_works.each do |work|
      design = work.design
      designs[design] = {
        name: design.name,
        stage: :design,
        children: []
      } unless designs.key? design
      designs[design][:children] << work.flatten_downstreams(access_owner)
    end

    designs.each do |design, design_content|
      project = design.project
      projects[project] = {
        name: project.name,
        stage: :project,
        children: []
      } unless projects.key? project
      projects[project][:children] << design_content
    end

    if projects.size.eql? 1
      projects.values.first
    else
      {
        name: "",
        stage: "",
        children: projects.values
      }
    end
  end

  def attach_datas(data_content)
    self.datas.attach(
      data_content.map do |sub_table, data|
        comp_file = Tempfile.new(encoding: 'ascii-8bit')
        comp_file.write Zlib::deflate(data.to_json)
        comp_file.rewind
        {
          io: comp_file,
          filename: sub_table,
          content_type: "application/json",
          identify: false
        }
      end
    )
  end

  def query_sub_table(sub_table=nil)
    if sub_table.nil?
      return self.datas.map {|sub_table_data| sub_table_data.filename.to_s}
    else
      self.datas.each do |sub_table_data|
        return sub_table_data if sub_table_data.filename.to_s.eql? sub_table
      end
      return nil
    end
  end

  def allow?(access_owner=nil)
    !is_private || (owner.eql? access_owner)
  end

  def get_upstreams(access_owner=nil)
    upstreams = []
    n_upstream = upstream
    until n_upstream.nil? || 
          upstreams.include?(n_upstream) ||
          !n_upstream.allow?(access_owner)
      upstreams << n_upstream
      n_upstream = n_upstream.upstream
    end
    upstreams
  end

  def get_upstream(access_owner=nil)
    if upstream.nil? || !upstream.allow?(access_owner)
      nil
    else
      upstream
    end
  end

  def get_downstreams(access_owner=nil)
    downstreams.filter {|n| n.allow? access_owner}
  end

  def flatten_downstreams(access_owner=nil, visted_works=[])
    visted_works << self
    downstreams_safe = (downstreams.select {|n| n.allow? access_owner}) - visted_works
    if downstreams_safe.empty?
      attributes_with_references(name_only: true, with_relationshiop: false)
    else
      attributes_with_references(name_only: true, with_relationshiop: false).merge(
        children: downstreams_safe.map {|n| n.flatten_downstreams(access_owner, visted_works)}
      )
    end
  end

private
  def relationship(access_owner=nil)
    {
      id: id,
      upstream: (get_upstream(access_owner).name rescue nil),
      upstream_id: (get_upstream(access_owner).id rescue nil),
      upstreams_size: get_upstreams(access_owner).size,
      downstreams_size: get_downstreams(access_owner).size
    }
  end

end
