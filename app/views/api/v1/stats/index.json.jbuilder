json.data do
  Project::MANIFEST.each do |k|
    j = k.safe_constantize

    c = 0
    if @project_id.nil?
      c = j.count
    else
      c = j.where(project_id: @project_id).count
    end

    if c > 0
      json.set! k.tableize.humanize, c 
    end
  end

  json.Sources Source.count
  json.Serials Serial.count
  json.Organization Organization.count
  json.People Person.count
  json.GeographicArea GeographicArea.count
  json.Namespace Namespace.count
  json.set! 'Preparation type', PreparationType.count
  json.set! 'Repositories', Repository.count
  json.set! 'Projects', Project.count
end

json.metadata do
  json.set!'Days of curation', (User.sum(:time_active).seconds / 86400).round
  json.set!("Past week: Active curators", User.where('last_seen_at > ?', 1.week.ago).count)
  json.set!("Past week: New sources", Source.where('created_at > ?', 1.week.ago).count)
  json.set!("Past week: New taxon names", TaxonName.where('created_at > ?', 1.week.ago).count)
  json.set!("Past week: New collection objects", CollectionObject.where('created_at > ?', 1.week.ago).count)
  json.set!("Past week: New users", User.where('created_at > ?', 1.week.ago).count)
end
