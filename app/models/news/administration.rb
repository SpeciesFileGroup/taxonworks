

# New corresponding to the administration of this instance of TaxonWorks
class News::Administration < News
  validates :project_id, absence: true
  validate :user_must_be_administrator, prepend: false

  private

  def user_must_be_administrator
    return unless created_by_id || updated_by_id

    if created_by_id
      user = User.find_by(id: created_by_id)
      unless user&.is_administrator
        errors.add(:base, 'only administrators can edit administration news')
      end
    end

    if updated_by_id
      user = User.find_by(id: updated_by_id)
      unless user&.is_administrator
        errors.add(:base, 'only administrators can edit administration news')
      end
    end

  end
end
