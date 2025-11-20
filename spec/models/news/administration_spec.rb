require 'rails_helper'

RSpec.describe News::Administration, type: :model do
  let(:admin_user) { FactoryBot.create(:administrator) }
  let(:regular_user) { FactoryBot.create(:valid_user) }

  context 'validation' do
    specify 'requires project_id to be absent' do
      project = FactoryBot.create(:valid_project)
      news = News::Administration::Notice.new(
        title: 'Admin News',
        body: 'Admin body',
        project_id: project.id,
      )
      expect(news.valid?).to be_falsey
      expect(news.errors[:project_id]).to include("must be blank")
    end

    context 'creator_must_be_administrator' do


      specify 'allows creation by administrator' do
        news = News::Administration::Notice.new(
          title: 'Admin News',
          body: 'Admin body',
          created_by_id: admin_user.id,
          updated_by_id: admin_user.id
        )
        expect(news.valid?).to be_truthy
        expect(news.save).to be_truthy
      end

      specify 'prevents creation by non-administrator' do
        news = News::Administration::Warning.new(
          title: 'Admin News',
          body: 'Admin body',
        )
        expect(news.valid?).to be_falsey
        expect(news.errors[:base]).to include('only administrators can edit administration news')
      end

      specify 'prevents creation when user with created_by_id does not exist' do
        news = News::Administration::BlogPost.new(
          title: 'Admin News',
          body: 'Admin body',
          created_by_id: 999999, # Non-existent user ID
          updated_by_id: admin_user.id
        )
        news.valid?
        expect(news.errors[:base]).to include('only administrators can edit administration news')
      end

      specify 'runs after other validations' do
        # Test that even with invalid data, the creator validation still runs
        news = News::Administration::Notice.new(
          title: nil, # Invalid - missing title
          body: nil,  # Invalid - missing body
          by: regular_user.id
        )
        expect(news.valid?).to be_falsey

        # Should have both title/body errors AND the creator error
        expect(news.errors[:title]).to include("can't be blank")
        expect(news.errors[:body]).to include("can't be blank")
        expect(news.errors[:base]).to include('only administrators can edit administration news')
      end
    end
  end

  context 'factories' do
    specify 'news_administration factory creates valid News::Administration' do
      news = FactoryBot.build(:news_administration)
      expect(news).to be_valid
      expect(news).to be_a(News::Administration)
    end

    specify 'news_administration factory creates with admin user by default' do
      news = FactoryBot.build(:news_administration)
      expect(news.creator).to be_is_administrator
    end

    specify 'news_administration factory accepts custom admin user' do
      custom_admin = FactoryBot.create(:administrator)
      news = FactoryBot.build(:news_administration, by: custom_admin)
      expect(news.created_by_id).to eq(custom_admin.id)
      expect(news.updated_by_id).to eq(custom_admin.id)
    end
  end
end
