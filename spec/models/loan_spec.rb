require 'rails_helper'

describe Loan, type: :model, group: :loans do

  let(:loan) { Loan.new() }

  specify 'with lender_address and date_return_expected' do
    loan.lender_address = '123 N. South'
    loan.date_return_expected = Time.now.to_date
    expect(loan.valid?).to be_truthy
  end

  context 'cloning records' do
    let(:cloned_attributes) {
      {
        lender_address: '123 S. North Av',
        recipient_address: '456 E. West St',
        recipient_email: 'foo@example.com',
        recipient_phone: '888-123-4567',
        recipient_country: 'USA',
        supervisor_email: 'bar@example.com',
        recipient_honorific: 'Dr.'
      }
    }

    before do
      loan.update(cloned_attributes.merge( date_return_expected: (Time.now + 2.days).to_date) )
    end

    context '#clone_from clones' do
      let(:loan1) { Loan.new(clone_from: loan.id) }

      Loan::CLONED_ATTRIBUTES.each do |a|
        specify "#{a}" do
          expect(loan1.send(a)).to eq(loan.send(a))
        end
      end
    end
  end

  context 'loan items' do
    context 'can be' do
      specify 'collection_objects' do
        expect(loan.loan_items.build(loan_item_object: Specimen.create)).to be_truthy
      end
    end
  end

  context '#loan_items' do

    # build container hierarchy
    let(:specimen) { Specimen.create }
    let(:vial) { Container.containerize([specimen], Container::Vial) }
    let(:vial_rack) { Container.containerize([vial], Container::VialRack) }
    let(:room) { Container.containerize([vial_rack], Container::Room) }
    let(:building) { Container.containerize([room], Container::Building) }
    let(:site) { Container.containerize([building], Container::Site) }

    before { loan.update(lender_address: '123 N. South St.', date_return_expected: Time.now.to_date) }

    context 'enumerating loan items' do
      before  do
        loan.loan_items << LoanItem.new(loan_item_object: specimen)
      end

      specify '#loan_items' do
        expect(loan.loan_items.first.persisted?).to be_truthy
      end

      specify '#collection_objects' do
        expect(loan.collection_objects).to contain_exactly(specimen)
      end

      specify 'can not be destroyed' do
        expect(loan.destroy).to be_falsey
      end
    end

    context 'objects via containers' do
      before { loan.loan_items << LoanItem.new(loan_item_object: site) }

      specify '#collection_objects' do
        expect(loan.collection_objects).to contain_exactly(specimen)
      end
    end

    context 'objects via Otus' do
      let(:otu) { Otu.create(name: 'Blobasaurus') }
      let!(:determination) { TaxonDetermination.create(otu: otu, biological_collection_object: specimen) }

      before do
        loan.loan_items << LoanItem.new(loan_item_object: otu)
      end

      specify '#collection_objects' do
        expect(loan.collection_objects).to contain_exactly(specimen)
      end
    end

  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
