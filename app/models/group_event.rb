class GroupEvent < ApplicationRecord
  SKIP_KEYS = %w(id user_id created_at updated_at is_published deleted_at).freeze

  # The requrement does not tell more about user. Hence just expecting user_id to be present
  validates :user_id, presence: true
  validates :name, uniqueness: { scope: [:start_date, :end_date] }
  validates :name, :description, :start_date, :end_date, :duration, :location_name, presence: true, if: :is_published?
  validates :duration, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true

  # Set start_date/end_date/duration
  before_validation :set_dates_and_duration

  # Custom validation to check whether any of the attributes are present
  # as the object can be saved with a subset, but should not be entirely empty!
  validate :validate_any_key_presence
  validate :validate_dates_and_duration

  scope :non_deleted, -> { where(deleted_at: nil) }

  # override so that not permanently deleted
  def destroy
    update(deleted_at: Time.current)
  end

  protected

  # consider the duration including end date
  # means, if start date is today, end date is tomorrow, duration is 2 days
  def set_dates_and_duration
    if start_date && end_date && !duration
      self.duration = (end_date - start_date).to_i + 1 # if it's same date, duration should be 1
    elsif start_date && !end_date && duration
      self.end_date = start_date + (duration - 1).days
    elsif !start_date && end_date && duration
      self.start_date = end_date - (duration - 1).days
    end
  end

  def validate_any_key_presence
    keys_to_check = attributes.keys.without(SKIP_KEYS)
    
    if keys_to_check.all? {|attr| self[attr].blank? }
      self.errors.add(:base, I18n.t('group_event.validation.all_blank', keys: keys_to_check.join(', ')))
    end
  end

  def validate_dates_and_duration
    if start_date && end_date
      if start_date > end_date
        self.errors.add(:end_date, I18n.t('group_event.validation.end_date'))
      end

      if duration && duration.to_i != ((end_date - start_date).to_i + 1)
        self.errors.add(:duration, I18n.t('group_event.validation.duration'))
      end
    end
  end
end
