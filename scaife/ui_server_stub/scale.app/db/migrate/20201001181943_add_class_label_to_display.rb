class AddClassLabelToDisplay < ActiveRecord::Migration[5.2]
  def change
    add_column :displays, :class_label, :string
  end
end
