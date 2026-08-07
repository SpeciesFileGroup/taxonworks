require 'rails_helper'

RSpec.describe SqedDepictionPreprocessJob, type: :model do

  context 'job configuration' do
    specify 'queues in sqed_preprocess queue' do
      expect {
        SqedDepictionPreprocessJob.perform_later(sqed_depiction_id: 1)
      }.to have_enqueued_job(SqedDepictionPreprocessJob)
        .with(sqed_depiction_id: 1)
        .on_queue('sqed_preprocess')
    end
  end

  context 'perform' do
    let(:sqed_depiction) { FactoryBot.create(:valid_sqed_depiction) }

    specify 'calls preprocess(false) on the identified record' do
      expect_any_instance_of(SqedDepiction).to receive(:preprocess).with(false)
      SqedDepictionPreprocessJob.perform_now(sqed_depiction_id: sqed_depiction.id)
    end

    specify 'does nothing when the record is not found' do
      expect {
        SqedDepictionPreprocessJob.perform_now(sqed_depiction_id: 0)
      }.not_to raise_error
    end
  end

  context 'after_create_commit' do
    specify 'enqueues a job when a SqedDepiction is created' do
      expect {
        FactoryBot.create(:valid_sqed_depiction)
      }.to have_enqueued_job(SqedDepictionPreprocessJob)
    end
  end

end
