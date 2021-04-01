class AddFieldsToClassifierMetrics < ActiveRecord::Migration[5.2]
  def change
    add_column :classifier_metrics, :num_labeled_meta_alerts_used_for_classifier_training, :integer
    add_column :classifier_metrics, :num_labeled_T_test_suite_used_for_classifier_training, :integer
    add_column :classifier_metrics, :num_labeled_F_test_suite_used_for_classifier_training, :integer
    add_column :classifier_metrics, :num_labeled_T_manual_verdicts_used_for_classifier_training, :integer
    add_column :classifier_metrics, :num_labeled_F_manual_verdicts_used_for_classifier_training, :integer
    add_column :classifier_metrics, :num_code_metrics_tools_used_for_classifier_training, :integer
    add_column :classifier_metrics, :top_features_impacting_classifier, :text
  end
end
