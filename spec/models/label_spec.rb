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
    let(:total) { 3 }

    let!(:ce1) { FactoryBot.create(:collecting_event, verbatim_label: 'Label with  spaces') }
    let!(:ce2) { FactoryBot.create(:collecting_event, verbatim_label: "Label with\nnewline") }
    let!(:ce3) { FactoryBot.create(:collecting_event, verbatim_label: '') }

    before do
      query_params = {
        collecting_event_id: [ce1.id, ce2.id, ce3.id]
      }
      Label.batch_create(query_params, total)
    end

    specify 'creates labels with correct text, skipping blank labels' do
      expect(Label.all.pluck(:text)).to contain_exactly('Label with  spaces', "Label with\nnewline")
    end

    specify 'sets total correctly on all labels' do
      expect(Label.all.pluck(:total).uniq).to eq([total])
    end
  end

end
