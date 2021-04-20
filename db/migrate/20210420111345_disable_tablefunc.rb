class DisableTablefunc < ActiveRecord::Migration[6.0]
  def change
    disable_extension 'tablefunc'
  end
end
