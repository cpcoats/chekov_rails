require 'task_promotion_strategy'

class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  # GET /comments(.json)
  def index
    @comments = Comment.all
  end

  # GET /comments/1(.json)
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new(task_for_comment)
    @task = Task.find(params[:task_id])
    @status_list = Status.all
    @comment.commenter = User.find(params[:commenter_id])
    @task.assignee ||= User.nobody
    render :partial => "partials/new_comment_view",
           :locals => { :comment => CommentViewPresenter.new(@comment, @task), :mode => :add }
  end

  # GET /comments/1/edit
  def edit
    @status_list = Status.all
    render :partial => "partials/new_comment_view",
           :locals => { :comment => CommentViewPresenter.new(@comment, @comment.task), :mode => :edit }
  end

  # POST /comments(.json)
  def create
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if @comment.save
        # format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        # format.json { render action: 'show', status: :created, location: @comment }
        format.html { redirect_to :back, :success => "Comment added successfully to task ##{ @comment.task.id }" }
        format.js   {}
        format.json { render :json => { :ok => 200 } }
      else
        format.html { render action: 'new' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1(.json)
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to :back }#@comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1(.json)
  def destroy
    @comment.destroy
    respond_to do |format|
      # format.html { redirect_to root_path }
      format.json { head :no_content, :success => "Comment successfully deleted." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment)
            .permit(:description, :task_id, :commenter_id, :commenter,
                    :task_attributes => [ :status, :status_id, :application_id, :reporter_id ])
    end

    def task_for_comment
      params.permit(:task_id, :task, :commenter, :commenter_id)
    end

end
