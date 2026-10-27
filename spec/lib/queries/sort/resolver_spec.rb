require 'rails_helper'

describe 'Queries::Sort::Resolver', type: :model do
  let(:klass) { Queries::CollectionObject::Sort }

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

    # Rails keeps encrypted attribute names as a Set of symbols.
    specify 'rejects an encrypted column' do
      allow(::Repository).to receive(:encrypted_attributes).and_return(Set[:name])
      expect {
        klass.send(:validate_column!, ::Repository, 'name')
      }.to raise_error(ArgumentError, /encrypted/)
      expect(klass.send(:column_safe?, ::Repository, 'name')).to be false
    end

    specify 'rejects a column whose type has no ordering (xml)' do
      expect {
        klass.send(:validate_column!, ::Depiction, 'svg_clip')
      }.to raise_error(ArgumentError, /cannot be ordered/)
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

    specify 'allows User when the terminal column is its display name' do
      expect {
        Queries::Note::Sort.send(:association, :creator, :name)
      }.not_to raise_error
    end

    specify 'rejects User for any other terminal column' do
      expect {
        Queries::Note::Sort.send(:association, :creator, :email)
      }.to raise_error(ArgumentError, /not reachable for sorting/)
    end

    specify 'rejects User reached through a has_many hop' do
      expect {
        klass.send(:build_sort_lambda, ::Project, [:users], 'email', :aggregate)
      }.to raise_error(ArgumentError, /not reachable for sorting/)
    end

    specify 'allows User reached through a has_many hop when the terminal column is its display name' do
      expect {
        klass.send(:build_sort_lambda, ::Project, [:users], 'name', :aggregate)
      }.not_to raise_error
    end
  end

  context 'association() guardrails' do
    specify 'rejects an association chain deeper than MAX_DEPTH' do
      expect {
        klass.send(:association, :a, :b, :c, :d, :name)
      }.to raise_error(ArgumentError, /too deep/)
    end

    specify 'rejects an unknown association' do
      expect {
        klass.send(:association, :no_such_association, :name)
      }.to raise_error(ArgumentError, /no association/)
    end

    specify 'rejects a has_many hop with no collapse: given' do
      expect {
        klass.send(:association, :identifiers, :cached)
      }.to raise_error(ArgumentError, /collapse: is required/)
    end

    specify 'rejects collapse: :aggregate combined with further hops' do
      expect {
        klass.send(:association, :taxon_determinations, :otu, :name, collapse: :aggregate)
      }.to raise_error(ArgumentError, /cannot be combined with further hops/)
    end

    context 'on: (association declared on an STI subclass)' do
      let(:source_filter) { Queries::Source::Sort }

      specify 'the association is not reachable from the base class' do
        expect {
          source_filter.send(:association, :serial, :name)
        }.to raise_error(ArgumentError, /no association/)
      end

      specify 'reflects on the given subclass' do
        expect {
          source_filter.send(:association, :serial, :name, on: ::Source::Bibtex)
        }.not_to raise_error
      end

      specify 'rejects a class that is not a subclass of the filtered class' do
        expect {
          source_filter.send(:association, :serial, :name, on: ::Serial)
        }.to raise_error(ArgumentError, /not a subclass/)
      end
    end

    specify 'rejects a bare belongs_to fk column as the terminal column' do
      expect {
        klass.send(:association, :repository, :id)
      }.not_to raise_error # 'id' itself is not FK-shaped

      expect {
        klass.send(:association, :collecting_event, :geographic_area_id)
      }.to raise_error(ArgumentError, /raw foreign key/)
    end
  end

  context 'has_one hop' do
    # A plain join lets the planner choose a hash join for large results;
    # a LATERAL forces a per-row loop.
    specify 'is a plain LEFT JOIN, not a LATERAL' do
      sql = Queries::Pager.new(CollectionObject.all, sort: 'dwc_occurrence.scientificName').all.to_sql
      expect(sql).not_to include('LATERAL')
      expect(sql).to include('LEFT JOIN dwc_occurrences AS sort_dwc_occurrence ON sort_dwc_occurrence.dwc_occurrence_object_id = collection_objects.id')
      expect(sql).to include(%(sort_dwc_occurrence.dwc_occurrence_object_type = 'CollectionObject'))
    end

    context 'followed by a belongs_to hop' do
      let(:sort) { Queries::Content::Sort.send(:association, :public_content, :otu, :name) }
      let!(:content_z) { FactoryBot.create(:valid_content, otu: FactoryBot.create(:valid_otu, name: 'Zed')) }
      let!(:content_a) { FactoryBot.create(:valid_content, otu: FactoryBot.create(:valid_otu, name: 'Alpha')) }

      # content_z is created first so id order and name order disagree.
      before { [content_z, content_a].each(&:publish) }

      specify 'joins both hops directly' do
        sql = sort.call(::Content.all, :asc).to_sql
        expect(sql).not_to include('LATERAL')
        expect(sql).to include('LEFT JOIN otus AS sort_public_content_otu ON sort_public_content_otu.id = sort_public_content.otu_id')
      end

      specify 'orders by the final column' do
        expect(sort.call(::Content.where(id: [content_z.id, content_a.id]), :asc).to_a).to eq([content_a, content_z])
      end
    end
  end

  context 'association shapes the resolver cannot honor' do
    specify 'rejects a scoped association (its conditions would be ignored)' do
      expect {
        Queries::Otu::Sort.send(:association, :origin_citation, :source, :cached)
      }.to raise_error(ArgumentError, /has a scope/)
    end

    specify 'rejects a scoped association as a later hop' do
      expect {
        Queries::Content::Sort.send(:association, :otu, :origin_citation, :pages)
      }.to raise_error(ArgumentError, /has a scope/)
    end

    specify 'rejects a scoped association inside a has_many LATERAL' do
      expect {
        klass.send(:association, :taxon_determinations, :otu, :origin_citation, :pages, collapse: :position)
      }.to raise_error(ArgumentError, /has a scope/)
    end

    specify 'rejects has_one :through' do
      expect {
        Queries::Otu::Sort.send(:association, :source, :cached)
      }.to raise_error(ArgumentError, /has_one :through/)
    end

    specify 'rejects has_one :through inside a has_many LATERAL' do
      expect {
        klass.send(:association, :taxon_determinations, :otu, :source, :cached, collapse: :position)
      }.to raise_error(ArgumentError, /has_one :through/)
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

    specify 'sortable_direct_columns excludes columns whose type has no ordering' do
      cols = Queries::Depiction::Sort.send(:sortable_direct_columns)
      expect(cols).to have_key('caption')
      expect(cols).not_to have_key('svg_clip')
    end

    specify 'sortable_association_columns includes the target class columns and excludes its fk-shaped ones' do
      cols = klass.send(:sortable_association_columns, :repository)
      expect(cols).to have_key('name')
      expect(cols).to have_key('id')
      expect(cols).not_to have_key('created_by_id')
      expect(cols.values).to all(be_a(Proc))
    end

    specify 'sortable_association_columns raises for an unknown association' do
      expect {
        klass.send(:sortable_association_columns, :no_such_association)
      }.to raise_error(ArgumentError, /no association/)
    end
  end

  context 'has_many :through shapes' do
    # The LATERAL walks one through table and one belongs_to source. Other
    # shapes would join the wrong columns, and skip the User and scope checks
    # for the classes in the middle of the chain.
    specify 'rejects a nested has_many :through' do
      expect {
        Queries::TaxonName::Sort.send(:association, :collection_objects, :total, collapse: :aggregate)
      }.to raise_error(ArgumentError, /use custom\(\)/)
    end

    specify 'rejects a has_many source' do
      expect {
        Queries::TaxonName::Sort.send(:association, :taxon_determinations, :position, collapse: :position)
      }.to raise_error(ArgumentError, /use custom\(\)/)
    end

    specify 'rejects a through belongs_to' do
      expect {
        klass.send(:association, :georeferences, :error_radius, collapse: :aggregate)
      }.to raise_error(ArgumentError, /use custom\(\)/)
    end
  end

  context 'join aliases' do
    # Two keys reaching an association of the same name through different
    # parents must not share an alias.
    specify 'differ for the same association reached through different parents' do
      by_repository = klass.send(:association, :repository, :identifiers, :cached, collapse: :joined)
      by_current = klass.send(:association, :current_repository, :identifiers, :cached, collapse: :joined)

      q = by_current.call(by_repository.call(CollectionObject.all, :asc), :asc)
      expect { q.to_a }.not_to raise_error
    end
  end

  context 'STI targets' do
    let(:otu) { FactoryBot.create(:valid_otu) }
    # Biocuration groups tag biocuration classes.
    let(:biocuration_class) { FactoryBot.create(:valid_biocuration_class) }
    let(:group) { BiocurationGroup.create!(name: 'Aaa group', definition: 'A group of biocuration classes.') }
    let(:keyword) { Keyword.create!(name: 'Zzz keyword', definition: 'A keyword for sorting by.') }

    # A join to a class with STI subclasses includes the subclasses' rows,
    # as the association itself does.
    specify 'a non-leaf STI target includes its subclasses' do
      tag_z = Tag.create!(keyword:, tag_object: otu)
      tag_a = Tag.create!(keyword: group, tag_object: biocuration_class)
      sort = Queries::Tag::Sort.send(:association, :keyword, :name)

      expect(sort.call(Tag.where(id: [tag_z.id, tag_a.id]), :asc).to_a).to eq([tag_a, tag_z])
    end
  end
end
