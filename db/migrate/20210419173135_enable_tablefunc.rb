class EnableTablefunc < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'tablefunc'
  end
end
