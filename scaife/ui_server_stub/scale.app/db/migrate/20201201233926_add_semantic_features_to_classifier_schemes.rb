class AddSemanticFeaturesToClassifierSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :classifier_schemes, :semantic_features, :boolean
  end
end
