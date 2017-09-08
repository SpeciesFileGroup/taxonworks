class ExtendDepictionsToActAsFigures < ActiveRecord::Migration[4.2]

  def change
    add_column :depictions, :caption, :text, index: true
    add_column :depictions, :figure_label, :string
  end

end
