class AddConfidenceLockToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :confidence_lock, :integer
  end
end
