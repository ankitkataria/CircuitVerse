class SimulatorController < ApplicationController

  before_action :authenticate_user!, only: [:create, :update, :edit,:update_image]
  before_action :set_project, only: [:show, :embed, :embed, :update, :edit, :get_data,:update_image]
  before_action :check_view_access, only: [:show,:embed,:get_data]
  before_action :check_edit_access, only: [:edit,:update,:update_image]
  after_action :allow_iframe, only: :embed

  def self.policy_class
    ProjectPolicy
  end

  def show
    @logix_project_id = params[:id]
    render 'embed'
  end

  def edit
    @project = Project.find_by(id:params[:id])
    @logix_project_id = params[:id]
    @projectName = @project.name
  end

  def embed
    authorize @project
    @logix_project_id = params[:id]
    render 'embed'
  end

  def get_data
    render json: @project.data
  end

  def new
    @logix_project_id = 0
    @projectName = ""
    render "edit"
  end

  def update
    @project.data = params[:data]
    data_url = params[:image]
    jpeg      = Base64.decode64(data_url['data:image/jpeg;base64,'.length .. -1])
    image_file = File.new("preview_#{Time.now()}.jpeg", "wb")
    image_file.write(jpeg)
    @project.image_preview = image_file
    @project.name = params[:name]
    @project.save
    File.delete(image_file)
    render plain: "success"
  end


  def create
    @project = Project.new
    @project.data = params[:data]
    @project.name = params[:name]
    @project.author = current_user

    data_url = params[:image]
    jpeg      = Base64.decode64(data_url['data:image/jpeg;base64,'.length .. -1])
    image_file = File.new("preview_#{Time.now()}.jpeg", "wb")
    image_file.write(jpeg)
    @project.image_preview = image_file
    @project.save
    File.delete(image_file)

    # render plain: simulator_path(@project)
    # render plain: user_project_url(current_user,@project)
    redirect_to edit_user_project_url(current_user,@project)
  end

  private
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def check_edit_access
    authorize @project, :edit_access?
  end

  def check_view_access
    authorize @project, :view_access?
  end

end
