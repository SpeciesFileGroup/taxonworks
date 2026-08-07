require 'rails_helper'

RSpec.describe Label, type: :model do

  let(:label) { Label.new }

  context 'validation' do

    specify 'label with no text is invalid' do
      expect(label.valid?).to be_falsey
    end

    specify 'label with text and total is valid' do
      label.text = 'This is some text'
      label.total = 0
      expect(label.valid?).to be_truthy
    end
  end

  specify '.unprinted' do
    expect(Label.unprinted).to contain_exactly()
  end

  context '.batch_create' do
    let!(:ce1) { FactoryBot.create(:collecting_event, verbatim_label: 'Verbatim with  spaces', document_label: 'Document label 1', print_label: 'Print label 1') }
    let!(:ce2) { FactoryBot.create(:collecting_event, verbatim_label: "Verbatim with\nnewline", document_label: 'Document label 2', print_label: 'Print label 2') }
    let!(:ce3) { FactoryBot.create(:collecting_event, verbatim_label: '', document_label: '', print_label: '') }
    let!(:ce4) { FactoryBot.create(:collecting_event, verbatim_label: 'Only verbatim', document_label: nil, print_label: nil) }
    let!(:ce5) { FactoryBot.create(:collecting_event, verbatim_label: nil, document_label: 'Only document', print_label: nil) }

    let(:total) { 3 }
    let(:preview) { false }
    let(:query_params) {
      { collecting_event_id: [ce1.id, ce2.id, ce3.id, ce4.id, ce5.id] }
    }

    specify 'creates labels from verbatim_label, skipping blank labels' do
      result = Label.batch_create(query_params, :verbatim_label, total, preview)
      expect(Label.all.pluck(:text)).to contain_exactly('Verbatim with  spaces', "Verbatim with\nnewline", 'Only verbatim')
      expect(result.updated.count).to eq(3)
      expect(result.not_updated.count).to eq(2)
    end

    specify 'sets total correctly on all labels' do
      result = Label.batch_create(query_params, :verbatim_label, total, preview)
      expect(Label.all.pluck(:total).uniq).to eq([total])
    end

    specify 'creates labels only from document_label field' do
      result = Label.batch_create(query_params, 'document_label', total, preview)
      expect(Label.all.pluck(:text)).to contain_exactly('Document label 1', 'Document label 2', 'Only document')
      expect(result.updated.count).to eq(3)
      expect(result.not_updated.count).to eq(2)
    end

    specify 'creates labels only from print_label field' do
      result = Label.batch_create(query_params, :print_label, total, preview)
      expect(Label.all.pluck(:text)).to contain_exactly('Print label 1', 'Print label 2')
      expect(result.updated.count).to eq(2)
      expect(result.not_updated.count).to eq(3)
    end

    specify 'preview mode returns results without creating labels' do
      result = Label.batch_create(query_params, :verbatim_label, total, true)
      expect(Label.all.count).to eq(0)
      expect(result.updated.count).to eq(3)
      expect(result.not_updated.count).to eq(2)
    end
  end

end
