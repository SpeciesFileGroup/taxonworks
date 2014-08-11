class Loan < ActiveRecord::Base

  belongs_to :recipient_person, foreign_key: :recipient_person_id, class_name: 'Person'
  belongs_to :supervisor_person, foreign_key: :supervisor_person_id, class_name: 'Person'

  def self.find_for_autocomplete(params)
    where('name LIKE ?', "#{params[:term]}%")
  end

end
