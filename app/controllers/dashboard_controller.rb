class DashboardController < ApplicationController
  def notification
    
  end

  def index
    @status = statistic
    @works  = (Work.filter_by_owner(logged_in? ? current_user : nil)[-7..-1] || []).reverse
  end

  def chart
  end

  def summary
    @format = Format.find_by(name: :work).get_format
    @filter_data = filter_data
    @data_param = request.url.split("?")[1]
  end

  def detail
    @format = Format.find_by(name: :work).get_format
    @filter_data = filter_data
  end

  def statistic
    db_file = Rails.root + Rails.application.config.database_configuration[Rails.env]["database"]
    db_mtime = db_file.mtime
    Rails.cache.fetch("custom_cache/statistic/#{db_mtime}", expires_in: 12.hours) do
      attachements = ActiveStorage::Blob.all  
      attachements_bytes = attachements.reduce(0) {|sum, n| sum + n.byte_size}
      {
        works_count:    Work.count,
        projects_count: Project.count,
        designs_count:  Design.count,
        owners_count:   Owner.count,
        file_size:      convert_file_size(attachements_bytes),
        file_count:     attachements.size,
        db_size:        convert_file_size(db_file.size)
      }
    end
  end

  def convert_file_size(org_size)
    unit =  ["KB", "MB", "GB"].each do |unit|
              org_size = (org_size / 1024.0).round(3)
              if org_size < 1024 then
                break unit 
              else
                unit
              end
            end
    "#{org_size}#{unit}"
  end

  def filter_data
    map_proc = Proc.new {|n| [n.name, n.name]}
    {
      "owner"       =>  Owner.all.map(&map_proc).to_h,
      "project"     =>  Project.all.map(&map_proc).to_h,
      "design"      =>  Design.all.map(&map_proc).to_h,
      "stage"       =>  Stage.all.map(&map_proc).to_h,
      "is_private"  =>  {true: true, false: false}
    }
  end
end
