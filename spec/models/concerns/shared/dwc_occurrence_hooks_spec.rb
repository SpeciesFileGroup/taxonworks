require 'rails_helper'

describe 'Shared::DwcOccurrenceHooks', type: :model, group: :dwc_occurrence do
  let!(:hookable_class) {TestDwcHookable.new}

  # TODO: if eager_load paradigm changes this may need update
  ApplicationRecord.descendants.each do |c|
    if c < Shared::DwcOccurrenceHooks
      specify "hooked model includes #dwc_occurrences #{c.name}" do
        expect(c.new.respond_to?(:dwc_occurrences)).to be_truthy
      end

      specify "#dwc_occurrences of #{c.name} is a ActiveRecord::Relation" do
        expect(c.new.dwc_occurrences.class.name).to match('ActiveRecord::Relation')
      end
    end
  end
end

class TestDwcHookable < ApplicationRecord
  include FakeTable
  include Shared::DwcOccurrenceHooks

  def dwc_occurrences
    DwcOccurrence.none
  end

end

