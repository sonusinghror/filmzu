class AddSkillsToProjects < ActiveRecord::Migration
  def self.up
		add_column :projects, :skills, :string
  end

	def self.down
		remove_column :projects, :skills
	end
end
