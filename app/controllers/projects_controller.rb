# frozen_string_literal: true

require 'sanitize'

class ProjectsController < ApplicationController
  #  before_action :authenticate_user!, only: [:edit, :update, :destroy, :new, :create]
  load_and_authorize_resource
  before_action :set_project, only: %i[edit update destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.order(updated_at: :desc).all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
    @payments = @project.payments.includes(:user)
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit; end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    @project.user = current_user

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Проект создан.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Проект изменен.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Проект удален.' }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    permitted_attrs = %i[name short_desc full_desc photo markup_type project_status]
    permitted_attrs << :public if @project.present? && @project.user == current_user

    result_params = params.require(:project).permit(permitted_attrs)
    sanitize_config = Sanitize::Config.merge(Sanitize::Config::RELAXED,
                                             elements: Sanitize::Config::RELAXED[:elements] + ['iframe'],
                                             attributes: Sanitize::Config::RELAXED[:attributes].merge(
                                               {
                                                 'iframe' => %w[width height src frameborder allow allowfullscreen]
                                               }
                                             ),
                                             remove_contents: true)
    result_params[:short_desc] = Sanitize.fragment(result_params[:short_desc], sanitize_config)
    result_params[:full_desc] = Sanitize.fragment(result_params[:full_desc], sanitize_config)
    result_params
  end
end
