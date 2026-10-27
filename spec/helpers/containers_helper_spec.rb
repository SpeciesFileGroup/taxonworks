require 'rails_helper'

describe ContainersHelper, type: :helper do
  context '#label_for_container_container' do
    let(:namespace) { FactoryBot.create(:valid_namespace) }
    let(:container) { Container::Box.create! }
    let!(:first_identifier) {
      Identifier::Local::ContainerCode.create!(identifier_object: container, namespace:, identifier: 'A1')
    }
    let!(:second_identifier) {
      Identifier::Local::ContainerCode.create!(identifier_object: container, namespace:, identifier: 'B2')
    }

    # Filter tables preload identifiers, which come back in no particular
    # order; the label must not depend on that. First is by position, as
    # identifiers are listed everywhere else.
    specify 'uses the first identifier by position, also when identifiers are preloaded' do
      # Rewrite the first identifier so it no longer comes first in the table.
      first_identifier.update_column(:updated_at, Time.current)
      first_identifier.update_column(:position, 3)

      preloaded = Container.includes(:identifiers).find(container.id)
      expect(helper.label_for_container_container(preloaded)).to eq(helper.label_for_identifier(second_identifier))
      expect(helper.label_for_container_container(Container.find(container.id))).to eq(helper.label_for_identifier(second_identifier))
    end
  end
end
