class AddCommentMessageInProjectFeedbackPage < ActiveRecord::Migration
  def up
    add_column :project_feedbacks, :comment, :string
  end

  def down
    remove_column :project_feedbacks, :comment
  end
end
