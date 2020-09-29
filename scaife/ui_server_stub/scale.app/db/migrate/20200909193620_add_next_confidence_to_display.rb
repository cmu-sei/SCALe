class AddNextConfidenceToDisplay < ActiveRecord::Migration[5.2]
  def change
    add_column :displays, :next_confidence, :decimal
  end
end
