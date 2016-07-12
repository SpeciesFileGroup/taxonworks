require 'rails_helper'

describe Loan, :type => :model do

  context 'concerns' do
    it_behaves_like 'is_data'
  end

  context 'loan with items' do
    # build container hierarchy
    let(:specimens) { [Specimen.create, Specimen.create] }
    let(:vial) { Container.containerize(specimens, Container::Vial) }
    let(:vial_rack) { Container.containerize([vial], Container::VialRack) }
    let(:room) { Container.containerize([vial_rack], Container::Room) }
    let(:building) { Container.containerize([room], Container::Building) }
    let(:site) { Container.containerize([building], Container::Site) }

    # build loan
    let!(:new_loan) { FactoryGirl.create(:valid_loan) }
    let(:loan) {
      new_loan.loan_items << loan_item_0
      new_loan.loan_items << loan_item_1
      new_loan.loan_items << loan_item_2
      new_loan
    }

    #build loan_items
    let(:specimen) { FactoryGirl.create(:valid_specimen) }
    let(:otu) { FactoryGirl.create(:valid_otu) }
    let(:loan_item_0) {
      site.save
      FactoryGirl.create(:loan_item, {loan:             new_loan,
                                      loan_item_object: site})
    }
    let(:loan_item_1) { FactoryGirl.create(:valid_loan_item, {loan:             new_loan,
                                                              loan_item_object: specimen}) }
    let(:loan_item_2) { FactoryGirl.create(:valid_loan_item, {loan:             new_loan,
                                                              loan_item_object: otu}) }

    specify 'create a valid loan' do
      expect(loan.valid?).to be_truthy
    end

    specify 'finding collection object from a complex loan' do

    end
  end

  context 'loan_items' do
    let(:loan1) { li_specimen.loan }

    let(:li_specimen) { FactoryGirl.create(:valid_loan_item_specimen) }

    context 'create a loan item' do
      specify 'create an OTU loan item' do
        expect(true).to be_truthy
      end
      specify 'create a collection object loan item' do
        expect(true).to be_truthy
      end
      describe 'create a container loan item' do
        specify 'create some collection objects to put in a container' do
          expect(true).to be_truthy
        end

      end
    end
  end
end
