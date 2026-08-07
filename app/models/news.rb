# News
# News is used to communicate with users of Projects and the Application (Administration).
#
class News < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData::Navigation
  include Shared::IsData::Metamorphosize
  include Shared::HasPapertrail
  include Shared::Permissions

  ignore_whitespace_on(:body)

  ADMINISTRATION_TYPES = {
    'News::Administration::BlogPost': :administration_blog_post,
    'News::Administration::Warning': :administration_warning,
    'News::Administration::Notice': :administration_notice,
  }.freeze

  PROJECT_TYPES = {
    'News::Project::BlogPost': :blog_post,
    'News::Project::Instruction': :instruction,
    'News::Project::Notice': :notice,
  }.freeze

  validates :title, presence: true
  validates :body, presence: true
  validates :type, format: { with: /\ANews::Project::/, message: 'is not a project News type' }, if: -> { project_id.present? }
  validate :display_end_after_display_start

  scope :administration, -> {where("type like 'News::Administration::%'")}
  scope :project, -> {where("type like 'News::Project::%'")}

  scope :current, -> {
    now = Time.current
    where(
      '(display_start IS NULL OR display_start <= ?) AND (display_end IS NULL OR display_end >= ?)',
      now, now
    )
  }

  def self.annotates?
    false
  end

  def is_current?
    t = Time.current
    (display_start.nil? or display_start <= t) && (display_end.nil? or display_end >= t)
  end

  private

  def display_end_after_display_start
    return if display_start.nil? || display_end.nil?

    if display_end <= display_start
      errors.add(:display_end, 'must be later than display start')
    end
  end

end
