require 'rails_helper'

describe 'Papertrail', type: :model do

  let(:o) { Otu.new(name: 'first_name') }

  context 'test framework has versioning off' do
    before do
      o.save!
      o.update_attribute(:name, :second_version)
    end

    specify 'should not be added' do
      expect(o.versions.count).to eq(0)
    end
  end

  context 'test framework has versioning on' do
    context 'versions' do
      context 'on create' do
        before do
          with_versioning do
            o.save!
          end
        end

        specify 'should not be added' do
          expect(o.versions.count).to eq(0)
        end

        context 'after update' do
          before do
            with_versioning do
              o.update_attribute(:name, :second_version)
            end
          end

          specify 'should be added' do
            expect(o.versions.count).to eq(1)
          end

          specify '#whodunnit should be set' do
            expect(o.versions.first.whodunnit).to eq('1')
          end
        end
      end
    end
  end
end
