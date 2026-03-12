# Specs to verify that job isolation actually works.
# These test the isolation mechanism itself, not individual jobs.
#
require 'rails_helper'

RSpec.describe 'Job Current isolation' do
  include ActiveJob::TestHelper
  # Test job that records what it saw
  class TestIsolationJob < ApplicationJob
    cattr_accessor :saw_user_id, :saw_project_id, :saw_locale

    def perform
      self.class.saw_user_id = Current.user_id
      self.class.saw_project_id = Current.project_id
      self.class.saw_locale = I18n.locale
    end
  end

  before do
    TestIsolationJob.saw_user_id = nil
    TestIsolationJob.saw_project_id = nil
    TestIsolationJob.saw_locale = nil
  end

  after do
    I18n.locale = I18n.default_locale
    Current.reset
  end

  describe 'ActiveJob isolation' do
    context 'with perform_now' do
      specify 'resets Current.user_id before job execution' do
        Current.user_id = 123
        TestIsolationJob.perform_now
        expect(TestIsolationJob.saw_user_id).to be_nil
      end

      specify 'resets Current.project_id before job execution' do
        Current.project_id = 456
        TestIsolationJob.perform_now
        expect(TestIsolationJob.saw_project_id).to be_nil
      end

      specify 'resets I18n.locale to default before job execution' do
        I18n.locale = :de
        TestIsolationJob.perform_now
        expect(TestIsolationJob.saw_locale).to eq(I18n.default_locale)
      end

      specify 'restores Current.user_id after job execution' do
        Current.user_id = 123
        TestIsolationJob.perform_now
        expect(Current.user_id).to eq(123)
      end

      specify 'restores Current.project_id after job execution' do
        Current.project_id = 456
        TestIsolationJob.perform_now
        expect(Current.project_id).to eq(456)
      end

      specify 'restores I18n.locale after job execution' do
        I18n.locale = :de
        TestIsolationJob.perform_now
        expect(I18n.locale).to eq(:de)
      end

      specify 'handles jobs that raise errors without leaving context polluted' do
        Current.user_id = 999

        error_job = Class.new(ApplicationJob) do
          def perform
            raise StandardError, 'test error'
          end
        end

        expect { error_job.perform_now }.to raise_error(StandardError)
        expect(Current.user_id).to eq(999)  # Should be restored despite error
      end
    end

    context 'with perform_enqueued_jobs' do
      specify 'resets Current.user_id before job execution' do
        Current.user_id = 123
        TestIsolationJob.perform_later
        perform_enqueued_jobs
        expect(TestIsolationJob.saw_user_id).to be_nil
      end

      specify 'resets Current.project_id before job execution' do
        Current.project_id = 456
        TestIsolationJob.perform_later
        perform_enqueued_jobs
        expect(TestIsolationJob.saw_project_id).to be_nil
      end

      specify 'restores Current.user_id after job execution' do
        Current.user_id = 789
        TestIsolationJob.perform_later
        perform_enqueued_jobs
        expect(Current.user_id).to eq(789)
      end

      specify 'restores Current.project_id after job execution' do
        Current.project_id = 321
        TestIsolationJob.perform_later
        perform_enqueued_jobs
        expect(Current.project_id).to eq(321)
      end

      specify 'handles jobs that raise errors without leaving context polluted' do
        Current.user_id = 888
        Current.project_id = 777

        error_job = Class.new(ApplicationJob) do
          def perform
            raise StandardError, 'test error'
          end
        end

        error_job.perform_later
        expect { perform_enqueued_jobs }.to raise_error(StandardError)
        expect(Current.user_id).to eq(888)     # Should be restored despite error
        expect(Current.project_id).to eq(777)  # Should be restored despite error
      end
    end
  end

  describe 'Delayed::Job isolation' do
    class TestDelayedJob
      def perform
        TestIsolationJob.saw_user_id = Current.user_id
        TestIsolationJob.saw_project_id = Current.project_id
        TestIsolationJob.saw_locale = I18n.locale
      end
    end

    specify 'resets Current.user_id before processing jobs' do
      Current.user_id = 123
      Delayed::Job.enqueue(TestDelayedJob.new)
      Delayed::Worker.new.work_off
      expect(TestIsolationJob.saw_user_id).to be_nil
    end

    specify 'resets Current.project_id before processing jobs' do
      Current.project_id = 456
      Delayed::Job.enqueue(TestDelayedJob.new)
      Delayed::Worker.new.work_off
      expect(TestIsolationJob.saw_project_id).to be_nil
    end

    specify 'restores Current values after processing jobs' do
      Current.user_id = 123
      Current.project_id = 456
      Delayed::Job.enqueue(TestDelayedJob.new)
      Delayed::Worker.new.work_off
      expect(Current.user_id).to eq(123)
      expect(Current.project_id).to eq(456)
    end

    specify 'handles jobs that raise errors without leaving context polluted' do
      Current.user_id = 999

      error_job = Class.new do
        def perform
          raise StandardError, 'test error'
        end
      end

      Delayed::Job.enqueue(error_job.new)
      expect { Delayed::Worker.new.work_off }.not_to raise_error
      expect(Current.user_id).to eq(999)  # Should be restored despite error
    end
  end
end
