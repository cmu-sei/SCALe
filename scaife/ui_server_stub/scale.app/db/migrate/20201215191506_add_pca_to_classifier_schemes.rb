class AddPcaToClassifierSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :classifier_schemes, :use_pca, :boolean
  end
end
