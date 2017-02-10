class ExtendDepictionsToActAsFigures < ActiveRecord::Migration

  def change
    add_column :depictions, :caption, :text, index: true
    add_column :depictions, :figure_label, :string
  end

end
