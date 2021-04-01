class AddNumMetaAlertThresholdToClassifierSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :classifier_schemes, :num_meta_alert_threshold, :integer
  end
end
