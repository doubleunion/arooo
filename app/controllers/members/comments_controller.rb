class Members::CommentsController < Members::MembersController
  def create
    application = Application.find(application_id_param)
    comment = Comment.new(comment_params)
    comment.user = current_user

    if comment.save
      flash[:notice] = "Comment saved"
    else
      flash[:error] = "Comment not saved"
    end

    redirect_to members_application_path(application)
  end

  def index
    # only comments on applications that are not accepted should be viewable!
    @recent_comments = Comment.where("created_at > ?", 1.month.ago).sort_by(&:created_at).select { |comment|
      comment.application.state == "submitted"
    }
  end

  private

  def application_id_param
    params.require(:comment).require(:application_id)
  end

  def comment_params
    params.require(:comment).permit([:body, :application_id])
  end
end
