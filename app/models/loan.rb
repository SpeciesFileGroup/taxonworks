class Loan < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  has_paper_trail

  belongs_to :recipient_person, foreign_key: :recipient_person_id, class_name: 'Person'
  belongs_to :supervisor_person, foreign_key: :supervisor_person_id, class_name: 'Person'

  # TODO: @mjy What *is* the right construct for 'Loan'?
  def self.find_for_autocomplete(params)
    where('recipient_email LIKE ?', "#{params[:term]}%")
  end

end
