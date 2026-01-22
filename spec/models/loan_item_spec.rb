require 'rails_helper'

describe LoanItem, type: :model, group: :loans do

  let(:loan_item) { LoanItem.new }
  let(:valid_loan_item) { FactoryBot.create(:valid_loan_item) }
  let(:loan) { FactoryBot.create(:valid_loan) }

  specify '#loan is required' do
    loan_item.valid?
    expect(loan_item.errors.include?(:loan) ).to be_truthy
  end

  specify '#loan_item_object is required' do
    loan_item.valid?
    expect(loan_item.errors.include?(:loan_item_object) ).to be_truthy
  end

  specify '#loan_item_object must be loanable' do
    loan_item.loan_item_object = FactoryBot.create(:valid_source)
    loan_item.valid?
    expect(loan_item.errors.full_messages.include?('Loan item object is not loanble') ).to be_truthy
  end

  specify 'total can not be provided for Container' do
    loan_item.total = 4
    loan_item.loan_item_object_type = 'CollectionObject'
    loan_item.valid?
    expect(loan_item.errors.include?(:total)).to be_truthy
  end

  specify 'OTU can be loaned 2x' do
    o = Otu.create!(name: 'giveaway')
    loan_item.update!(loan:, loan_item_object: o)
    o.reload
    expect(LoanItem.create!(loan_item_object: o, loan:)).to be_truthy
  end

  specify 'collection object can NOT be loaned 2x' do
    s = Specimen.create!
    loan_item.update!(loan_item_object: s, loan:)
    s.reload
    expect(LoanItem.new(loan_item_object: s, loan:).valid?).to be_falsey
  end

  specify 'loan item can be created when object previously returned from loan' do
    s = Specimen.create!
    loan_item.update!(loan:, loan_item_object: s, date_returned: Time.current.to_date )
    s.reload
    expect(LoanItem.new(loan_item_object: s, loan: FactoryBot.create(:valid_loan)).valid?).to be_truthy
  end

  specify '#disposition can be updated on CollectionObject' do
    loan_item.update!(loan:, loan_item_object: Specimen.create!)
    expect(loan_item.update!(disposition: 'Donated')).to be_truthy
  end

  specify '#disposition can be updated on Otu' do
    loan_item.update!(loan:, loan_item_object: Otu.create!(name: 'loany'))
    expect(loan_item.update!(disposition: 'Donated')).to be_truthy
  end

  context 'as part of a loan' do
    before { loan_item.loan = loan }

    specify 'a specimen can be added to loan item' do
      loan_item.loan_item_object = FactoryBot.create(:valid_specimen)
      expect(loan_item.valid?).to be_truthy
    end

    specify 'a container can be added to loan item' do
      loan_item.loan_item_object = FactoryBot.create(:valid_container)
      expect(loan_item.valid?).to be_truthy
    end

    specify 'an OTU alone can be added to loan item' do
      loan_item.loan_item_object = FactoryBot.create(:valid_otu)
      expect(loan_item.valid?).to be_truthy
    end
  end

  context 'status' do
    context 'while on loan' do
      before { loan_item.date_returned = nil }

      specify '#returned? is false' do
        expect(loan_item.returned?).to be_falsey
      end
    end

    context 'when returned' do
      before { loan_item.date_returned = Time.now }

      specify '#returned? is true' do
        expect(loan_item.returned?).to be_truthy
      end
    end
  end

  context 'batch' do

  let(:s1) { FactoryBot.create(:valid_specimen) }
    let(:s2) { FactoryBot.create(:valid_specimen) }
    let(:o1) { FactoryBot.create(:valid_otu) }
    let(:o2) { FactoryBot.create(:valid_otu) }
    let(:c1) { FactoryBot.create(:valid_container) }
    let(:c2) { FactoryBot.create(:valid_container) }

    context '.batch_move' do

      let(:loan2) { FactoryBot.create(:valid_loan) }

      before do
        LoanItem.create!(loan_item_object: s1, loan:)
        LoanItem.create!(loan_item_object: s2, loan:)
      end

      specify 'moves' do
        r = LoanItem.batch_move(
          loan_id: loan2.id,
          collection_object_query: {},
          disposition: 'Returned',
          date_returned: Time.current.to_date,
          user_id:,
          )

        expect(r[:moved].size).to eq(2)

        expect(LoanItem.all.reload.size).to eq(4)

        expect(LoanItem.last.loan_id).to eq(loan2.id)
        expect(LoanItem.first.disposition).to eq('Returned')
        expect(LoanItem.first.date_returned).to eq(Time.current.to_date)
      end
    end

    context '.batch_create batch_type=collection_object_filter' do
      before do
        s1
        s2
      end
      specify 'creates' do
        LoanItem.batch_create(collection_object_query: {}, batch_type: 'collection_object_filter', loan_id: loan.id)
        expect(LoanItem.all.count).to eq(2)
      end
    end

    context '.batch_return' do
      let!(:li) {LoanItem.create!(loan:, loan_item_object: s1 )}
      let!(:li) {LoanItem.create!(loan:, loan_item_object: s2 )}

      specify 'returns' do
        LoanItem.batch_return(collection_object_query: {}, disposition: 'Returned', returned_on: Time.current.to_date )
        expect(LoanItem.where(disposition: nil).any?).to be_falsey
      end
    end

  context '.batch_create' do
    context 'from tags' do
      let(:keyword) { FactoryBot.create(:valid_keyword) }
      let!(:t1) { Tag.create(keyword:, tag_object: s1) }
      let!(:t2) { Tag.create(keyword:, tag_object: o2) }
      let!(:t3) { Tag.create(keyword:, tag_object: c1) }

      context 'not supplying klass' do
        let(:params) { { keyword_id: keyword.id, batch_type: 'tags', loan_id: loan.id } }
        before { LoanItem.batch_create(params) }
        specify 'loan_items are created for all types' do
          expect(LoanItem.count).to eq(3)
        end
      end

      context 'supplying klass' do
        let(:params) { { keyword_id: keyword.id, batch_type: 'tags', loan_id: loan.id } }

        specify 'Otu' do
          LoanItem.batch_create(params.merge(klass: 'Otu'))
          expect(LoanItem.count).to eq(1)
        end

        specify 'Container' do
          LoanItem.batch_create(params.merge(klass: 'Container'))
          expect(LoanItem.count).to eq(1)
        end

        specify 'CollectionObject' do
          LoanItem.batch_create(params.merge(klass: 'CollectionObject'))
          expect(LoanItem.count).to eq(1)
        end
      end
    end

    context 'from pinboard' do
      let!(:p1) { PinboardItem.create!(pinned_object: s1, user_id:) }
      let!(:p2) { PinboardItem.create!(pinned_object: o2, user_id:) }
      let!(:p3) { PinboardItem.create!(pinned_object: c1, user_id:) }

      let(:params) { { batch_type: 'pinboard', loan_id: loan.id, user_id:, project_id: } }

      context 'not supplying klass' do
        before { LoanItem.batch_create(params) }
        specify 'loan_items are created for all types' do
          expect(LoanItem.count).to eq(3)
        end
      end

      context 'supplying klass' do
        specify 'Otu' do
          LoanItem.batch_create(params.merge(klass: 'Otu'))
          expect(LoanItem.count).to eq(1)
        end

        specify 'Container' do
          LoanItem.batch_create(params.merge(klass: 'Container'))
          expect(LoanItem.count).to eq(1)
        end

        specify 'CollectionObject' do
          LoanItem.batch_create(params.merge(klass: 'CollectionObject'))
          expect(LoanItem.count).to eq(1)
        end

      end
    end
  end

    context '.batch_by_filter_scope' do
      before do
        s1
        s2
      end

      specify 'creates loan items with :add mode' do
        q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id, s2.id])
        result = LoanItem.batch_by_filter_scope(
          filter_query: {'collection_object_query' => q.params},
          mode: :add,
          params: {loan_id: loan.id},
          project_id:,
          user_id:
        )

        expect(result[:updated].size).to eq(2)
        expect(result[:not_updated]).to be_empty
        expect(result[:total_attempted]).to eq(2)
        expect(LoanItem.count).to eq(2)
      end

      specify 'returns error when loan_id not provided' do
        q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id, s2.id])
        result = LoanItem.batch_by_filter_scope(
          filter_query: {'collection_object_query' => q.params},
          mode: :add,
          params: {},
          project_id:,
          user_id:
        )

        expect(result[:errors]).to include('no loan_id provided' => 1)
        expect(LoanItem.count).to eq(0)
      end

      specify 'tracks items that cannot be added in not_updated' do
        # Create a loan item for s1 so it's already on loan
        LoanItem.create!(loan:, loan_item_object: s1)

        q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id, s2.id])
        result = LoanItem.batch_by_filter_scope(
          filter_query: {'collection_object_query' => q.params},
          mode: :add,
          params: {loan_id: loan.id},
          project_id:,
          user_id:
        )

        expect(result[:updated].size).to eq(1) # only s2
        expect(result[:not_updated].size).to eq(1) # s1 already on loan
        expect(result[:errors]).to be_empty # per-item errors not tracked in errors hash
        expect(LoanItem.count).to eq(2) # original + s2
      end

      specify 'populates validation_errors with reasons for failure' do
        # Create a loan item for s1 so it's already on loan
        LoanItem.create!(loan:, loan_item_object: s1)

        q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id, s2.id])
        result = LoanItem.batch_by_filter_scope(
          filter_query: {'collection_object_query' => q.params},
          mode: :add,
          params: {loan_id: loan.id},
          project_id:,
          user_id:
        )

        expect(result[:validation_errors]).not_to be_empty
        expect(result[:validation_errors].values.sum).to eq(1) # 1 item failed
        expect(result[:validation_errors].first.first).to include('already on loan')
      end

      context ':return mode' do
        let!(:li1) { LoanItem.create!(loan:, loan_item_object: s1) }
        let!(:li2) { LoanItem.create!(loan:, loan_item_object: s2) }

        specify 'returns loan items' do
          q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id, s2.id])
          result = LoanItem.batch_by_filter_scope(
            filter_query: {'collection_object_query' => q.params},
            mode: :return,
            params: {disposition: 'Returned', date_returned: Time.current.to_date},
            project_id:,
            user_id:
          )

          expect(result[:updated].size).to eq(2)
          expect(result[:not_updated]).to be_empty
          expect(li1.reload.disposition).to eq('Returned')
          expect(li2.reload.disposition).to eq('Returned')
        end

        specify 'returns error when disposition not provided' do
          q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id])
          result = LoanItem.batch_by_filter_scope(
            filter_query: {'collection_object_query' => q.params},
            mode: :return,
            params: {date_returned: Time.current.to_date},
            project_id:,
            user_id:
          )

          expect(result[:errors]).to include('no disposition provided' => 1)
        end

        specify 'tracks items not on loan in not_updated' do
          s3 = FactoryBot.create(:valid_specimen) # not on loan
          q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id, s3.id])
          result = LoanItem.batch_by_filter_scope(
            filter_query: {'collection_object_query' => q.params},
            mode: :return,
            params: {disposition: 'Returned', date_returned: Time.current.to_date},
            project_id:,
            user_id:
          )

          expect(result[:updated].size).to eq(1) # only s1
          expect(result[:not_updated].size).to eq(1) # s3 not on loan
        end

        specify 'populates validation_errors when items not on loan' do
          s3 = FactoryBot.create(:valid_specimen) # not on loan
          q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s3.id])
          result = LoanItem.batch_by_filter_scope(
            filter_query: {'collection_object_query' => q.params},
            mode: :return,
            params: {disposition: 'Returned', date_returned: Time.current.to_date},
            project_id:,
            user_id:
          )

          expect(result[:validation_errors]).to include('not currently on loan' => 1)
        end

        specify 'finds items with disposition set but date_returned nil' do
          # Item has disposition but hasn't been physically returned yet
          li1.update_column(:disposition, 'Retained')
          s1.reload

          q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id])
          result = LoanItem.batch_by_filter_scope(
            filter_query: {'collection_object_query' => q.params},
            mode: :return,
            params: {disposition: 'Returned', date_returned: Time.current.to_date},
            project_id:,
            user_id:
          )

          expect(result[:updated].size).to eq(1)
          expect(result[:not_updated]).to be_empty
        end
      end

      context ':move mode' do
        let(:loan2) { FactoryBot.create(:valid_loan) }
        let!(:li1) { LoanItem.create!(loan:, loan_item_object: s1) }
        let!(:li2) { LoanItem.create!(loan:, loan_item_object: s2) }

        specify 'moves loan items to new loan' do
          q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id, s2.id])
          result = LoanItem.batch_by_filter_scope(
            filter_query: {'collection_object_query' => q.params},
            mode: :move,
            params: {loan_id: loan2.id, disposition: 'Returned', date_returned: Time.current.to_date},
            project_id:,
            user_id:
          )

          expect(result[:updated].size).to eq(2)
          expect(result[:not_updated]).to be_empty
          expect(li1.reload.disposition).to eq('Returned')
          expect(LoanItem.where(loan: loan2).count).to eq(2)
        end

        specify 'returns error when loan_id not provided' do
          q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id])
          result = LoanItem.batch_by_filter_scope(
            filter_query: {'collection_object_query' => q.params},
            mode: :move,
            params: {disposition: 'Returned', date_returned: Time.current.to_date},
            project_id:,
            user_id:
          )

          expect(result[:errors]).to include('no loan_id provided' => 1)
        end

        specify 'populates validation_errors when items not on loan' do
          s3 = FactoryBot.create(:valid_specimen) # not on loan
          q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s3.id])
          result = LoanItem.batch_by_filter_scope(
            filter_query: {'collection_object_query' => q.params},
            mode: :move,
            params: {loan_id: loan2.id, disposition: 'Returned', date_returned: Time.current.to_date},
            project_id:,
            user_id:
          )

          expect(result[:validation_errors]).to include('not currently on loan' => 1)
        end

        specify 'finds items with disposition set but date_returned nil' do
          # Item has disposition but hasn't been physically returned yet
          li1.update_column(:disposition, 'Retained')
          s1.reload

          q = ::Queries::CollectionObject::Filter.new(collection_object_id: [s1.id])
          result = LoanItem.batch_by_filter_scope(
            filter_query: {'collection_object_query' => q.params},
            mode: :move,
            params: {loan_id: loan2.id, disposition: 'Returned', date_returned: Time.current.to_date},
            project_id:,
            user_id:
          )

          expect(result[:updated].size).to eq(1)
          expect(result[:not_updated]).to be_empty
        end
      end
    end
end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
