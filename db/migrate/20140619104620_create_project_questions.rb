class CreateProjectQuestions < ActiveRecord::Migration
  def change
    create_table :project_questions do |t|
      t.string :question_text, :null => false
      t.string :answer_text, :null => false
			t.references :project
      t.timestamps
    end
  end
end
