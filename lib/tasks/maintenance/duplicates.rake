namespace :tw do
  namespace :maintenance do
    namespace :duplicates do

      desc 'Destroy duplicate Roles and TaxonNameRelationships. Dry run by default; use PREVIEW=false to commit. Requires user_id=<id>.'
      task cleanup_roles_and_taxon_name_relationships: [:environment, :user_id] do
        $stdout.sync = true

        preview = ActiveModel::Type::Boolean.new.cast(ENV.fetch('PREVIEW', true))

        puts '*' * 80
        puts preview ? 'Dry run, transaction rolled back at the end' : '!! RUNNING FOR REAL !!'
        puts '*' * 80
        puts

        ActiveRecord::Base.transaction do
          roles_filename = cleanup_destroy_duplicate_roles
          tnrs_filename = cleanup_destroy_duplicate_taxon_name_relationships

          puts "Role records written to #{roles_filename}"
          puts "TaxonNameRelationship records written to #{tnrs_filename}"

          if preview
            puts
            puts 'No errors, rolling back on dry run'
            raise ActiveRecord::Rollback
          end
        end
      end

    end
  end
end

def cleanup_destroy_records(klass, keep_list, dups_of, string_of, filename)
  actual_destroyed = []
  File.open(filename, 'w') do |f|
    keep_list.each do |id|
      m = klass.find(id)
      f.puts "Keep:    #{string_of.call(m)}"
      dups_of.call(m).each do |dup|
        f.puts "Destroy: #{string_of.call(dup)}"

        if klass.name == 'TaxonNameRelationship'
          # Invalid objects can't be unified, so we need to move associated
          # data by hand.
          dup.citations.each { |c| c.update_column(:citation_object_id, m.id) }
          dup.notes.each { |n| n.update_column(:note_object_id, m.id) }
        end

        # Both Role and TaxonNameRelationship are isData, so both have
        # (verifier) roles and pinboard items.
        dup.roles.each { |r| r.update_column(:role_object_id, m.id) }
        dup.pinboard_items.each { |p| p.update_column(:pinned_object_id, m.id) }

        dup.destroy!
        actual_destroyed << dup.id
        print '.'
      end

      if m.reload.invalid?
        raise "Kept #{klass} #{m.id} still not valid! #{m.errors.full_messages}"
      end

      f.puts
    end
    puts
    puts
  end

  actual_destroyed
end

def cleanup_assert_no_unknown_role_associations
  # We have to handle these associations "by hand", so anytime they change we
  # need to reassess.
  # Currently we move pinboard_items and roles, the others are convenience
  # associations.
  a = [:has_one, :has_many].flat_map { |m| Role.reflect_on_all_associations(m) }.map(&:name)
  if a.sort != [:pinboard_items, :roles, :verifier_roles, :verifiers]
    raise 'Changed Role associations - make sure we handle them!'
  end
end

def cleanup_destroy_duplicate_roles
  cleanup_assert_no_unknown_role_associations

  keep_list = cleanup_roles_dups_keep.sort
  destroy_list = cleanup_roles_dups_destroy.sort

  puts '!' * 60
  puts "Keeping #{keep_list.count} dup roles, destroying #{destroy_list.count} dup roles..."
  puts '!' * 60

  roles_filename = "/tmp/role_dup_cleanup-#{Time.now.strftime('%Y%m%d_%H%M%S')}"

  actual_destroyed = cleanup_destroy_records(
    Role,
    keep_list,
    method(:cleanup_dups_of_role),
    method(:cleanup_role_string),
    roles_filename
  )

  if destroy_list.sort != actual_destroyed.sort
    raise "Unexpected role destroy list! expected #{destroy_list}, got #{actual_destroyed}"
  end

  roles_filename
end

def cleanup_assert_no_unchecked_taxon_name_relationship_dups
  # CurrentCombination has its own constraint that's stricter than what we're
  # checking: (type, object) only. Check that we don't need to worry about it.
  current_combo_dups = TaxonNameRelationship::CurrentCombination
    .group(:type, :object_taxon_name_id)
    .having('count(*) > 1')
    .count
  if current_combo_dups.any?
    raise 'Unexpected CurrentCombination dups under model scope (type, object)!'
  end

  # Combination::* subclasses add
  # validates_uniqueness_of :object_taxon_name_id, scope: :type (no project_id),
  # stricter than the parent's scope: [:type, :project_id] that the script uses.
  # Check there are no cross-project dups that the script would miss.
  combination_dups = TaxonNameRelationship::Combination
    .group(:type, :object_taxon_name_id)
    .having('count(*) > 1')
    .count
  if combination_dups.any?
    raise 'Unexpected Combination::* dups under model scope (type, object)!'
  end
end

def cleanup_assert_no_unknown_taxon_name_relationship_associations
  # We have to handle these associations "by hand", so anytime they change we
  # need to reassess.
  # Currently we move citations, notes, pinboard_items, and roles, the others
  # are convenience associations.
  a = [:has_one, :has_many].flat_map { |m| TaxonNameRelationship.reflect_on_all_associations(m) }.map(&:name)
  if a.sort != [:citation_topics, :citations, :notes, :origin_citation, :pinboard_items, :roles, :source, :sources, :subsequent_citations, :subsequent_sources, :topics, :verifier_roles, :verifiers]
    raise 'Changed TaxonNameRelationship associations - make sure we handle them!'
  end
end

def cleanup_destroy_duplicate_taxon_name_relationships
  cleanup_assert_no_unchecked_taxon_name_relationship_dups
  cleanup_assert_no_unknown_taxon_name_relationship_associations

  keep_list = cleanup_taxon_name_relationship_dups_keep
  destroy_list = cleanup_taxon_name_relationship_dups_destroy

  puts '!' * 60
  puts "Keeping #{keep_list.count} dup taxon name relationships, destroying #{destroy_list.count} dup taxon name relationships..."
  puts '!' * 60

  tnrs_filename = "/tmp/tnr_dup_cleanup-#{Time.now.strftime('%Y%m%d_%H%M%S')}"

  actual_destroyed = cleanup_destroy_records(
    TaxonNameRelationship,
    keep_list,
    method(:cleanup_dups_of_taxon_name_relationship),
    method(:cleanup_taxon_name_relationship_string),
    tnrs_filename
  )

  if destroy_list.sort != actual_destroyed.sort
    raise "Unexpected taxon_name_relationship destroy list! expected #{destroy_list}, got #{actual_destroyed}"
  end

  tnrs_filename
end

def cleanup_roles_dups_keep
  # From each dup group we keep the first one that was created.

  person_dups = Role
    .where.not(person_id: nil)
    .group(:type, :person_id, :role_object_id, :role_object_type)
    .having('count(*) > 1')
    .minimum(:id)
    .values

  org_dups = Role
    .where.not(organization_id: nil)
    .group(:type, :organization_id, :role_object_id, :role_object_type)
    .having('count(*) > 1')
    .minimum(:id)
    .values

  (person_dups + org_dups).uniq
end

def cleanup_roles_dups_destroy
  person_sql = <<~SQL
    JOIN roles rdup
    ON roles.type = rdup.type
    AND roles.person_id = rdup.person_id
    AND roles.role_object_id = rdup.role_object_id
    AND roles.role_object_type = rdup.role_object_type
    AND roles.id != rdup.id
  SQL

  org_sql = <<~SQL
    JOIN roles rdup
    ON roles.type = rdup.type
    AND roles.organization_id = rdup.organization_id
    AND roles.role_object_id = rdup.role_object_id
    AND roles.role_object_type = rdup.role_object_type
    AND roles.id != rdup.id
  SQL

  person_dups = Role
    .where.not(person_id: nil)
    .joins(person_sql)
    .pluck(:id)
    .uniq

  org_dups = Role
    .where.not(organization_id: nil)
    .joins(org_sql)
    .pluck(:id)
    .uniq

  (person_dups + org_dups).uniq - cleanup_roles_dups_keep
end

def cleanup_role_string(r)
  r = r.attributes.symbolize_keys
  "#{r[:type]}(#{r[:id]}): person(#{r[:person_id]}), object_type(#{r[:role_object_type]}), object_id(#{r[:role_object_id]}), project_id(#{r[:project_id]})"
end

def cleanup_dups_of_role(r)
  r = r.attributes.symbolize_keys
  agent_key = r[:person_id] ? :person_id : :organization_id
  Role
    .where(r.slice(:type, agent_key, :role_object_id, :role_object_type))
    .where('id > ?', r[:id])
end

def cleanup_taxon_name_relationship_dups_keep
  # From each dup group we keep the first one that was created.

  # Non-combinations: unique on (type, subject, object, project)
  non_combo = TaxonNameRelationship
    .where.not('type LIKE ? OR type LIKE ?', '%OriginalCombination%', '%::Combination%')
    .group(:type, :subject_taxon_name_id, :object_taxon_name_id, :project_id)
    .having('count(*) > 1')
    .minimum(:id)
    .values

  # Combinations: unique on (type, object, project) only
  combo = TaxonNameRelationship
    .where('type LIKE ? OR type LIKE ?', '%OriginalCombination%', '%::Combination%')
    .group(:type, :object_taxon_name_id, :project_id)
    .having('count(*) > 1')
    .minimum(:id)
    .values

  (non_combo + combo).uniq
end

def cleanup_taxon_name_relationship_dups_destroy
  combo_condition = <<~SQL
    taxon_name_relationships.type LIKE '%OriginalCombination%'
    OR taxon_name_relationships.type LIKE '%::Combination%'
  SQL

  non_combo_sql = <<~SQL
    JOIN taxon_name_relationships tnrdup
    ON taxon_name_relationships.type = tnrdup.type
    AND taxon_name_relationships.subject_taxon_name_id = tnrdup.subject_taxon_name_id
    AND taxon_name_relationships.object_taxon_name_id = tnrdup.object_taxon_name_id
    AND taxon_name_relationships.project_id = tnrdup.project_id
    AND taxon_name_relationships.id != tnrdup.id
  SQL

  non_combo = TaxonNameRelationship
    .where.not(combo_condition)
    .joins(non_combo_sql)
    .pluck(:id)
    .uniq

  combo_sql = <<~SQL
    JOIN taxon_name_relationships tnrdup
    ON taxon_name_relationships.type = tnrdup.type
    AND taxon_name_relationships.object_taxon_name_id = tnrdup.object_taxon_name_id
    AND taxon_name_relationships.project_id = tnrdup.project_id
    AND taxon_name_relationships.id != tnrdup.id
  SQL

  combo = TaxonNameRelationship
    .where(combo_condition)
    .joins(combo_sql)
    .pluck(:id)
    .uniq

  (non_combo + combo).uniq - cleanup_taxon_name_relationship_dups_keep
end

def cleanup_taxon_name_relationship_string(tnr)
  tnr = tnr.attributes.symbolize_keys
  "#{tnr[:type]}(#{tnr[:id]}): subject_taxon_name_id(#{tnr[:subject_taxon_name_id]}), object_taxon_name_id(#{tnr[:object_taxon_name_id]}), project_id(#{tnr[:project_id]})"
end

def cleanup_dups_of_taxon_name_relationship(tnr)
  is_combination = tnr.is_combination?
  tnr = tnr.attributes.symbolize_keys
  if is_combination
    TaxonNameRelationship
      .where(tnr.slice(:type, :object_taxon_name_id, :project_id))
      .where('id > ?', tnr[:id])
  else
    TaxonNameRelationship
      .where(tnr.slice(:type, :subject_taxon_name_id, :object_taxon_name_id, :project_id))
      .where('id > ?', tnr[:id])
  end
end
