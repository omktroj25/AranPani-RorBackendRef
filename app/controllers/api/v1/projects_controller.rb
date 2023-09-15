class Api::V1::ProjectsController < ApplicationController
    before_action { authorize("projects") }
    before_action :find_project,only:[:show,:update,:project_documents,:project_activity,:project_images]
    include SequenceGeneratorService
    def index
        render json: Project.search(params).paginate(page:params[:page],per_page:params[:limit]),status: :ok
    end
    def show
        render json: @project,include:['activities.images','images'],status: :ok
    end
    def create 
        @project=Project.new(project_params)
        @project.reg_no="TEM"+sequence_generator('project').to_s
        @project.status=Project.statuses[:Proposed]
        if @project.save
            render json: @project,status: :ok
        else
            render json: @project.errors,status: :ok
        end
    end
    def update
        if @project.update(update_project_params)
            render json: @project,status: :ok
        else
            render json: @project.errors,status: :ok
        end
    end
    def project_documents
        @project.project_documents.push(ProjectDocument.new(document_url:params[:document_url]))
        if @project.save
            render json: @project,status: :ok
        else
            render json: @project.errors,status: :ok
        end
    end
    def project_activity
        if @project.Active? || @project.Completed? || @project.Scrapped?
            @activity=Activity.new(description:params[:description])
            if params[:image_url].present?
                @activity.images.push(Image.new(image_url:params[:image_url]))
            end
            @project.activities.push(@activity)
            if @project.save
                render json: @project,include:['activities.images'],status: :ok
            else
                render json: @project.errors,status: :ok
            end
        else
            render json:{status:false,message:"Planned project can't have activity"},status: :ok
        end
    end
    def project_images
        @project.images.push(Image.new(image_url:params[:image_url]))
        if @project.save
            render json:@project,status: :ok
        else
            render json:@project.errors,status: :ok
        end
    end
    private 
    def project_params
        params.require(:project).permit(:temple_name,:incharge_name,:phonenumber,:location,:status,:latitude,:longitude)
    end
    def update_project_params
        params.require(:project).permit(:temple_name,:incharge_name,:phonenumber,:location,:status,:latitude,:longitude,:start_date,:end_date,:estimated_amount)
    end
    def find_project
        @project=Project.find(params[:id])
    end
end
