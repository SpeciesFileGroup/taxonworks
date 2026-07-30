require 'rails_helper'

describe 'Shared::Unify', type: :model do

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_otu) }
  let(:source) { FactoryBot.create(:valid_source) }


  # Canary spec: Shared::Unify detects acts_as_list models via
  # respond_to?(:acts_as_list_options). If the acts_as_list gem removes or
  # renames that method the position re-sort in unify will silently stop
  # working. This spec ensures the detection is checking live gem code.
  specify 'acts_as_list exposes acts_as_list_options on list models' do
    expect(Georeference).to respond_to(:acts_as_list_options)
  end

  specify 'unifies Topics' do
    t1 = FactoryBot.create(:valid_topic)
    t2 = FactoryBot.create(:valid_topic)

    t1.unify(t2)
    expect(t2.destroyed?).to be_truthy
  end

  specify 'unifies Topics with identical Content' do
    t1 = FactoryBot.create(:valid_topic)
    t2 = FactoryBot.create(:valid_topic)

    s =  'Exactly the same'

    c1 = FactoryBot.create(:valid_content, topic: t1, text: s)
    c2 = FactoryBot.create(:valid_content, topic: t2, text: s, otu: c1.otu)

    t1.unify(t2)

    expect(t2.destroyed?).to be_truthy
    expect(Content.all.reload.count).to eq(1)
  end

  specify 'unifies Topics with identical Citations' do
    t1 = FactoryBot.create(:valid_topic)
    t2 = FactoryBot.create(:valid_topic)

    c1 = FactoryBot.create(:valid_citation)

    c1.topics << t1
    c1.topics << t2

    t1.unify(t2)

    expect(t2.destroyed?).to be_truthy
    expect(Citation.first.topics.count).to eq(1)
  end

  specify 'unifies Otus with CommonNames' do
    c = FactoryBot.create(:valid_common_name, otu: o1)
    c1 = FactoryBot.create(:valid_common_name, otu: o2)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.common_names.reload.count).to eq(2)
  end

  specify 'unifies Otus in BiologicalAssociations ' do
    o3 = FactoryBot.create(:valid_otu)
    ba1 = FactoryBot.create(:valid_biological_association, biological_association_subject: o2, biological_association_object: o3)

    expect(o1.related_biological_associations.reload.count).to eq(0)

    o1.unify(o3)

    expect(o3.destroyed?).to be_truthy
    expect(o1.related_biological_associations.reload.count).to eq(1)
  end

  specify 'unifies Otus in BiologicalAssociations - merge object associations' do
    [o1,o2] # so that numbers match ids
    o3 = FactoryBot.create(:valid_otu)

    ba1 = FactoryBot.create(:valid_biological_association, biological_association_subject: o2, biological_association_object: o1)
    ba2 = FactoryBot.create(:valid_biological_association, biological_association_subject: o2,
                            biological_association_object: o3, biological_relationship: ba1.biological_relationship)

    s = FactoryBot.create(:valid_source)
    c1  = FactoryBot.create(:valid_citation, citation_object: ba1)
    c2  = FactoryBot.create(:valid_citation, citation_object: ba2)

    o1.unify(o3)

    expect(o3.destroyed?).to be_truthy
    expect(BiologicalAssociation.find_by(id: ba2.id)).to be_falsey
    expect(o1.related_biological_associations.reload.count).to eq(1)
    expect(o1.biological_associations.reload.count).to eq(0)
    expect(ba1.reload.citations.count).to eq(2)
  end

  specify 'unifies Otus in BiologicalAssociations - merge subject associations' do
    [o1,o2] # so that numbers match ids
    o3 = FactoryBot.create(:valid_otu)

    ba1 = FactoryBot.create(:valid_biological_association, biological_association_subject: o1, biological_association_object: o2)
    ba2 = FactoryBot.create(:valid_biological_association, biological_association_subject: o3,
                            biological_association_object: o2, biological_relationship: ba1.biological_relationship)

    s = FactoryBot.create(:valid_source)
    c1  = FactoryBot.create(:valid_citation, citation_object: ba1)
    c2  = FactoryBot.create(:valid_citation, citation_object: ba2)

    u = o1.unify(o3)

    expect(o3.destroyed?).to be_truthy
    expect(BiologicalAssociation.find_by(id: ba2.id)).to be_falsey
    expect(o1.biological_associations.reload.count).to eq(1)
    expect(o1.related_biological_associations.reload.count).to eq(0)
    expect(ba1.reload.citations.count).to eq(2)
  end

  context 'BiologicalAssociation self-referential / dual-target collision shapes' do
    # biological_association_subject and biological_association_object are
    # polymorphic, but nothing prevents them from being set to the same
    # record (real data has at least one such case - an Otu recorded as
    # "feeds on" itself). Like a self-referential TaxonNameRelationship (see
    # the OriginalCombination specs below), a self-referential
    # BiologicalAssociation is returned by both o3's :biological_associations
    # (subject side) and :related_biological_associations (object side)
    # collections, so both its FKs need reassigning together, in one update,
    # for the same reasons documented on Shared::Unify#reassign_foreign_keys.
    specify 'unifies Otus when destroy has a self-referential BiologicalAssociation' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba = BiologicalAssociation.create!(
        biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(ba.reload.biological_association_subject).to eq(o1)
      expect(ba.reload.biological_association_object).to eq(o1)
    end

    # Same shape, but keep already has its own self-referential
    # BiologicalAssociation of the same type - reassigning destroy's collides
    # with it, and the automatic dedup fallback has to resolve it. Neither
    # record ever references the *other* Otu, so - like the k->k pairings
    # below - only destroy's own self-ref is ever independently reassigned;
    # keep's plays the same passive "thing it collides with" role. Verified
    # order-independent (both below land on keep's self-ref surviving), but
    # specced both ways per the same reasoning as the other pairings.
    specify 'unifies Otus when both keep and destroy have their own self-referential BiologicalAssociation - keep self-ref created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_keep = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o1, biological_relationship: rel)
      ba_destroy = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_keep, text: 'note on keep self-ref')
      FactoryBot.create(:valid_note, note_object: ba_destroy, text: 'note on destroy self-ref')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.find_by(id: ba_destroy.id)).to be_nil
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on keep self-ref', 'note on destroy self-ref'])
    end

    specify 'unifies Otus when both keep and destroy have their own self-referential BiologicalAssociation - destroy self-ref created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_destroy = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)
      ba_keep = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o1, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_destroy, text: 'note on destroy self-ref')
      FactoryBot.create(:valid_note, note_object: ba_keep, text: 'note on keep self-ref')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.find_by(id: ba_destroy.id)).to be_nil
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on keep self-ref', 'note on destroy self-ref'])
    end

    # A different collision shape than the one above: instead of keep having
    # its own self-referential record, keep has an ordinary record already
    # pointing *at* destroy (o1 --rel--> o3). Once o3 is absorbed into o1,
    # that record and o3's self-referential one (o3 --rel--> o3) both need to
    # become o1 --rel--> o1 - so they collide with *each other*, not because
    # either one was itself a pre-existing duplicate. Both are genuinely
    # identical once fully migrated, so it should not matter which one
    # survives the dedup, as long as both records' own annotations end up on
    # whichever one does. Specs cover both creation orders since it wasn't
    # obvious from reading the code alone whether creation order could
    # influence which relation merge_relations processes first (it doesn't -
    # that's governed by has_many reflection order, not row creation order -
    # but it's worth pinning down as a regression rather than assuming it).
    specify 'unifies Otus when a pre-existing keep->destroy association collides with destroy''s self-referential one - self-ref created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_self_ref = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)
      ba_existing = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: rel)

      note_self_ref = FactoryBot.create(:valid_note, note_object: ba_self_ref, text: 'note on self-ref')
      note_existing = FactoryBot.create(:valid_note, note_object: ba_existing, text: 'note on pre-existing')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on self-ref', 'note on pre-existing'])
    end

    specify 'unifies Otus when a pre-existing keep->destroy association collides with destroy''s self-referential one - pre-existing created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_existing = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: rel)
      ba_self_ref = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)

      note_existing = FactoryBot.create(:valid_note, note_object: ba_existing, text: 'note on pre-existing')
      note_self_ref = FactoryBot.create(:valid_note, note_object: ba_self_ref, text: 'note on self-ref')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on self-ref', 'note on pre-existing'])
    end

    # Mirror of the pair above: here the pre-existing association points
    # *from* destroy *to* keep (o3 --rel--> o1) rather than the other way
    # around. That puts it in the same has_many collection as destroy's
    # self-referential record (both have subject: o3), unlike the k-->d
    # case where the two records were split across separate has_many
    # collections (processed in different passes). Because both are found
    # and reassigned within the *same* find_each loop here, creation order
    # determines which one is reassigned first (find_each iterates in id
    # order) - and whichever moves first "wins" the k-->k slot, so the
    # other one is the one that collides and gets deduplicated away. Unlike
    # the k-->d case, survivor identity here is genuinely creation-order
    # dependent - both orders are specced to document that, not because
    # either survivor is wrong (both preserve every annotation correctly).
    specify 'unifies Otus when destroy->keep association collides with destroy''s self-referential one - self-ref created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_self_ref = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)
      ba_mirror = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o1, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_self_ref, text: 'note on self-ref')
      FactoryBot.create(:valid_note, note_object: ba_mirror, text: 'note on mirror')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on self-ref', 'note on mirror'])
    end

    specify 'unifies Otus when destroy->keep association collides with destroy''s self-referential one - mirror created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_mirror = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o1, biological_relationship: rel)
      ba_self_ref = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_mirror, text: 'note on mirror')
      FactoryBot.create(:valid_note, note_object: ba_self_ref, text: 'note on self-ref')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on self-ref', 'note on mirror'])
    end

    # Two more pairings, this time colliding with keep's own *pre-existing*
    # association rather than one of destroy's. In both of these, unlike the
    # d-->d cases above, the keep-side record is never itself found among
    # destroy's related_biological_associations/biological_associations (it
    # doesn't reference destroy at all), so it's never independently
    # reassigned - it only ever plays the passive role of "the thing the
    # destroy-side record collides with". That makes survivor identity
    # order-independent here (verified: both orders below land on the
    # keep-side record surviving) - but both orders are specced anyway
    # since that's an artifact of the current implementation, not a
    # documented guarantee, and the processing order could change later.

    specify 'unifies Otus when destroy->keep association collides with keep''s own pre-existing self-referential one - mirror created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_mirror = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o1, biological_relationship: rel)
      ba_keep_self_ref = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o1, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_mirror, text: 'note on mirror')
      FactoryBot.create(:valid_note, note_object: ba_keep_self_ref, text: 'note on keep self-ref')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on mirror', 'note on keep self-ref'])
    end

    specify 'unifies Otus when destroy->keep association collides with keep''s own pre-existing self-referential one - keep self-ref created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_keep_self_ref = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o1, biological_relationship: rel)
      ba_mirror = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o1, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_keep_self_ref, text: 'note on keep self-ref')
      FactoryBot.create(:valid_note, note_object: ba_mirror, text: 'note on mirror')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on mirror', 'note on keep self-ref'])
    end

    specify 'unifies Otus when keep->destroy association collides with keep''s own pre-existing self-referential one - existing created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_existing = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: rel)
      ba_keep_self_ref = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o1, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_existing, text: 'note on existing')
      FactoryBot.create(:valid_note, note_object: ba_keep_self_ref, text: 'note on keep self-ref')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on existing', 'note on keep self-ref'])
    end

    specify 'unifies Otus when keep->destroy association collides with keep''s own pre-existing self-referential one - keep self-ref created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_keep_self_ref = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o1, biological_relationship: rel)
      ba_existing = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_keep_self_ref, text: 'note on keep self-ref')
      FactoryBot.create(:valid_note, note_object: ba_existing, text: 'note on existing')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on existing', 'note on keep self-ref'])
    end

    # Last pairing: neither record is itself self-referential here - d-->k
    # and k-->d are two ordinary, opposite-direction associations between
    # keep and destroy. They're found via different has_many collections
    # (d-->k only via subject-side, k-->d only via object-side), so which
    # one is reassigned first is governed by relation-processing order, not
    # by which one was created first - verified below, both orders land on
    # d-->k surviving (it happens to be reassigned by whichever pass runs
    # first, landing on k-->k cleanly; the other then collides with it and
    # is deduplicated away). Specced in both creation orders anyway, per the
    # same reasoning as above: this is a property of the current
    # implementation, not a guarantee, and worth pinning down as a
    # regression rather than assuming it holds after future changes.
    specify 'unifies Otus when d->k and k->d associations between the same two Otus collide - d->k created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_dk = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o1, biological_relationship: rel)
      ba_kd = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_dk, text: 'note on dk')
      FactoryBot.create(:valid_note, note_object: ba_kd, text: 'note on kd')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on dk', 'note on kd'])
    end

    specify 'unifies Otus when d->k and k->d associations between the same two Otus collide - k->d created first' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba_kd = BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: rel)
      ba_dk = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o1, biological_relationship: rel)

      FactoryBot.create(:valid_note, note_object: ba_kd, text: 'note on kd')
      FactoryBot.create(:valid_note, note_object: ba_dk, text: 'note on dk')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(BiologicalAssociation.count).to eq(1)

      survivor = BiologicalAssociation.first
      expect(survivor.biological_association_subject).to eq(o1)
      expect(survivor.biological_association_object).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on dk', 'note on kd'])
    end
  end

  # only:/except: are documented as scoping unify to "only operate on
  # these relations" - a deliberate partial move, not a full merge (and
  # remove_object is never destroyed in this mode). For a self-referential
  # record, reassign_foreign_keys would otherwise reassign every FK it
  # finds pointing at remove_object regardless of which relation the
  # caller actually asked to move, silently moving more than requested.
  # allowed_associations (see #unify/#reassign_foreign_keys) restricts the
  # "extra" FKs it's willing to grab to whatever only:/except: actually
  # left in scope.
  context 'only:/except: scoping is respected for self-referential records' do
    specify 'only: [:biological_associations] reassigns just the subject side, not the object side too' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)

      result = o1.unify(o3, only: [:biological_associations])

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_falsey
      expect(ba.reload.biological_association_subject).to eq(o1)
      expect(ba.reload.biological_association_object).to eq(o3)
    end

    specify 'only: [:related_biological_associations] reassigns just the object side, not the subject side too' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)

      result = o1.unify(o3, only: [:related_biological_associations])

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_falsey
      expect(ba.reload.biological_association_subject).to eq(o3)
      expect(ba.reload.biological_association_object).to eq(o1)
    end

    specify 'except: [:related_biological_associations] reassigns just the subject side, not the object side too' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)

      result = o1.unify(o3, except: [:related_biological_associations])

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_falsey
      expect(ba.reload.biological_association_subject).to eq(o1)
      expect(ba.reload.biological_association_object).to eq(o3)
    end

    specify 'no only:/except: still reassigns both sides of a self-referential record together' do
      o3 = FactoryBot.create(:valid_otu)
      rel = FactoryBot.create(:valid_biological_relationship)

      ba = BiologicalAssociation.create!(biological_association_subject: o3, biological_association_object: o3, biological_relationship: rel)

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(ba.reload.biological_association_subject).to eq(o1)
      expect(ba.reload.biological_association_object).to eq(o1)
    end
  end

  # OtuRelationship has the same dual-FK shape as BiologicalAssociation -
  # belongs_to :subject_otu and :object_otu, both class_name: 'Otu', and
  # nothing prevents subject_otu_id == object_otu_id (only presence and a
  # [:type, :object_otu_id]-scoped uniqueness on subject_otu_id - no "not
  # identical to self" validation). Otu is directly unifiable in the UI
  # (see app/javascript/vue/tasks/unify/objects/constants/types.js), and
  # both :otu_relationships (subject side) and :related_otu_relationships
  # (object side) pass Shared::Unify's inferred_relations filter, so this
  # is reachable through an ordinary Otu unify, not just a theoretical
  # shape. There were no unify specs for this class before these.
  context 'OtuRelationship self-referential collision shapes' do
    specify 'unifies Otus when destroy has a self-referential OtuRelationship' do
      o3 = FactoryBot.create(:valid_otu)

      rel = OtuRelationship::Disjoint.create!(subject_otu: o3, object_otu: o3)

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(rel.reload.subject_otu).to eq(o1)
      expect(rel.reload.object_otu).to eq(o1)
    end

    specify 'unifies Otus when both keep and destroy have their own self-referential OtuRelationship - keep self-ref created first' do
      o3 = FactoryBot.create(:valid_otu)

      rel_keep = OtuRelationship::Disjoint.create!(subject_otu: o1, object_otu: o1)
      rel_destroy = OtuRelationship::Disjoint.create!(subject_otu: o3, object_otu: o3)

      FactoryBot.create(:valid_note, note_object: rel_keep, text: 'note on keep self-ref')
      FactoryBot.create(:valid_note, note_object: rel_destroy, text: 'note on destroy self-ref')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(OtuRelationship.find_by(id: rel_destroy.id)).to be_nil
      expect(OtuRelationship.count).to eq(1)

      survivor = OtuRelationship.first
      expect(survivor.subject_otu).to eq(o1)
      expect(survivor.object_otu).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on keep self-ref', 'note on destroy self-ref'])
    end

    specify 'unifies Otus when both keep and destroy have their own self-referential OtuRelationship - destroy self-ref created first' do
      o3 = FactoryBot.create(:valid_otu)

      rel_destroy = OtuRelationship::Disjoint.create!(subject_otu: o3, object_otu: o3)
      rel_keep = OtuRelationship::Disjoint.create!(subject_otu: o1, object_otu: o1)

      FactoryBot.create(:valid_note, note_object: rel_destroy, text: 'note on destroy self-ref')
      FactoryBot.create(:valid_note, note_object: rel_keep, text: 'note on keep self-ref')

      result = o1.unify(o3)

      expect(result[:result][:unified]).to be(true)
      expect(o3.destroyed?).to be_truthy
      expect(OtuRelationship.find_by(id: rel_destroy.id)).to be_nil
      expect(OtuRelationship.count).to eq(1)

      survivor = OtuRelationship.first
      expect(survivor.subject_otu).to eq(o1)
      expect(survivor.object_otu).to eq(o1)
      expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on keep self-ref', 'note on destroy self-ref'])
    end
  end

  specify 'unifies Otus in Matrices with overlapping observations' do
    om = ObservationMatrix.create!(name: 'Lune')
    ri1 = ObservationMatrixRowItem::Single.create!(observation_object: o1, observation_matrix: om)
    ri2 = ObservationMatrixRowItem::Single.create!(observation_object: o2, observation_matrix: om)
    r1 = om.reload.observation_matrix_rows.first
    r2 = om.observation_matrix_rows.second

    # See comments below if re-implemented
    # cit2 = Citation.create!(citation_object: r2, source:)
    # tag = Tag.create!(tag_object: r2, keyword: FactoryBot.create(:valid_keyword))

    d = FactoryBot.create(:valid_descriptor)

    d1 = Descriptor::Qualitative.create!(name: 'foo')
    cs = CharacterState.create!(label: 0, name: 'foo', descriptor: d1)
    c1 = FactoryBot.create(:valid_observation_matrix_column, observation_matrix: om, descriptor: d1 )
    # Give both rows the same character state.
    Observation.code_column(c1.id, { character_state: cs })
    obs1 = o1.observations.first
    obs2 = o2.observations.first

    o1.unify(o2)
    expect(ObservationMatrixRowItem.find_by(id: ri2.id)).to be_falsey
    expect(ObservationMatrixRow.find_by(id: r2.id)).to be_falsey
    expect(Observation.find_by(id: obs2.id)).to be_falsey
    expect(Otu.find_by(id: o2.id)).to be_falsey

    expect(o1.reload.observation_matrix_row_items.map(&:id)).to eq([ri1.id])
    expect(o1.observation_matrix_rows.map(&:id)).to eq([r1.id])
    expect(o1.observations.map(&:id)).to eq([obs1.id])

    expect(om.reload.observation_matrix_row_items.map(&:id)).to eq([ri1.id])
    expect(o1.observation_matrix_rows.map(&:id)).to eq([r1.id])

    # See comments on ObservationMatrixRowItem if re-implementing these
    #
    # expect(r1.reload.tags.map(&:id)).to eq([tag.id])
    # # !! Fails, cit2 still points to r2.
    # expect(r1.reload.citations.map(&:id)).to eq([cit2.id])
  end

  specify 'ObservationMatrixRows with refcount > 1 aren\'t destroyed' do
    om = ObservationMatrix.create!(name: 'Lune')
    ri1 = ObservationMatrixRowItem::Single.create!(observation_object: o1, observation_matrix: om)
    s1 = FactoryBot.create(:relationship_species, parent: FactoryBot.create(:root_taxon_name))
    o1.update!(taxon_name: s1)
    ri1d = ObservationMatrixRowItem::Dynamic::TaxonName.create!(observation_object: s1, observation_matrix: om)
    # ri1 and ri1d both refer to r1.
    r1 = om.reload.observation_matrix_rows.first

    ri2 = ObservationMatrixRowItem::Single.create!(observation_object: o2, observation_matrix: om)
    s2 = FactoryBot.create(:relationship_species, name: 'macandcheesei', parent: s1.parent)
    o2.update!(taxon_name: s2)
    ri2d = ObservationMatrixRowItem::Dynamic::TaxonName.create!(observation_object: s2, observation_matrix: om)
    # ri2 and ri2d both refer to r2.
    r2 = om.reload.observation_matrix_rows.second

    r = o1.unify(o2, only: [:observation_matrix_rows])
    expect(ObservationMatrixRow.find_by(id: r2.id)).to be_truthy
  end

  specify 'unifies Repositories' do
    a = FactoryBot.create(:valid_repository)
    b = FactoryBot.create(:valid_repository)

    c = FactoryBot.create(:valid_specimen, repository: b, current_repository: b)
    e = FactoryBot.create(:valid_extract, repository: b)

    a.unify(b, target_project_id: project_id)
    expect(b.destroyed?).to be_truthy
    expect(c.reload.current_repository).to eq(a)
    expect(c.reload.repository).to eq(a)
  end

  specify 'community relations are picked up via #unify_relations' do
    a = FactoryBot.create(:valid_serial)
    expect(a.merge_relations.map(&:name)).to include(:sources)
  end

  specify '#relation_targets_community?' do
    a = FactoryBot.create(:valid_serial)

    r = ApplicationEnumeration.klass_reflections(Serial, :belongs_to).select{|a| a.name == :translated_from_serial}.first
    expect(ApplicationEnumeration.relation_targets_community?(r)).to be_truthy
  end

  specify 'unifies Serials with Sources' do
    a = FactoryBot.create(:valid_serial)
    b = FactoryBot.create(:valid_serial)

    c = FactoryBot.create(:valid_source_bibtex, serial: b)

    e = a.unify(b, target_project_id: project_id)

    expect(b.destroyed?).to be_truthy
    expect(a.sources.reload.size).to eq(1)
  end

  specify 'unifies Serials without Sources' do
    a = FactoryBot.create(:valid_serial)
    b = FactoryBot.create(:valid_serial)

    a.unify(b, target_project_id: project_id)
    expect(b.destroyed?).to be_truthy
  end

  # Regression for a crash fixed alongside the used_inferred_relations
  # linting spec above (see #4971): Serial#unify_relations force-includes
  # :translations regardless of inverse_of: (unify_relations bypasses that
  # check - see Shared::Unify#used_inferred_relations), and the :translations
  # has_many previously had no inverse_of: set. That left
  # reassign_foreign_keys's primary_association nil for every translation
  # record found, and `associations |= [primary_association]` folded that
  # nil into the update hash, raising ActiveModel::UnknownAttributeError
  # instead of moving the record - for any Serial#unify where the removed
  # Serial had a translation, not just a self-referential one.
  specify 'unifies Serials when the removed Serial has a translation pointing at it' do
    a = FactoryBot.create(:valid_serial)
    b = FactoryBot.create(:valid_serial)
    translation = FactoryBot.create(:valid_serial, translated_from_serial: b)

    result = a.unify(b, target_project_id: project_id)

    expect(result[:result][:unified]).to be(true)
    expect(b.destroyed?).to be_truthy
    expect(translation.reload.translated_from_serial).to eq(a)
  end

  # Same underlying gap, but via the dual-targeted shape this branch's other
  # commits are about (see e.g. the BiologicalAssociation/OtuRelationship/
  # TaxonNameRelationship self-referential contexts above): nothing prevents
  # translated_from_serial_id from pointing at the Serial's own row, so the
  # removed Serial can appear in its own :translations collection.
  #
  # Unlike the TaxonNameRelationship/BiologicalAssociation dual-targeted
  # cases, this self-loop does not survive onto the keeper. Those cases
  # involve two independent belongs_to columns on one surviving third-party
  # record, so redirecting both to self leaves that record self-referential.
  # Serial's translated_from_serial/translations pair has only one
  # belongs_to; its self-loop can only be the removed Serial's own FK
  # pointing at its own row, and that row is destroyed right after the
  # redirect - there's no surviving record left to carry it forward. This
  # is consistent with #unify's general rule that a removed object's own
  # belongs_to/attribute values are never copied onto the keeper (see
  # module header) - confirmed true here even though the target happens to
  # be the removed object itself.
  specify 'unifies Serials when the removed Serial is its own translated_from_serial' do
    a = FactoryBot.create(:valid_serial)
    b = FactoryBot.create(:valid_serial)
    b.update!(translated_from_serial: b)

    result = a.unify(b, target_project_id: project_id)

    expect(result[:result][:unified]).to be(true)
    expect(b.destroyed?).to be_truthy
    expect(a.reload.translated_from_serial).to be_nil
  end

  specify 'deduplicates Depictions referencing the same image' do
    i = FactoryBot.create(:valid_image)

    a = FactoryBot.create(:valid_depiction, depiction_object: o1, image: i)
    b = FactoryBot.create(:valid_depiction, depiction_object: o2, image: i)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.depictions.size).to eq(1)
  end

  specify 'deduplicates double non-unique DataAttributes' do
    a = FactoryBot.create(:valid_data_attribute_import_attribute, attribute_subject: o1, value: 123)
    c = FactoryBot.create(:valid_data_attribute_import_attribute, attribute_subject: o2, value: 123, import_predicate:  a.import_predicate)

    b = FactoryBot.create(:valid_data_attribute_import_attribute, attribute_subject: o1, value: 456)
    d = FactoryBot.create(:valid_data_attribute_import_attribute, attribute_subject: o2, value: 456, import_predicate: b.import_predicate)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.data_attributes.reload.size).to eq(2)
  end

  specify 'deduplicates double non-unique DataAttributes' do
    a = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o1, value: 123)
    b = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o2, value: 123, predicate: a.predicate)

    c = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o1, value: 123)
    d = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o2, value: 123, predicate: c.predicate)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.data_attributes.reload.size).to eq(2)
  end

  specify 'moves Confidences' do
    a = FactoryBot.create(:valid_specimen)
    b = FactoryBot.create(:valid_specimen)

    c = FactoryBot.create(
      :valid_confidence, confidence_object: b
    )

    a.unify(b)

    expect(b.destroyed?).to be_truthy
    expect(a.confidences.size).to eq(1)
  end

  specify 'returns failure when too many relations' do
    a = FactoryBot.create(:valid_specimen)
    b = FactoryBot.create(:valid_specimen)

    c = FactoryBot.create(
      :valid_confidence, confidence_object: b
    )
    d = FactoryBot.create(
      :valid_confidence, confidence_object: b
    )

    r = a.unify(b, cutoff: 1)
    expect(r[:result][:unified]).to be_falsey
    expect(r[:result][:message]).to include('cutoff')
  end

   specify 'does not unify non-community objects from different projects' do
    other_project = FactoryBot.create(:valid_project)
    b = FactoryBot.create(:valid_otu, project: other_project)

    r = o1.unify(b)

    expect(r[:result][:unified]).to be(false)
    expect(r[:result][:message]).to include('different project')
    expect(b.destroyed?).to be_falsey
  end

  specify 'handles BiocurationClassifications when identical' do
    a = FactoryBot.create(:valid_specimen)
    b = FactoryBot.create(:valid_specimen)

    c = FactoryBot.create(
      :valid_biocuration_classification, biocuration_classification_object: a
    )

    d = FactoryBot.create(
      :valid_biocuration_classification,
      biocuration_classification_object: b,
      biocuration_class: c.biocuration_class)

    e =  a.unify(b)

    expect(b.destroyed?).to be_truthy
    expect(BiocurationClassification.all.reload.size).to eq(1)
    expect(e[:details]['Biocuration classifications'][:deduplicated]).to eq(1)
  end

  specify 'sums BiocurationClassifications when classes differ' do
    a = FactoryBot.create(:valid_specimen)
    b = FactoryBot.create(:valid_specimen)

    c1 = FactoryBot.create(
      :valid_biocuration_classification, biocuration_classification_object: a
    )

    c2 = FactoryBot.create(
      :valid_biocuration_classification, biocuration_classification_object: b
    )

    a.unify(b)

    expect(b.destroyed?).to be_truthy

    a_classifications = a.biocuration_classifications.reload
    expect(a_classifications.pluck(:biocuration_class_id)).to contain_exactly(
      c1.biocuration_class_id, c2.biocuration_class_id
    )
  end

  specify 'if only used then use as "move" not unify' do
    c1 = Citation.create(citation_object: o1, source:, pages: 123)
    c2 = Citation.create(citation_object: o1, source:, pages: 456)

    o1.unify(o2, only: [:citations])

    expect(o2.reload.destroyed?).to be_falsey
    expect(o1.citations.reload.count).to eq(2)
    expect(o1.citations.pluck(:pages)).to contain_exactly('123', '456')
  end

  specify 'merges non-unique DataAttributes' do
    a = FactoryBot.create(:valid_data_attribute, attribute_subject: o1, value: 123)
    b = FactoryBot.create(:valid_data_attribute, attribute_subject: o2, value: 456)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.data_attributes.reload.size).to eq(2)
    expect(o1.data_attributes.pluck(:value)).to contain_exactly('123', '456')
  end

  specify 'deduplicates DataAttributes' do
    predicate = FactoryBot.create(:valid_predicate)
    a = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o1, value: 123, predicate: )
    b = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o2, value: 123, predicate: )

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.data_attributes.reload.size).to eq(1)
    expect(o1.data_attributes.last.value).to eq('123')
  end

  specify 'persists citations on deduplicate DataAttributes' do
    predicate = FactoryBot.create(:valid_predicate)
    a = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o1, value: 123, predicate: )
    b = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o2, value: 123, predicate: )

    FactoryBot.create(:valid_citation, citation_object: b)

    o1.unify(o2)
    expect(o1.data_attributes.first.citations.size).to eq(1)
  end

  # Only makes sense when observations need to be moved
  specify 'unifies TypeMaterial' do
    a = FactoryBot.create(:valid_type_material)
    b = FactoryBot.create(:valid_type_material)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Only makes sense when observations need to be moved
  specify 'unifies TaxonDetermination' do
    a = FactoryBot.create(:valid_taxon_name)
    b = FactoryBot.create(:valid_taxon_name)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Only makes sense when observations need to be moved
  specify 'unifies TaxonDetermination' do
    a = FactoryBot.create(:valid_taxon_determination)
    b = FactoryBot.create(:valid_taxon_determination)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Source with target_project_id (when Source is "naked")' do
    a = FactoryBot.create(:valid_source)
    b = FactoryBot.create(:valid_source)

    a.unify(b, target_project_id: o1.project_id)
    expect(b.destroyed?).to be_truthy
  end

  specify 'does not unify Source without target_project_id' do
    a = FactoryBot.create(:valid_source)
    b = FactoryBot.create(:valid_source)

    a.unify(b)
    expect(b.destroyed?).to be_falsey
  end

  specify 'does not unify Source when cross-project use present' do
    project = FactoryBot.create(:valid_project)
    o3 = FactoryBot.create(:valid_otu, project:)

    a = FactoryBot.create(:valid_source)
    b = FactoryBot.create(:valid_source)

    c = FactoryBot.create(:valid_citation, project:, source: b, citation_object: o3)

    a.unify(b)
    expect(b.destroyed?).to be_falsey
  end

  specify 'does unify Source if specific to project' do
    a = FactoryBot.create(:valid_source)
    b = FactoryBot.create(:valid_source)

    c = FactoryBot.create(:valid_citation, source: a, citation_object: o1)
    d = FactoryBot.create(:valid_citation, source: b, citation_object: o2)

    a.unify(b, target_project_id: project_id )

    expect(b.destroyed?).to be_truthy
    expect(d.reload.source).to eq(a)
  end

  # !! Requires more thorough testing with items etc.
  specify 'unifies ObservationMatrix' do
    a = FactoryBot.create(:valid_observation_matrix)
    b = FactoryBot.create(:valid_observation_matrix)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Only useful to annotations from one to another
  specify 'unifies Observation' do
    a = FactoryBot.create(:valid_observation)
    b = FactoryBot.create(:valid_observation)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Loan' do
    a = FactoryBot.create(:valid_loan)
    b = FactoryBot.create(:valid_loan)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Useful in replacing versions of self if necessary,
  # but image de-duplication already happens
  specify 'unifies Image' do
    a = FactoryBot.create(:valid_image)

    b = Image.create!(
      image_file: Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_sized_png(
        file_name: 'foo.png',
      ), 'image/png'),
    )

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Image — reroutes Depictions to the surviving image' do
    a = FactoryBot.create(:valid_image)
    b = Image.create!(
      image_file: Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_sized_png(
        file_name: 'foo.png',
      ), 'image/png'),
    )
    depiction = FactoryBot.create(:valid_depiction, image: b, depiction_object: o1)

    a.unify(b)

    expect(b.destroyed?).to be_truthy
    expect(depiction.reload.image).to eq(a)
  end

  specify 'unifies Document' do
    a = FactoryBot.create(:valid_document)
    b = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        Spec::Support::Utilities::Files.generate_pdf(file_name: 'doc_b.pdf', pages: 2),
        'application/pdf'
      )
    )

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Document — reroutes Documentation to the surviving document' do
    a = FactoryBot.create(:valid_document)
    b = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        Spec::Support::Utilities::Files.generate_pdf(file_name: 'doc_b.pdf', pages: 2),
        'application/pdf'
      )
    )
    documentation = Documentation.create!(document: b, documentation_object: o1)

    a.unify(b)

    expect(b.destroyed?).to be_truthy
    expect(documentation.reload.document).to eq(a)
  end

  specify 'unifies Georeference' do
    a = FactoryBot.create(:valid_georeference)
    b = FactoryBot.create(:valid_georeference)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Tries to move the required TD, which isn't allowed
  #  - perhaps dup and not add error then destroy @ end?
  specify 'unifies FieldOccurrence' do
    a = FactoryBot.create(:valid_field_occurrence)
    b = FactoryBot.create(:valid_field_occurrence)

    r = a.unify(b)
    expect(b.destroyed?).to be_truthy
    expect(a.taxon_determinations.reload.size).to eq(2)
  end

  # Tries to move the required TD, which isn't allowed
  #  - perhaps dup and not add error then destroy @ end?
  specify 'unifies FieldOccurrence with CEs linked to COs' do
    a = FactoryBot.create(:valid_field_occurrence)
    ce = a.collecting_event
    b = FactoryBot.create(:valid_field_occurrence, collecting_event: ce)

    s = FactoryBot.create(:valid_specimen, collecting_event: ce)

    r = a.unify(b)
    expect(b.destroyed?).to be_truthy
    expect(a.taxon_determinations.reload.size).to eq(2)
  end



  specify 'unifies Extract' do
    a = FactoryBot.create(:valid_extract)
    b = FactoryBot.create(:valid_extract)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifying Descriptors moves observation_matrix_column_items to the surviving descriptor' do
    om = FactoryBot.create(:valid_observation_matrix)
    d1 = FactoryBot.create(:valid_descriptor)
    d2 = FactoryBot.create(:valid_descriptor)
    col_item = ObservationMatrixColumnItem::Single::Descriptor.create!(observation_matrix: om, descriptor: d2)

    d1.unify(d2)

    expect(d2.destroyed?).to be_truthy
    expect(ObservationMatrixColumnItem.where(id: col_item.id).exists?).to be(true)
    expect(col_item.reload.descriptor_id).to eq(d1.id)
  end

  specify 'unifying Keywords moves observation_matrix_column_items to the surviving keyword' do
    om = FactoryBot.create(:valid_observation_matrix)
    k1 = FactoryBot.create(:valid_keyword)
    k2 = FactoryBot.create(:valid_keyword)
    col_item = ObservationMatrixColumnItem::Dynamic::Tag.create!(observation_matrix: om, controlled_vocabulary_term: k2)

    k1.unify(k2)

    expect(k2.destroyed?).to be_truthy
    expect(ObservationMatrixColumnItem.where(id: col_item.id).exists?).to be(true)
    expect(col_item.reload.controlled_vocabulary_term_id).to eq(k1.id)
  end

  specify 'unifying Keywords moves observation_matrix_row_items to the surviving keyword' do
    om = FactoryBot.create(:valid_observation_matrix)
    k1 = FactoryBot.create(:valid_keyword)
    k2 = FactoryBot.create(:valid_keyword)
    row_item = ObservationMatrixRowItem::Dynamic::Tag.create!(observation_matrix: om, observation_object: k2)

    k1.unify(k2)

    expect(k2.destroyed?).to be_truthy
    expect(ObservationMatrixRowItem.where(id: row_item.id).exists?).to be(true)
    expect(row_item.reload.observation_object_id).to eq(k1.id)
  end

  # !! Can unify *across* Descriptors as well
  specify 'unifies CharacterState' do
    a = FactoryBot.create(:valid_character_state)
    b = FactoryBot.create(:valid_character_state)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Descriptor' do
    a = FactoryBot.create(:valid_descriptor)
    b = FactoryBot.create(:valid_descriptor)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'does not unify different kinds of ControlledVocabularyTerm' do
    a = FactoryBot.create(:valid_predicate)
    b = FactoryBot.create(:valid_keyword)

    a.unify(b)
    expect(b.destroyed?).to be_falsey
  end

  specify 'unifies ControlledVocabularyTerms' do
    a = FactoryBot.create(:valid_keyword)
    b = FactoryBot.create(:valid_keyword)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # No point in unify here, is there?
  xspecify 'unifies Depiction' do
  end

  # Not exposed in UI
  # !? What does this mean, merge text?
  xspecify 'unifies Content' do
    a = FactoryBot.create(:valid_content)
    b = FactoryBot.create(:valid_content)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Container' do
    a = FactoryBot.create(:valid_container)
    b = FactoryBot.create(:valid_container)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies CollectionObject' do
    a = FactoryBot.create(:valid_collection_object)
    b = FactoryBot.create(:valid_collection_object)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies CollectingEvent' do
    ce1 = FactoryBot.create(:valid_collecting_event)
    ce2 = FactoryBot.create(:valid_collecting_event)

    ce1.unify(ce2)
    expect(ce2.destroyed?).to be_truthy
  end

  specify 'unifies BiologicalAssociationsGraph' do
    bag1 = FactoryBot.create(:valid_biological_associations_graph)
    bag2 = FactoryBot.create(:valid_biological_associations_graph)

    bag1.unify(bag2)
    expect(bag2.destroyed?).to be_truthy
  end

  specify 'unifies BiologicalAssocations' do
    o3 = FactoryBot.create(:valid_otu)

    ba0 = FactoryBot.create(:valid_biological_association, biological_association_subject: o1, biological_association_object: o3)
    ba1 = FactoryBot.create(:valid_biological_association, biological_association_subject: o2, biological_association_object: o3)

    b = ba0.unify(ba1)

    expect(ba1.destroyed?).to be_truthy
    expect(BiologicalAssociation.all.reload.count).to eq(1)
  end

  specify 'unify preserves once-removed citations differing only by page / AssertedDstribution test ' do
    # Create a GA and a non-target record
    ad0 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1, source:)
    ad1 = AssertedDistribution.create!(
      asserted_distribution_object: o2,
      source:,
      asserted_distribution_shape: ad0.asserted_distribution_shape
    )

    ad0.origin_citation.update!(pages: 123)
    ad1.origin_citation.update!(pages: 456)

    b = ad0.unify(ad1)

    expect(ad1.destroyed?).to be_truthy

    expect(ad0.citations.reload.size).to eq(2)
    expect(ad0.citations.pluck(:pages)).to contain_exactly('123', '456')
  end

  specify 'unify preserves citations differing by pages' do
    c1 = Citation.create(citation_object: o1, source:, pages: 123)
    c2 = Citation.create(citation_object: o1, source:, pages: 456)

    o1.unify(o2)

    expect(o1.citations.reload.count).to eq(2)
    expect(o1.citations.pluck(:pages)).to contain_exactly('123', '456')
  end

  specify '#unify' do
    expect(o1.unify(o2)).to be_truthy
  end

  specify 'unify destroys by default' do
    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
  end

  specify 'unify does not destroy with preview' do
    o1.unify(o2, preview: true)
    expect(o2.destroyed?).to be_falsey
  end

  specify 'unify moves annotations' do
    n = FactoryBot.create(:valid_note, note_object: o2)

    o1.unify(o2)
    expect(o1.notes.reload.count).to eq(1)
  end

  specify 'unify moves has_many' do
    s = FactoryBot.create(:valid_specimen)
    n = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s, otu: o2)

    o1.unify(o2)
    expect(o1.taxon_determinations.reload.count).to eq(1)
  end

  specify 'unify handles duplicate tags when both objects share the same keyword' do
    k = FactoryBot.create(:valid_keyword)
    Tag.create!(tag_object: o1, keyword: k)
    Tag.create!(tag_object: o2, keyword: k)

    result = o1.unify(o2)

    expect(result[:result][:unified]).to be_truthy
    expect(o2.destroyed?).to be_truthy
    expect(o1.tags.reload.count).to eq(1)
    expect(o1.tags.first.keyword).to eq(k)
  end

  specify '#identical' do
    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape)

    ad2.asserted_distribution_object = o1

    expect(ad2.identical.first).to eq(ad1)
  end

  #
  # Model/Context specific handling
  #

  specify 'unify handles Auto UUIDs' do
    o1.unify(o2)

    expect(o1.identifiers.reload.size).to eq(2)
  end

  # See also TNR
  #  When we loop through as has_many
  #     and we are updating a record A
  #      and it fails with an error * on the class being unified *
  #         then we find the identical duplicate record B
  #             and we unify A -> B
  #               and we delete A
  #
  specify 'unify one degree of seperation' do
    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape) # differ only by OTU

    n = FactoryBot.create(:valid_note, note_object: ad1)

    b = o1.unify(o2)

    expect(AssertedDistribution.find_by(id: ad2.id)).to eq(nil)
    expect(n.reload.note_object).to eq(ad1)
    expect(o2.destroyed?).to be_truthy
  end

  specify 'unify one degree of seperation - records deduplication result in preview' do
    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape) # differ only by OTU

    n = FactoryBot.create(:valid_note, note_object: ad1)

    b = o1.unify(o2, preview: true)

    expect( b[:details]['Asserted distributions'].dig(:deduplicated)).to eq(1)
  end

  specify 'unify one degree of seperation - records deduplication result' do
    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape) # differ only by OTU

    n = FactoryBot.create(:valid_note, note_object: ad1)

    b = o1.unify(o2)

    expect( b[:details]['Asserted distributions'].dig(:deduplicated)).to eq(1)
  end

  context 'when the nested unify inside deduplicate_update_target fails' do
    let(:om) { ObservationMatrix.create!(name: 'BugTest') }
    let!(:row1) { FactoryBot.create(:valid_observation_matrix_row, observation_object: o1, observation_matrix: om) }
    let!(:row2) { FactoryBot.create(:valid_observation_matrix_row, observation_object: o2, observation_matrix: om) }

    before do
      # At time of writing there are no second-level model associations that
      # could return {unified: false} from the secondary unify call, but there's
      # no reason that might not happen in the future.
      allow_any_instance_of(ObservationMatrixRow).to receive(:unify)
        .and_return({result: {unified: false, message: 'nested failure'}, details: {}})
    end

    specify 'unify returns unified: false' do
      result = o1.unify(o2)
      expect(result[:result][:unified]).to be(false)
    end

    specify 'o2 is not destroyed' do
      o1.unify(o2)
      expect(Otu.where(id: o2.id).exists?).to be(true)
    end

    specify 'details report unmerged count of 1 (not deduplicated)' do
      result = o1.unify(o2)
      expect(result[:details]['Observation matrix rows'][:unmerged]).to eq(1)
    end
  end

  # Generalize to all annotations.
  #
  # If unify would create two identical citations anywhere
  # during the process, then destroy one of them.
  #
  #   then destroy one of them
  #
  #
  #
  specify 'would-be duplicate citations do not halt unify' do
    s = FactoryBot.create(:valid_source)

    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1, source: s)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape, source: s)

    expect(Citation.all.size).to eq(2)

    b = o1.unify(o2)

    expect(o2.destroyed?).to be_truthy
    expect(Citation.all.size).to eq(1)
    expect(b[:details]['Asserted distributions'][:deduplicated]).to eq(1)
  end

  # log_unify_result resets a duplicate Citation's `is_original` to false
  # before attempting deduplication (to clear the separate is_original
  # uniqueness conflict). Citation::IGNORE_IDENTICAL excludes is_original
  # from #identical's comparison, so that reset doesn't stop the duplicate
  # from still matching the surviving Citation - #identical finds it, and
  # deduplicate_update_target moves its annotations (e.g. this Note) onto
  # the survivor before destroying it, rather than losing them to ad2's own
  # destroy cascade.
  specify 'would-be duplicate citations do not halt unify - preserves Notes on the removed duplicate' do
    s = FactoryBot.create(:valid_source)

    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1, source: s)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape, source: s)

    n = FactoryBot.create(:valid_note, note_object: ad2.citations.first)

    o1.unify(o2)

    expect(Citation.all.size).to eq(1)
    expect(n.reload.note_object).to eq(Citation.first)
  end

  specify 'would-be duplicate citations do not halt unify - preserves Tags on the removed duplicate' do
    s = FactoryBot.create(:valid_source)
    k = FactoryBot.create(:valid_keyword)

    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1, source: s)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape, source: s)

    t = Tag.create!(tag_object: ad2.citations.first, keyword: k)

    o1.unify(o2)

    expect(Citation.all.size).to eq(1)
    expect(t.reload.tag_object).to eq(Citation.first)
  end

  specify 'would-be duplicate citations do not halt unify - records deduplication result' do
    s = FactoryBot.create(:valid_source)

    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1, source: s)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape, source: s)

    b = ad1.unify(ad2)

    expect(ad2.destroyed?).to be_truthy
    expect(Citation.all.size).to eq(1)
    expect(b[:details]['Citations'][:deduplicated]).to eq(1)
  end

  # Citation#prevent_if_required consults UnifyDestroyContext.objects_in_destroy
  # (populated by Shared::Unify#unify, keyed by {id:, type:} rather than
  # object reference, since citation_object may be a different in-memory
  # instance than whatever unify holds - see UnifyDestroyContext) to decide
  # whether citation_object is already slated for destruction regardless.
  # citation1 and citation2 here are on two entirely unrelated
  # AssertedDistributions - neither ad1 nor ad2 is being unified with the
  # other, so ad2 is never registered as being destroyed. Calling
  # Citation#unify directly must not destroy citation2 and leave ad2 -
  # untouched, still fully alive - with zero citations despite requiring
  # one.
  specify 'unify does not destroy a required citation for an unrelated, untouched citation_object' do
    s = FactoryBot.create(:valid_source)
    ad1 = FactoryBot.create(:valid_asserted_distribution, source: s)
    ad2 = FactoryBot.create(:valid_asserted_distribution, source: s)

    citation1 = ad1.citations.first
    citation2 = ad2.citations.first

    citation1.unify(citation2)

    expect(citation2.destroyed?).to be_falsey
    expect(ad2.reload.citations.count).to eq(1)
  end

  # Same guard, same UnifyDestroyContext mechanism, on the other model that
  # has the identical "must have at least one" before_destroy shape
  # (Shared::TaxonDeterminationRequired mirrors Shared::CitationRequired, and
  # FieldOccurrence#requires_taxon_determination? is unconditionally true,
  # just like Citation's requirement).
  specify 'unify does not destroy a required taxon determination for an unrelated, untouched taxon_determination_object' do
    fo1 = FactoryBot.create(:valid_field_occurrence)
    fo2 = FactoryBot.create(:valid_field_occurrence)

    td1 = fo1.taxon_determinations.first
    td2 = fo2.taxon_determinations.first

    td1.unify(td2)

    expect(td2.destroyed?).to be_falsey
    expect(fo2.reload.taxon_determinations.count).to eq(1)
  end

  # TaxonDetermination's only uniqueness validator is on :position, scoped by
  # (taxon_determination_object_id/type, project_id). Unlike Citation's
  # source/pages uniqueness, this validator can never survive
  # log_unify_result's generic "reset position to nil and retry" fixup:
  # acts_as_list's add_new_at: :top callback (before_update :check_scope)
  # treats a nilled position as "insert at top" and always finds room by
  # shifting every other record in the scope down, so the retry always
  # succeeds. That means object.errors is always empty by the time
  # log_unify_result would otherwise reach for deduplicate_update_target -
  # dedup is never actually exercised here, regardless of the guard fix
  # above. The "duplicate" determination is just merged in as an ordinary
  # (undeduped) second record, not destroyed and not blocked.
  specify 'unify does not attempt (and so does not need to guard) dedup of a duplicate TaxonDetermination on a FieldOccurrence' do
    fo1 = FactoryBot.create(:valid_field_occurrence)
    fo2 = FactoryBot.create(:valid_field_occurrence)
    otu = FactoryBot.create(:valid_otu)

    fo1.taxon_determinations.first.update!(otu:)
    fo2.taxon_determinations.first.update!(otu:)

    result = fo1.unify(fo2)

    expect(result[:result][:unified]).to be(true)
    expect(result[:details]['Taxon determinations'][:merged]).to eq(1)
    expect(result[:details]['Taxon determinations'][:deduplicated]).to eq(0)
    expect(fo2.destroyed?).to be_truthy
    expect(fo1.taxon_determinations.reload.count).to eq(2)
  end

  specify 'unifies TaxonNames when both have an identical OriginalCombination relationship (same subject and type)' do
    genus = FactoryBot.create(:relationship_genus)
    keep = FactoryBot.create(:relationship_species)
    destroy = FactoryBot.create(:relationship_species)

    r_keep = FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
      subject_taxon_name: genus, object_taxon_name: keep)
    r_destroy = FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
      subject_taxon_name: genus, object_taxon_name: destroy)

    keep.unify(destroy)

    expect(destroy.destroyed?).to be_truthy
    expect(TaxonNameRelationship.find_by(id: r_destroy.id)).to be_nil
    expect(TaxonNameRelationship.find_by(id: r_keep.id)).not_to be_nil
  end

  specify 'unifies TaxonNames with duplicate OriginalCombination - counts as deduplicated in result' do
    genus = FactoryBot.create(:relationship_genus)
    keep = FactoryBot.create(:relationship_species)
    destroy = FactoryBot.create(:relationship_species)

    FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
      subject_taxon_name: genus, object_taxon_name: keep)
    FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
      subject_taxon_name: genus, object_taxon_name: destroy)

    result = keep.unify(destroy)

    expect(result[:details]['Related taxon name relationships'][:deduplicated]).to eq(1)
  end

  # A populated species-rank Protonym typically carries its own
  # self-referential OriginalCombination::OriginalSpecies relationship
  # (subject_taxon_name == object_taxon_name == itself), recording "the
  # original species epithet is unchanged". validate_subject_and_object_are_
  # not_identical explicitly permits self-reference only for
  # OriginalCombination types.
  #
  # Unlike the duplicate-via-a-third-party cases above (where the
  # conflicting record's other FK points at some uninvolved name and so
  # only one merge_relations pass ever touches it), a self-referential
  # record has *both* its subject and object pointing at destroy, so it's
  # picked up by both the subject-side and object-side passes. Reassigning
  # both of its FKs together (Shared::Unify#reassign_foreign_keys) - rather
  # than one at a time across the two passes - is what makes this
  # resolvable: the fully-migrated shape it lands on (or fails to, if it
  # collides) matches what #identical needs to find keep's own analogous
  # record. See #4971. Both creation orders specced: neither record ever
  # references the other TaxonName directly, so keep's self-ref is never
  # itself reassigned - it only ever plays the passive "thing destroy's
  # collides with" role, making the survivor order-independent (verified:
  # both orders below land on keep's self-ref surviving) - but pinned down
  # in both orders anyway since that's a property of the current
  # implementation, not a documented guarantee.
  specify 'unifies two TaxonNames that each have their own self-referential OriginalSpecies relationship - keep self-ref created first' do
    keep = FactoryBot.create(:relationship_species)
    destroy = FactoryBot.create(:relationship_species)

    r_keep = TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: keep, object_taxon_name: keep)
    r_destroy = TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: destroy, object_taxon_name: destroy)

    FactoryBot.create(:valid_note, note_object: r_keep, text: 'note on keep self-ref')
    FactoryBot.create(:valid_note, note_object: r_destroy, text: 'note on destroy self-ref')

    result = keep.unify(destroy)

    expect(result[:result][:unified]).to be(true)
    expect(destroy.destroyed?).to be_truthy
    expect(TaxonNameRelationship.count).to eq(1)

    survivor = TaxonNameRelationship.first
    expect(survivor.subject_taxon_name).to eq(keep)
    expect(survivor.object_taxon_name).to eq(keep)
    expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on keep self-ref', 'note on destroy self-ref'])
  end

  specify 'unifies two TaxonNames that each have their own self-referential OriginalSpecies relationship - destroy self-ref created first' do
    keep = FactoryBot.create(:relationship_species)
    destroy = FactoryBot.create(:relationship_species)

    r_destroy = TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: destroy, object_taxon_name: destroy)
    r_keep = TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: keep, object_taxon_name: keep)

    FactoryBot.create(:valid_note, note_object: r_destroy, text: 'note on destroy self-ref')
    FactoryBot.create(:valid_note, note_object: r_keep, text: 'note on keep self-ref')

    result = keep.unify(destroy)

    expect(result[:result][:unified]).to be(true)
    expect(destroy.destroyed?).to be_truthy
    expect(TaxonNameRelationship.count).to eq(1)

    survivor = TaxonNameRelationship.first
    expect(survivor.subject_taxon_name).to eq(keep)
    expect(survivor.object_taxon_name).to eq(keep)
    expect(Note.where(note_object: survivor).pluck(:text)).to match_array(['note on keep self-ref', 'note on destroy self-ref'])
  end

  # OriginalCombination's uniqueness validator is narrower than
  # #identical's comparison: validates_uniqueness_of on OriginalSpecies is
  # scoped to [:type] on object_taxon_name_id alone (see
  # taxon_name_relationship/original_combination/original_species.rb's
  # parent class), ignoring subject_taxon_name_id entirely - but
  # #identical (Shared::IsData) compares the full attribute set, subject
  # included. So a record can be rejected as "not unique" by the validator
  # while still failing to match anything via #identical, if the existing
  # colliding record has a *different* subject. That's the case here:
  # destroy's self-ref OriginalSpecies (subject: destroy, object: destroy)
  # collides on the object+type scope with keep's *pre-existing*
  # OriginalSpecies from a different subject (third, object: keep) once
  # reassigned - but once fully migrated it would be (subject: keep,
  # object: keep), which does not match third's (subject: third, object:
  # keep). These represent genuinely different, conflicting claims about
  # keep's original species (unlike a real duplicate), so dedup correctly
  # can't/shouldn't resolve it - the whole unify must roll back rather
  # than silently keep one arbitrary side.
  specify 'unify reports unmerged (not merged, not deduplicated) when a self-referential OriginalSpecies collides on the validator''s narrower scope but is not a match for #identical' do
    keep = FactoryBot.create(:relationship_species)
    destroy = FactoryBot.create(:relationship_species)
    third = FactoryBot.create(:relationship_species)

    TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: third, object_taxon_name: keep)
    TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(subject_taxon_name: destroy, object_taxon_name: destroy)

    result = keep.unify(destroy)

    expect(result[:result][:unified]).to be(false)
    expect(destroy.reload.destroyed?).to be_falsey
    expect(result[:details]['Related taxon name relationships'][:merged]).to eq(0)
    expect(result[:details]['Related taxon name relationships'][:deduplicated]).to eq(0)
    expect(result[:details]['Related taxon name relationships'][:unmerged]).to eq(1)
    expect(TaxonNameRelationship.count).to eq(2)
  end

  specify 'unifies TaxonNames when both are subjects of the same TaxonNameRelationship type to the same object' do
    keep = FactoryBot.create(:relationship_species)
    destroy = FactoryBot.create(:relationship_species)
    valid_name = FactoryBot.create(:relationship_species)

    r_keep = FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
      subject_taxon_name: keep, object_taxon_name: valid_name)
    r_destroy = FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
      subject_taxon_name: destroy, object_taxon_name: valid_name)

    keep.unify(destroy)

    expect(destroy.destroyed?).to be_truthy
    expect(TaxonNameRelationship.find_by(id: r_destroy.id)).to be_nil
    expect(TaxonNameRelationship.find_by(id: r_keep.id)).not_to be_nil
  end

  # A relation move can fail validation for reasons that have nothing to do
  # with duplication. Here, unifying moves a SourceClassifiedAs relationship
  # onto an ICN (botanical) name, but its subject is an ICZN (zoological)
  # name - TaxonNameRelationship#validate_subject_and_object_share_code, a
  # plain `validate` callback, not a uniqueness check, correctly rejects
  # relating names from different nomenclatural codes. That must be reported
  # unmerged (and destroy/its relationship must survive), not treated as a
  # duplicate-worthy failure or silently merged.
  specify 'unifying does not report merged for a relation whose move fails a non-uniqueness validation' do
    destroy = FactoryBot.create(:relationship_family) # ICZN
    subject_name = FactoryBot.create(:relationship_genus, parent: destroy) # ICZN, shares code with destroy
    keep = FactoryBot.create(:icn_family) # different nomenclatural code

    r = TaxonNameRelationship::SourceClassifiedAs.create!(subject_taxon_name: subject_name, object_taxon_name: destroy)

    result = keep.unify(destroy)

    expect(result[:result][:unified]).to be(false)
    expect(result[:details]['Related taxon name relationships'][:unmerged]).to eq(1)
    expect(result[:details]['Related taxon name relationships'][:merged]).to eq(0)
    expect(destroy.reload.destroyed?).to be_falsey
    expect(r.reload.object_taxon_name_id).to eq(destroy.id)
  end

  # Aus bus (destroy) and Cus dus (keep) both exist, and some other name is
  # a Synonym *of* Aus bus (i.e. Aus bus is the *object* of that TNR, and
  # Aus bus's id is cached on the synonym's cached_valid_taxon_name_id).
  # keep.unify(destroy) moves destroy's taxon_name_relationships (including
  # the synonym TNR) over to keep, then destroys Aus bus. The synonym's
  # cached_valid_taxon_name_id must follow that move and end up pointing at
  # keep, not the now-destroyed Aus bus - otherwise anything that resolves
  # #valid_taxon_name off the synonym would blow up trying to load a name
  # that no longer exists.
  specify 'unifies TaxonNames - synonym cached_valid_taxon_name_id follows the object of a Synonym relationship' do
    keep = FactoryBot.create(:relationship_species)    # Cus dus
    destroy = FactoryBot.create(:relationship_species) # Aus bus
    synonym = FactoryBot.create(:relationship_species)  # something else, synonym of Aus bus

    FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
      subject_taxon_name: synonym, object_taxon_name: destroy)

    expect(synonym.reload.cached_valid_taxon_name_id).to eq(destroy.id)

    keep.unify(destroy)

    expect(destroy.destroyed?).to be_truthy
    expect(synonym.reload.cached_valid_taxon_name_id).to eq(keep.id)
    expect(synonym.valid_taxon_name).to eq(keep)
  end

  # Same shape, opposite side of the TNR: here Aus bus (destroy) is itself the
  # *subject* (a Synonym) of a relationship pointing to some unrelated valid
  # name, rather than being the object another name is a synonym of.
  # keep.unify(destroy) moves that relationship's subject_taxon_name over to
  # Cus dus (keep), which should itself pick up destroy's cached_valid_taxon_name_id.
  specify 'unifies TaxonNames - keep picks up cached_valid_taxon_name_id when it becomes the subject of a Synonym relationship' do
    keep = FactoryBot.create(:relationship_species)       # Cus dus
    destroy = FactoryBot.create(:relationship_species)    # Aus bus, a synonym
    valid_name = FactoryBot.create(:relationship_species) # the name Aus bus is a synonym of

    FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
      subject_taxon_name: destroy, object_taxon_name: valid_name)

    expect(destroy.reload.cached_valid_taxon_name_id).to eq(valid_name.id)
    expect(keep.reload.cached_valid_taxon_name_id).to eq(keep.id)

    keep.unify(destroy)

    expect(destroy.destroyed?).to be_truthy
    expect(keep.reload.cached_valid_taxon_name_id).to eq(valid_name.id)
    expect(keep.valid_taxon_name).to eq(valid_name)
  end

  specify 'InvalidForeignKey error' do
    keep = FactoryBot.create(:valid_topic)
    remove = FactoryBot.create(:valid_topic)

    # Simulate a DB-level FK violation on destroy of the "remove" record.
    allow(remove).to receive(:destroy!).and_raise(
      ActiveRecord::InvalidForeignKey.new('PG::ForeignKeyViolation: update or delete on table ...')
    )

    result = keep.unify(remove)

    expect(result[:result][:unified]).to be(false)

    error = result[:details][:Object][:errors].first
    expect(error[:id]).to eq(remove.id)
    expect(error[:exception]).to eq('ActiveRecord::InvalidForeignKey')
    expect(error[:message]).to match(/ForeignKey|foreign key|PG::/i)
  end

  specify 'unifying TaxonNames moves observation_matrix_row_items to the surviving taxon name' do
    om = FactoryBot.create(:valid_observation_matrix)
    t1 = FactoryBot.create(:valid_taxon_name)
    t2 = FactoryBot.create(:valid_taxon_name)
    row_item = ObservationMatrixRowItem::Dynamic::TaxonName.create!(observation_matrix: om, observation_object: t2)
    t1.unify(t2)
    expect(t2.destroyed?).to be_truthy
    expect(ObservationMatrixRowItem.where(id: row_item.id).exists?).to be(true)
    expect(row_item.reload.observation_object_id).to eq(t1.id)
  end

  context 'acts_as_list positions' do
    let(:ns) { FactoryBot.create(:valid_namespace) }
    let(:ce1) { FactoryBot.create(:valid_collecting_event) }
    let(:ce2) { FactoryBot.create(:valid_collecting_event) }

    context 'when only the removed CE has identifiers' do
      let!(:id_ce2_secondary) { Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-B') }
      let!(:id_ce2_preferred) { Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-A') }

      specify 'ce2 preferred becomes ce1 preferred' do
        ce1.unify(ce2)
        expect(ce1.reload.identifiers.order(:position).first.id).to eq(id_ce2_preferred.id)
      end

      specify 'ce2 secondary is last' do
        ce1.unify(ce2)
        expect(ce1.reload.identifiers.order(:position).last.id).to eq(id_ce2_secondary.id)
      end
    end

    context 'when both CEs have an identifier' do
      let!(:id_ce1) { Identifier::Local::Event.create!(identifier_object: ce1, namespace: ns, identifier: 'CE1-A') }
      before {
        Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-A')
      }

      specify "ce1's original identifier remains preferred after unify" do
        ce1.unify(ce2)
        expect(ce1.reload.identifiers.order(:position).first.id).to eq(id_ce1.id)
      end
    end

    context 'when both CEs have multiple identifiers' do
      # ce1: create B first (pos 2), then A (pos 1) — A is preferred
      let!(:id_ce1_secondary) { Identifier::Local::Event.create!(identifier_object: ce1, namespace: ns, identifier: 'CE1-B') }
      let!(:id_ce1_preferred) { Identifier::Local::Event.create!(identifier_object: ce1, namespace: ns, identifier: 'CE1-A') }
      # ce2: create D first (pos 2), then C (pos 1) — C is preferred
      let!(:id_ce2_secondary) { Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-D') }
      let!(:id_ce2_preferred) { Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-C') }

      specify 'ce1 identifiers retain their order, followed by ce2 identifiers in their original order' do
        ce1.unify(ce2)
        expect(ce1.reload.identifiers.order(:position).pluck(:id)).to eq(
          [id_ce1_preferred.id, id_ce1_secondary.id, id_ce2_preferred.id, id_ce2_secondary.id]
        )
      end
    end

    context 'collector role order during unify' do
      let(:ce1) { FactoryBot.create(:valid_collecting_event) }
      let(:ce2) { FactoryBot.create(:valid_collecting_event) }
      let(:person1) { FactoryBot.create(:valid_person) }
      let(:person2) { FactoryBot.create(:valid_person) }
      let(:person3) { FactoryBot.create(:valid_person) }
      let(:person4) { FactoryBot.create(:valid_person) }

      # Bottom-insertion: each new role appends to the end, so creation order = position order.
      let!(:role_ce1_a) { Collector.create!(person: person1, role_object: ce1) }
      let!(:role_ce1_b) { Collector.create!(person: person2, role_object: ce1) }
      let!(:role_ce2_a) { Collector.create!(person: person3, role_object: ce2) }
      let!(:role_ce2_b) { Collector.create!(person: person4, role_object: ce2) }

      before { ce1.unify(ce2) }

      specify 'ce2 is destroyed' do
        expect(ce2.destroyed?).to be_truthy
      end

      specify 'all four collector roles are on ce1' do
        expect(ce1.collector_roles.reload.count).to eq(4)
      end

      specify 'ce1 original collectors retain their relative order, followed by ce2 collectors in their original order' do
        ordered_ids = ce1.collector_roles.reload.order(:position).pluck(:id)
        expect(ordered_ids).to eq([role_ce1_a.id, role_ce1_b.id, role_ce2_a.id, role_ce2_b.id])
      end
    end
  end

  context 'Georeferences on Collecting Events' do
    let(:ce1) { FactoryBot.create(:valid_collecting_event) }
    let(:ce2) { FactoryBot.create(:valid_collecting_event) }

    context 'when the removed CE has a georeference' do
      before { Georeference::Wkt.create!(wkt: 'POINT (10 10)', collecting_event: ce2) }

      specify 'the removed CE is destroyed' do
        ce1.unify(ce2)
        expect(ce2.destroyed?).to be_truthy
      end
    end

    context 'when the target CE also has a georeference' do
      let!(:georef1) { Georeference::Wkt.create!(wkt: 'POINT (10 10)', collecting_event: ce1) }

      before { Georeference::Wkt.create!(wkt: 'POINT (20 20)', collecting_event: ce2) }

      specify 'the target CE retains its original georeference as preferred' do
        ce1.unify(ce2)
        expect(ce1.reload.preferred_georeference.id).to eq(georef1.id)
      end

      specify 'the moved georeference is positioned after the existing one' do
        ce1.unify(ce2)
        expect(ce1.reload.georeferences.order(:position).last.geographic_item.geo_object.to_s).to include('20.0 20.0')
      end

      specify 'geographic_name_classification_method is :preferred_georeference' do
        ce1.unify(ce2)
        expect(ce1.reload.send(:geographic_name_classification_method)).to eq(:preferred_georeference)
      end
    end

    context 'when the target CE has no georeference and the removed CE has two' do
      let!(:georef_secondary) { Georeference::Wkt.create!(wkt: 'POINT (20 20)', collecting_event: ce2) }
      let!(:georef_preferred) { Georeference::Wkt.create!(wkt: 'POINT (10 10)', collecting_event: ce2) }

      specify 'the target CE gains two georeferences' do
        ce1.unify(ce2)
        expect(ce1.reload.georeferences.count).to eq(2)
      end

      specify "ce2's preferred georeference becomes ce1's preferred georeference" do
        ce1.unify(ce2)
        expect(ce1.reload.preferred_georeference.id).to eq(georef_preferred.id)
      end

      specify 'geographic_name_classification_method is :preferred_georeference' do
        ce1.unify(ce2)
        expect(ce1.reload.send(:geographic_name_classification_method)).to eq(:preferred_georeference)
      end
    end

    context 'when both CEs have georeferences' do
      let!(:georef_ce1) { Georeference::Wkt.create!(wkt: 'POINT (1 1)', collecting_event: ce1) }
      # ce2: create secondary first (pos 2), then preferred (pos 1)
      let!(:georef_ce2_secondary) { Georeference::Wkt.create!(wkt: 'POINT (30 30)', collecting_event: ce2) }
      let!(:georef_ce2_preferred) { Georeference::Wkt.create!(wkt: 'POINT (20 20)', collecting_event: ce2) }

      specify 'the target CE has all three georeferences' do
        ce1.unify(ce2)
        expect(ce1.reload.georeferences.count).to eq(3)
      end

      specify "ce1's georeferences retain their order, followed by ce2's in their original order, with ce1's first remaining preferred" do
        ce1.unify(ce2)
        ordered = ce1.reload.georeferences.order(:position)
        expect(ordered.pluck(:id)).to eq([georef_ce1.id, georef_ce2_preferred.id, georef_ce2_secondary.id])
        expect(ce1.preferred_georeference.id).to eq(georef_ce1.id)
      end
    end

    context 'georeference subtype associations excluded from merge_relations' do
      # verbatim_data_georeference (has_one) and geo_locate_georeferences
      # (has_many, dependent: :destroy) are excluded from merge_relations by the
      # class_name: rule.
      # They are moved as part of the base :georeferences association instead.
      # If the move didn't happen, ce2's destruction would cascade-delete these
      # records via their own dependent: :destroy. The specs below fail under
      # that regression.

      specify 'VerbatimData georeference is moved to the target CE and accessible via has_one' do
        ce2_with_coords = FactoryBot.create(:valid_collecting_event,
          verbatim_latitude: '40.0',
          verbatim_longitude: '-88.0')
        vd = Georeference::VerbatimData.create!(collecting_event: ce2_with_coords)
        ce1.unify(ce2_with_coords)
        expect(ce1.reload.verbatim_data_georeference.id).to eq(vd.id)
      end

      specify 'GeoLocate georeference survives ce2 destruction and is accessible on ce1' do
        geo_locate = FactoryBot.create(:valid_georeference_geo_locate, collecting_event: ce2)
        ce1.unify(ce2)
        expect(ce1.reload.geo_locate_georeferences.map(&:id)).to include(geo_locate.id)
      end
    end

    context 'when ce1 has a geographic_area that does not contain ce2s georeference' do
      # ce1's geographic area is a small box from (0,0) to (5,5).
      # ce2's georeference is at POINT(10 10), outside that box.
      # The unify should fail entirely: unified=false, ce2 and its georef survive.
      let(:earth) { FactoryBot.create(:earth_geographic_area) }
      let(:ga_shape) {
        GeographicItem.create!(geography: 'POLYGON((0 0 0, 0 5 0, 5 5 0, 5 0 0, 0 0 0))')
      }
      let!(:ga) {
        gat = GeographicAreaType.find_or_create_by!(name: 'Test')
        a = GeographicArea.create!(
          name: 'Small area',
          data_origin: 'Test Data',
          geographic_area_type: gat,
          parent: earth)
        GeographicAreasGeographicItem.create!(geographic_item: ga_shape, geographic_area: a)
        a
      }
      let(:ce1_with_ga) { FactoryBot.create(:valid_collecting_event, geographic_area: ga) }
      let!(:georef_outside) { Georeference::Wkt.create!(wkt: 'POINT (10 10)', collecting_event: ce2) }

      specify 'unify returns unified: false' do
        result = ce1_with_ga.unify(ce2)
        expect(result[:result][:unified]).to be(false)
      end

      specify 'ce2 is not destroyed' do
        ce1_with_ga.unify(ce2)
        expect(CollectingEvent.where(id: ce2.id).exists?).to be(true)
      end

      specify 'ce2s georeference is not destroyed' do
        ce1_with_ga.unify(ce2)
        expect(Georeference.where(id: georef_outside.id).exists?).to be(true)
      end
    end
  end

  # Linting spec — catches the class_name: exclusion bug before it ships.
  #
  # inferred_relations drops any has_many/has_one that carries class_name:
  # (the rule exists to skip convenience subtype aliases and through relations).
  # When a *canonical* relation uses class_name: (e.g. because the target is a
  # namespaced class), it is silently excluded from merge_relations, so records
  # become untethered or are destroyed rather than being moved to the survivor.
  #
  # Legitimately excluded:
  #   - dependent: :restrict_with_error — destroy fails gracefully
  #   - through: relations — handled via their base relation
  #   - cache FK relations — recalculated automatically, not manually reassigned
  #   - closure_tree relations (:children, :ancestor_hierarchies, etc.) — gem-managed
  #   - Role subtypes — covered by FK-match to the base :roles relation (HasRoles)
  #   - ActiveStorage attachments — managed by Rails internals
  #   - Relations already in used_inferred_relations or covered by FK match
  #
  specify 'no has_many/has_one with class_name: goes unhandled during unify' do
    uncovered = []

    UNIFIABLE_MODELS.each do |name|
      klass = name.safe_constantize
      expect(klass).not_to be_nil, "UNIFIABLE_MODELS contains '#{name}' but it cannot be constantized"

      instance = klass.new
      expect(instance).to be_a(ApplicationRecord), "UNIFIABLE_MODELS contains '#{name}' but instantiation failed"

      used_names = instance.used_inferred_relations.map(&:name).to_set
      used_by_fk = instance.used_inferred_relations
        .group_by { |r| [r.foreign_key.to_s, r.options[:as]] }

      [:has_many, :has_one].each do |rel_type|
        ApplicationEnumeration.klass_reflections(klass, rel_type).each do |r|
          next unless r.options[:class_name].present?
          next if r.options[:dependent] == :restrict_with_error
          next if r.options[:through].present?
          next if r.foreign_key.to_s =~ /cache/
          next if r.name.to_s.match(/related/) # unify handles these in this case
          next if used_names.include?(r.name)
          next if Shared::Unify::EXCLUDE_RELATIONS.include?(r.name.to_sym)

          # closure_tree injects :children, :ancestor_hierarchies, and
          # :descendant_hierarchies. These are gem-managed and auto-maintained;
          # unify should not touch them.
          next if klass.ancestors.include?(ClosureTree::Model) &&
            %i[children ancestor_hierarchies descendant_hierarchies].include?(r.name)

          # ActiveStorage attachments are managed by Rails internals / custom
          # after_destroy hooks, not by the unify merge loop.
          next if r.options[:class_name].to_s.include?('ActiveStorage')

          # A base relation in used_inferred_relations with the same FK covers
          # these records (e.g. :roles covers :collector_roles).
          covered = used_by_fk[[r.foreign_key.to_s, r.options[:as]]].present?
          next if covered

          uncovered << "#{klass}##{r.name} " \
                       "(class_name: #{r.options[:class_name]}, " \
                       "dependent: #{r.options[:dependent].inspect})"
        end
      end
    end

    expect(uncovered).to be_empty,
      "has_many/has_one with class_name: excluded from unify merge_relations with no covering base relation.\n" \
      "Records in these relations will be untethered or destroyed rather than moved to the survivor.\n" \
      "Add the relation to unify_relations or ensure a covering base relation exists:\n" \
      "  #{uncovered.join("\n  ")}"
  end

  # Linting spec — catches missing inverse_of: on relations for models that
  # are actually exposed for unification (UNIFIABLE_MODELS).
  #
  # used_inferred_relations requires inverse_of: to be present so it can
  # reassign the FK during the merge loop. A relation that passes
  # inferred_relations but lacks inverse_of: is silently dropped from
  # merge_relations. Even if the relation is not dependent: :destroy, the
  # records become untethered — pointing at the destroyed object or nullified —
  # which is also data loss from the unify perspective.
  # Only dependent: :restrict_with_error is safe to skip, as it causes the
  # destroy to fail gracefully rather than silently losing data.
  specify 'no relation in inferred_relations is missing inverse_of: on unifiable models' do
    uncovered = []

    UNIFIABLE_MODELS.each do |name|
      klass = name.safe_constantize
      expect(klass).not_to be_nil, "UNIFIABLE_MODELS contains '#{name}' but it cannot be constantized"

      instance = klass.new
      expect(instance).to be_a(ApplicationRecord), "UNIFIABLE_MODELS contains '#{name}' but instantiation failed"

      instance.inferred_relations.each do |r|
        next if r.options[:dependent] == :restrict_with_error
        next if r.options[:inverse_of].present?

        uncovered << "#{name}##{r.name} (dependent: #{r.options[:dependent].inspect})"
      end
    end

    expect(uncovered).to be_empty,
      "Relations in inferred_relations missing inverse_of: on unifiable models.\n" \
      "Records in these relations will be untethered or destroyed rather than moved to the survivor.\n" \
      "Add inverse_of: to the relation so unify can move records to the survivor:\n" \
      "  #{uncovered.join("\n  ")}"
  end

  describe 'log_unify_result reports unmerged (not merged) when a dedup attempt does not pan out' do
    let(:helper) { TestUnify.new }
    let(:relation) { OpenStruct.new(name: :test_relation) }
    let(:result) { { result: { unified: nil }, details: {} } }

    specify 'trusts the error already on the object rather than reloading to recheck validity' do
      obj = TestUnifyIdenticalCapable.create!(string: 'a-value')
      # Fakes the aftermath of a failed relation move, without an actual
      # failed .update: obj.errors now looks exactly like it would right
      # after a failed save, but obj itself is still the one persisted,
      # perfectly valid row - reloading it would clear this and show no
      # error at all.
      obj.errors.add(:string, :taken)

      helper.send(:stub_unify_result, result, 'Test relation', 1)
      helper.send(:log_unify_result, obj, relation, result)

      # obj is the only row of its kind, so #identical (called internally
      # by deduplicate_update_target) finds no match - there's no duplicate
      # to merge into, so this must be reported as a failed move, not
      # silently treated as merged-because-obj.reload-is-valid.
      expect(result[:details]['Test relation'][:unmerged]).to eq(1)
      expect(result[:details]['Test relation'][:merged]).to eq(0)
      expect(result[:result][:unified]).to be(false)
    end
  end

end

class TestUnify < ApplicationRecord
  include FakeTable
  include Shared::Unify
end

# Like TestUnify, but also includes Shared::IsData for #identical, which
# deduplicate_update_target needs - kept separate from TestUnify so the
# plain helper class doesn't pick up Shared::IsData's broader behavior
# (callbacks, extra validations) just for tests that call private methods
# via `send` without persisting anything.
class TestUnifyIdenticalCapable < ApplicationRecord
  include FakeTable
  include Shared::Unify
  include Shared::IsData
end
