require 'rails_helper'

describe 'Housekeeping::User' do

  let!(:user) {FactoryGirl.create(:valid_user, id: 1)}
  let!(:other_user) {FactoryGirl.create(:valid_user, id: 2)}

  context 'Users' do

    let(:instance) {
      stub_model(HousekeepingTestClass::WithUser, id: 10)
    }

    context 'associations' do
      specify 'creator' do
        expect(instance).to respond_to(:creator)
      end

      specify 'updater' do
        expect(instance).to respond_to(:updater)
      end
    end

    context '#by=' do
      specify 'is a an available settor' do
        expect(instance.by = user).to be_truthy
      end

      context 'with a new record' do
        let(:new_record) { HousekeepingTestClass::WithUser.new }
        specify 'sets creator and updater when provided' do
          new_record.by = user
          expect(new_record.creator).to eq(user)
          expect(new_record.updater).to eq(user)
        end
      end

      specify 'works with a previously saved record' do
        instance.by = user
        expect(instance.creator).to eq(user)
        expect(instance.updater).to eq(user)
      end

      specify 'does not override creator' do
        instance.creator = user 
        instance.by = other_user
        expect(instance.creator).to eq(user)
      end

      specify 'works with update_attributes' do
        instance.update_attributes(by: user)
        expect(instance.updater).to eq(user)
        expect(instance.creator).to eq(user)
      end

      specify 'with new(), set order depends on last one provided, which should not be done' do
        a = HousekeepingTestClass::WithUser.new(updater: other_user, by: user)
        expect(a.updater).to eq(user)

        b = HousekeepingTestClass::WithUser.new(by: user, updater: other_user)
        expect(b.updater).to eq(other_user)
      end

    end

    context 'auto-population and validation' do
      let(:i) { HousekeepingTestClass::WithUser.new }

      context 'presence of the id itself' do
        before(:each) { $user_id = nil } 

        specify 'created_by_id is required' do
          i.valid?
          expect(i.errors.include?(:creator)).to be_truthy
        end

        specify 'updated_by_id is required' do
          i.valid?
          expect(i.errors.include?(:updater)).to be_truthy
        end
      end

      context 'presence in database' do
        before(:each) { $user_id = 49999 } # better not be one, but fragile

        specify 'creator must exist' do
          i.valid? 
          expect(i.errors.include?(:creator)).to be_truthy
        end

        specify 'updater must exist' do
          i.valid? 
          expect(i.errors.include?(:updater)).to be_truthy
        end
      end

      context 'population' do
        context 'on new()' do
          context 'when not previously provided' do
            before {
              $user_id = user.id
              i.valid?
            }
            specify 'creator should be set' do
              expect(i.creator).to eq(user)
            end

            specify 'updater should be set' do
              expect(i.updater).to eq(user)
            end
          end

          context 'when provided' do
            before {
              $user_id = user.id
              i.created_by_id = other_user.id 
              i.updated_by_id = other_user.id 
              i.valid? 
            }
            specify 'creator should not be overridden' do
              expect(i.creator).to eq(other_user)
            end

            specify 'updater should not be overridden' do
              expect(i.updater).to eq(other_user)
            end
          end
        end

        context 'on create()' do
          before {
            $user_id = user.id
          }
          let(:created_instance) { HousekeepingTestClass::WithUser.create() }

          specify 'creator is set' do
            expect(created_instance.creator).to eq(user)
          end

          specify 'updater is set' do
            expect(created_instance.updater).to eq(user)
          end
        end

        context 'on create!()' do
          before {
            $user_id = user.id
          }
          let(:created_instance) { HousekeepingTestClass::WithUser.create!() }

          specify 'creator is set' do
            expect(created_instance.creator).to eq(user)
          end

          specify 'updater is set' do
            expect(created_instance.updater).to eq(user)
          end
        end

        context 'on save!()' do
          before {
            $user_id = user.id
          }
          let(:created_instance) { 
            a = HousekeepingTestClass::WithUser.new() 
            a.save! 
            a
          }

          specify 'creator is set' do
            expect(created_instance.creator).to eq(user)
          end

          specify 'updater is set' do
            expect(created_instance.updater).to eq(user)
          end
        end

               

        context 'after save, subsequent updates' do
          before {
            $user_id = user.id
            i.save!
          }
 
          context 'on updated and updater is provided' do
            before {
              i.updated_by_id = other_user.id 
              i.valid? 
            }
            specify 'updater should be that provided' do
              expect(i.updater).to eq(other_user)
            end
          end

          context 'on updated and updater is not provided' do
            before {
              $user_id = other_user.id 
              i.string = "Foo"
              i.valid? 
            }

            specify 'updater should be that provided' do
              expect(i.updater).to eq(other_user)
            end
          end

          context 'on update when not changed and $user_id = nil' do
            before {
              $user_id = nil
              i.string = "Bar"
            }

            specify 'updater is updated to nil, and record is no longer valid' do
              expect(i.valid?).to be_falsey
            end
          end
        end
      end
    end

    context 'class method' do
      specify 'all creators' do
        expect(HousekeepingTestClass::WithUser).to respond_to(:all_creators)
      end

      specify 'all updaters' do
        expect(HousekeepingTestClass::WithUser).to respond_to(:all_updaters)
      end
    end
  end
end

module HousekeepingTestClass
  class WithBoth  < ActiveRecord::Base 
    include FakeTable  
    include Housekeeping 
  end

  class WithUser < ActiveRecord::Base
    include FakeTable 
    include Housekeeping::Users 
  end

end
