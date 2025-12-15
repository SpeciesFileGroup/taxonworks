require 'rails_helper'

RSpec.describe News, type: :model do
  let(:news) { News.new }

  context 'validation' do
    specify 'requires title' do
      news.body = 'Some body'
      expect(news.valid?).to be_falsey
      expect(news.errors[:title]).to include("can't be blank")
    end

    specify 'requires body' do
      news.title = 'Some title'
      expect(news.valid?).to be_falsey
      expect(news.errors[:body]).to include("can't be blank")
    end

    specify 'is valid with title and body' do
      news.title = 'Valid title'
      news.body = 'Valid body'
      news.type = 'News::Administration::Notice'
      expect(news.valid?).to be_truthy
    end

    context 'type validation' do
      specify 'requires Project type when project_id is present' do
        project = FactoryBot.create(:valid_project)
        news.title = 'Title'
        news.body = 'Body'
        news.project_id = project.id
        news.type = 'News::Administration::Notice'
        expect(news.valid?).to be_falsey
        expect(news.errors[:type]).to include('is not a project News type')
      end

      specify 'allows Project type when project_id is present' do
        project = FactoryBot.create(:valid_project)
        news.title = 'Title'
        news.body = 'Body'
        news.project_id = project.id
        news.type = 'News::Project::Notice'
        expect(news.valid?).to be_truthy
      end
    end

    context 'display date validation' do
      before do
        news.title = 'Title'
        news.body = 'Body'
        news.type = 'News::Administration::Notice'
      end

      specify 'is valid when display_end is later than display_start' do
        news.display_start = 1.day.ago
        news.display_end = 1.day.from_now
        expect(news.valid?).to be_truthy
      end

      specify 'is valid when only display_start is set' do
        news.display_start = 1.day.ago
        news.display_end = nil
        expect(news.valid?).to be_truthy
      end

      specify 'is valid when only display_end is set' do
        news.display_start = nil
        news.display_end = 1.day.from_now
        expect(news.valid?).to be_truthy
      end

      specify 'is valid when both are nil' do
        news.display_start = nil
        news.display_end = nil
        expect(news.valid?).to be_truthy
      end

      specify 'is invalid when display_end equals display_start' do
        time = Time.current
        news.display_start = time
        news.display_end = time
        expect(news.valid?).to be_falsey
        expect(news.errors[:display_end]).to include('must be later than display start')
      end

      specify 'is invalid when display_end is before display_start' do
        news.display_start = 1.day.from_now
        news.display_end = 1.day.ago
        expect(news.valid?).to be_falsey
        expect(news.errors[:display_end]).to include('must be later than display start')
      end
    end
  end

  context 'scopes' do
    let!(:project) { FactoryBot.create(:valid_project) }
    let!(:admin_news1) { FactoryBot.create(:news_administration, title: 'Admin News 1') }
    let!(:admin_news2) { FactoryBot.create(:news_administration, title: 'Admin News 2') }
    let!(:project_news) { FactoryBot.create(:news_project, title: 'Project News', project: project) }

    specify '.administration returns only administration news' do
      results = News.administration
      expect(results.map(&:id)).to contain_exactly(admin_news1.id, admin_news2.id)
    end

    specify '.project returns only project news' do
      results = News.project
      expect(results.map(&:id)).to contain_exactly(project_news.id)
    end

    context '.current' do
      let(:now) { Time.current }

      specify 'includes news with no start or end dates' do
        current = FactoryBot.create(:news_administration,
          display_start: nil,
          display_end: nil
        )
        expect(News.current).to include(current)
      end

      specify 'includes news that started in the past with no end date' do
        current = FactoryBot.create(:news_administration,
          display_start: 1.day.ago,
          display_end: nil
        )
        expect(News.current).to include(current)
      end

      specify 'includes news with no start date that ends in the future' do
        current = FactoryBot.create(:news_administration,
          display_start: nil,
          display_end: 1.day.from_now
        )
        expect(News.current).to include(current)
      end

      specify 'includes news that started in the past and ends in the future' do
        current = FactoryBot.create(:news_administration,
          display_start: 1.day.ago,
          display_end: 1.day.from_now
        )
        expect(News.current).to include(current)
      end

      specify 'excludes news that starts in the future' do
        future = FactoryBot.create(:news_administration,
          display_start: 1.day.from_now,
          display_end: nil
        )
        expect(News.current).not_to include(future)
      end

      specify 'excludes news that ended in the past' do
        past = FactoryBot.create(:news_administration,
          display_start: nil,
          display_end: 1.day.ago
        )
        expect(News.current).not_to include(past)
      end

      specify 'excludes news that ended in the past (with start date)' do
        past = FactoryBot.create(:news_administration,
          display_start: 2.days.ago,
          display_end: 1.day.ago
        )
        expect(News.current).not_to include(past)
      end

      specify 'excludes news that starts in the future and ends in the future' do
        future = FactoryBot.create(:news_administration,
          display_start: 1.day.from_now,
          display_end: 2.days.from_now
        )
        expect(News.current).not_to include(future)
      end
    end
  end

  context '#is_current?' do
    let(:news_item) { FactoryBot.build(:news_administration) }

    context 'with both display_start and display_end nil' do
      specify 'returns true' do
        news_item.display_start = nil
        news_item.display_end = nil
        expect(news_item.is_current?).to be_truthy
      end
    end

    context 'with display_start present and display_end nil' do
      specify 'returns true when display_start is in the past' do
        news_item.display_start = 1.day.ago
        news_item.display_end = nil
        expect(news_item.is_current?).to be_truthy
      end

      specify 'returns true when display_start is now' do
        news_item.display_start = Time.current
        news_item.display_end = nil
        expect(news_item.is_current?).to be_truthy
      end

      specify 'returns false when display_start is in the future' do
        news_item.display_start = 1.day.from_now
        news_item.display_end = nil
        expect(news_item.is_current?).to be_falsey
      end
    end

    context 'with display_start nil and display_end present' do
      specify 'returns true when display_end is in the future' do
        news_item.display_start = nil
        news_item.display_end = 1.day.from_now
        expect(news_item.is_current?).to be_truthy
      end

      specify 'returns true when display_end is now' do
        now = Time.current.change(usec: 0)
        
        news_item.display_start = nil
        news_item.display_end = now
        allow(Time).to receive(:current).and_return(now)
        expect(news_item.is_current?).to be_truthy
      end

      specify 'returns false when display_end is in the past' do
        news_item.display_start = nil
        news_item.display_end = 1.day.ago
        expect(news_item.is_current?).to be_falsey
      end
    end

    context 'with both display_start and display_end present' do
      specify 'returns true when current time is between start and end' do
        news_item.display_start = 1.day.ago
        news_item.display_end = 1.day.from_now
        expect(news_item.is_current?).to be_truthy
      end

      specify 'returns true when current time equals display_start' do
        now = Time.current
        news_item.display_start = now
        news_item.display_end = 1.day.from_now
        expect(news_item.is_current?).to be_truthy
      end

      specify 'returns true when current time equals display_end' do
        now = Time.current.change(usec: 0)
        
        news_item.display_start = 1.day.ago
        news_item.display_end = now
        allow(Time).to receive(:current).and_return(now)
        expect(news_item.is_current?).to be_truthy
      end

      specify 'returns false when current time is before display_start' do
        news_item.display_start = 1.day.from_now
        news_item.display_end = 2.days.from_now
        expect(news_item.is_current?).to be_falsey
      end

      specify 'returns false when current time is after display_end' do
        news_item.display_start = 2.days.ago
        news_item.display_end = 1.day.ago
        expect(news_item.is_current?).to be_falsey
      end
    end
  end

end
