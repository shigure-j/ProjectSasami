class DashboardController < ApplicationController
  def index
    @status = statistic
    @works  = Work.filter_by_owner(logged_in? ? current_user : nil)[-7..-1].reverse
  end

  def summary
    @format = Format.find_by(name: :work).get_format
  end

  def detail
    @format = Format.find_by(name: :work).get_format
  end

  def statistic
    attachements = ActiveStorage::Blob.all  
    attachements_bytes = attachements.reduce(0) {|sum, n| sum + n.byte_size}
    db_file = Rails.root + Rails.application.config.database_configuration[Rails.env]["database"]
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
end
