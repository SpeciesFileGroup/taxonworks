# A collection object that is classified as being biological in origin.
#
# !! See also CollectionObject::BiologicalExtensions
class FieldOccurrence::BiologicalFieldOccurrence < FieldOccurrence

  # TODO: revisit base class needs
  # is_origin_for 'Extract', 'FieldOccurrence::BiologicalFieldOccurrence'

  include Shared::IsDwcOccurrence
  include FieldOccurrence::DwcExtensions

  # !! See also FieldOccurrence::BiologicalFieldOccurrence, all code there technically belongs here

  soft_validate(
    :sv_determined_before_collected,
    set: :determined_before_collected,
    name: 'Determined before collecting date',
    description: 'Determination date preciding collecting date')

  soft_validate(
    :sv_missing_collecting_event,
    set: :missing_collecting_event,
    name: 'Missing collecting event',
    description: 'Missing collecting event')

  soft_validate(
    :sv_missing_biocuration_classification,
    set: :missing_biocuration_classification,
    name: 'Missing biocuration classification',
    description: 'Biocuration classification is not indicated')

  def current_taxon_determination=(taxon_determination)
    if taxon_determinations.include?(taxon_determination)
      taxon_determination.move_to_top
    end
  end

  # @return [Boolean]
  #   nil values are sent to the bottom
  def reorder_determinations_by(attribute = :date)
    determinations = []
    if attribute == :date
      determinations = taxon_determinations.sort{|a, b| (b.sort_date || Time.utc(1, 1))  <=> (a.sort_date || Time.utc(1,1)) }
    else
      determinations = taxon_determinations.order(attribute)
    end

    begin
      TaxonDetermination.transaction do
        determinations.each_with_index do |td, i|
          td.update_column(:position, i + 1)
        end
      end
    rescue
      return false
    end
    return true
  end

  protected

  def sv_missing_determination
    soft_validations.add(:base, 'Determination is missing', success_message: 'Determination was added', failure_message: 'The determination was not added') if !taxon_determinations.any?
  end

  def sv_determined_before_collected
    ce = collecting_event
    return true if ce.nil? || ce.start_date_year.nil?
    #ce_date = ce.start_date_year.to_s + '/' + sprintf( '%02d', ce.start_date_month.to_i) + "/" + sprintf( '%02d', ce.start_date_day.to_i)
    #ce_date = ce.end_date_year.to_s + '/' + sprintf( '%02d', ce.end_date_month.to_i) + "/" + sprintf( '%02d', ce.end_date_day.to_i) unless ce.end_date_year.nil?
    ce_date = Utilities::Dates.nomenclature_date(ce.start_date_day, ce.start_date_month, ce.start_date_year)
    ce_date = Utilities::Dates.nomenclature_date(ce.end_date_day, ce.end_date_month, ce.end_date_year) unless ce.end_date_year.nil?
    taxon_determinations.each do |d|
      next if d.year_made.nil?
      #d_date = d.year_made.to_s + '/' + sprintf( '%02d', d.month_made.to_i) + "/" + sprintf( '%02d', d.day_made.to_i)
      d_date = Utilities::Dates.nomenclature_date(d.day_made, d.month_made, d.year_made)
      soft_validations.add(:base, 'Determination is preceding the collecting date') if d_date < ce_date
    end
  end

  def sv_missing_collecting_event
    soft_validations.add(:collecting_event_id, 'Collecting event is not selected') if collecting_event_id.nil?
  end

  def sv_missing_biocuration_classification
    soft_validations.add(:repository_id, 'Biocuration is not specified') if !biocuration_classifications.any?
  end

end

