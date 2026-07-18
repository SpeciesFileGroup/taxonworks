require 'rails_helper'

describe 'Queries::Concerns::SortResolver', type: :model do
  let(:klass) { Queries::CollectionObject::Filter }

  context 'validate_column! guardrails' do
    specify 'rejects a column that looks like a raw foreign key' do
      expect {
        klass.send(:validate_column!, ::Repository, 'geographic_area_id')
      }.to raise_error(ArgumentError, /raw foreign key/)
    end

    specify 'rejects a restricted (credential-shaped) column' do
      expect {
        klass.send(:validate_column!, ::User, 'password_digest')
      }.to raise_error(ArgumentError, /restricted column/)
    end

    specify 'rejects a token-shaped column' do
      expect {
        klass.send(:validate_column!, ::User, 'api_access_token')
      }.to raise_error(ArgumentError, /restricted column/)
    end

    specify 'rejects an ip-shaped column' do
      expect {
        klass.send(:validate_column!, ::User, 'current_sign_in_ip')
      }.to raise_error(ArgumentError, /restricted column/)
    end

    specify 'rejects an unknown column' do
      expect {
        klass.send(:validate_column!, ::Repository, 'no_such_column')
      }.to raise_error(ArgumentError, /no column/)
    end

    specify 'allows an ordinary column' do
      expect { klass.send(:validate_column!, ::Repository, 'name') }.not_to raise_error
    end
  end

  context 'validate_target_class! guardrail' do
    specify 'rejects User as a sort-reachable class' do
      expect {
        klass.send(:validate_target_class!, ::User)
      }.to raise_error(ArgumentError, /not reachable for sorting/)
    end

    specify 'allows an ordinary class' do
      expect { klass.send(:validate_target_class!, ::Repository) }.not_to raise_error
    end
  end

  context 'assoc() guardrails' do
    specify 'rejects an association chain deeper than MAX_DEPTH' do
      expect {
        klass.send(:assoc, :a, :b, :c, :d, :name)
      }.to raise_error(ArgumentError, /too deep/)
    end

    specify 'rejects an unknown association' do
      expect {
        klass.send(:assoc, :no_such_association, :name)
      }.to raise_error(ArgumentError, /no association/)
    end

    specify 'rejects a has_many hop with no collapse: given' do
      expect {
        klass.send(:assoc, :identifiers, :cached)
      }.to raise_error(ArgumentError, /collapse: is required/)
    end

    specify 'rejects collapse: :aggregate combined with further hops' do
      expect {
        klass.send(:assoc, :taxon_determinations, :otu, :name, collapse: :aggregate)
      }.to raise_error(ArgumentError, /cannot be combined with further hops/)
    end

    specify 'rejects a bare belongs_to fk column as the terminal column' do
      expect {
        klass.send(:assoc, :repository, :id)
      }.not_to raise_error # 'id' itself is not FK-shaped

      expect {
        klass.send(:assoc, :collecting_event, :geographic_area_id)
      }.to raise_error(ArgumentError, /raw foreign key/)
    end
  end

  context 'bulk auto-derivation' do
    specify 'sortable_direct_columns includes ordinary columns and excludes blacklisted-shaped ones' do
      cols = klass.send(:sortable_direct_columns)
      expect(cols).to have_key('total')
      expect(cols).not_to have_key('repository_id')
      expect(cols).not_to have_key('project_id')
      expect(cols.values).to all(be_a(Proc))
    end

    specify 'sortable_assoc_columns includes the target class columns and excludes its fk-shaped ones' do
      cols = klass.send(:sortable_assoc_columns, :repository)
      expect(cols).to have_key('name')
      expect(cols).to have_key('id')
      expect(cols).not_to have_key('created_by_id')
      expect(cols.values).to all(be_a(Proc))
    end

    specify 'sortable_assoc_columns raises for an unknown association' do
      expect {
        klass.send(:sortable_assoc_columns, :no_such_association)
      }.to raise_error(ArgumentError, /no association/)
    end
  end
end
