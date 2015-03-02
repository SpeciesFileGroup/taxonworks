class RecastBadColumnTypes < ActiveRecord::Migration
  def change

    remove_column :loans, :supervisor_person_id
    add_column :loans, :supervisor_person_id, :integer
    Loan.connection.execute('alter table loans add foreign key (supervisor_person_id) references people (id);')


  end
end
