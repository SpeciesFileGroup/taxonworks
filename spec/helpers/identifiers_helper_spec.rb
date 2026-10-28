require 'rails_helper'

describe IdentifiersHelper, type: :helper do
  context '#identifiers_in_position_order' do
    let(:specimen) { FactoryBot.create(:valid_specimen) }
    let(:namespace) { FactoryBot.create(:valid_namespace) }

    def identifier(value, position)
      i = Identifier::Local::CatalogNumber.create!(
        identifier_object: specimen, namespace:, identifier: value
      )
      i.update_column(:position, position)
      i
    end

    # Matches SQL `ORDER BY position, id`, used by the identifiers sort.
    specify 'orders by position, then id, with NULL positions last' do
      third = identifier('c', nil)
      second = identifier('b', 2)
      first = identifier('a', 1)
      fourth = identifier('d', nil)

      expect(helper.identifiers_in_position_order(specimen.identifiers.reload))
        .to eq([first, second, third, fourth])
    end
  end
end
