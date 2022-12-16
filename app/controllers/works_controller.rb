class WorksController < ApplicationController
  def show
    @work = Work.find(params[:id])
    @format = Format.find_by(id: @work.stage.default_format) ; #TODO
  end

  def new
    @work = Work.new
  end

  def create
    i_params = work_params
    data_content = JSON.parse(work_params[:data].read)
    #TODO#stage = Stage.find_by name: i_params[:stage]

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

    if i_params[:stage].default_format.nil? 
      format_obj = i_params[:stage].formats.create(name: :default)
      format_obj.init_format_by(data_content)
      format_obj.save
      i_params[:stage].default_format = format_obj.id
      i_params[:stage].save
    end

    @work = Work.new(i_params)

    if @work.save
      redirect_to @work
    else
      render :new, status: :unprocessable_entity
    end
  end

private
  def work_params
    params.require(:work).permit(:name, :design, :project, :path, :owner, :stage, :start_time, :end_time, :data)
  end
end
