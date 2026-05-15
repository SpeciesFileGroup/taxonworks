require 'rails_helper'

# Does Image#unify preserve CitationTopics when both source and target carry a
# Citation to the same source+pages?
#
# AnnotationRerouter handles this explicitly: it reroutes CitationTopics to the
# surviving target Citation before destroying the source Citation.
# Shared::Unify calls citation.update(citation_object: target) which fails the
# uniqueness validation when a duplicate exists — this spec determines whether
# unify handles that case gracefully or loses the CitationTopic.
RSpec.describe 'Image#unify CitationTopic preservation', type: :model do
  let(:source)  { FactoryBot.create(:valid_source_bibtex) }
  let(:topic)   { FactoryBot.create(:valid_topic) }

  let(:target_image)   { FactoryBot.create(:tiny_random_image) }
  let(:sentinel_image) { FactoryBot.create(:tiny_random_image) }

  # Same source+pages on both images — a uniqueness conflict for Citation.
  let!(:target_citation) do
    Citation.create!(
      citation_object: target_image,
      source: source,
      pages: '42',
      project_id: Current.project_id,
      created_by_id: Current.user_id,
      updated_by_id: Current.user_id
    )
  end

  let!(:sentinel_citation) do
    Citation.create!(
      citation_object: sentinel_image,
      source: source,
      pages: '42',
      project_id: Current.project_id,
      created_by_id: Current.user_id,
      updated_by_id: Current.user_id
    )
  end

  # The CitationTopic that must survive the merge.
  let!(:sentinel_citation_topic) do
    CitationTopic.create!(
      citation: sentinel_citation,
      topic: topic,
      project_id: Current.project_id,
      created_by_id: Current.user_id,
      updated_by_id: Current.user_id
    )
  end

  it 'preserves the CitationTopic on the target citation after unify' do
    target_image.unify(sentinel_image, target_project_id: Current.project_id)

    survived = CitationTopic.exists?(sentinel_citation_topic.id)
    expect(survived).to be(true), 'CitationTopic was destroyed — unify does not handle duplicate-citation rerouting'
    expect(sentinel_citation_topic.reload.citation_id).to eq(target_citation.id)
  end

  it 'destroys the sentinel image and its duplicate citation' do
    target_image.unify(sentinel_image, target_project_id: Current.project_id)

    expect(Image.exists?(sentinel_image.id)).to be false
    expect(Citation.exists?(sentinel_citation.id)).to be false
  end
end
