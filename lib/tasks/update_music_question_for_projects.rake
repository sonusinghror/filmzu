

namespace :db  do
  # used to update the projects music question 'Do your need music?'
  task :update_music_question_for_projects => :environment do
    Project.all.each do |project|
      question = project.project_questions.where(question_text: "Do your need music?").first
      if question.present?
        question.update_attribute(:question_text, "Do you need music?")
        puts "updated project #-#{project.id}"
      end
    end
  end
end
