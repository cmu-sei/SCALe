class AddFeatureCategoryToClassifierSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :classifier_schemes, :feature_category, :string
  end
end
