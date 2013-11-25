class Admin::CommentsController < Admin::AdminController
  def create
    application = Application.find(params[:application_id])

    comment = Comment.create(comment_params)
    comment.user_id = current_user.id
    comment.application_id = application.id
    comment.save

    flash[:error] = comment.errors.full_messages.first

    redirect_to admin_application_path(application)
  end

  private

  def comment_params
    params.require(:comment).permit(:comment)
  end
end
