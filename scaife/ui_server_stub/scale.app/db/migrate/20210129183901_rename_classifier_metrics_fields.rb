class RenameClassifierMetricsFields < ActiveRecord::Migration[5.2]
  def change
    rename_column :classifier_metrics, :accuracy, :test_accuracy
    rename_column :classifier_metrics, :precision, :test_precision
    rename_column :classifier_metrics, :recall, :test_recall
    rename_column :classifier_metrics, :f1, :test_f1
    add_column :classifier_metrics, :train_accuracy, :float
    add_column :classifier_metrics, :train_precision, :float
    add_column :classifier_metrics, :train_recall, :float
    add_column :classifier_metrics, :train_f1, :float
  end
end
