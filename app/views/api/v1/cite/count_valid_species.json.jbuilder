extend TaxonNamesHelper
open_api_projects.each do |p|
  b = @base.where(project: p)

  json.set!('EXPERIMENTAL') do
    json.set!(p.name) do
      b.each_with_index do |n, i|
        json.set!(i) do
          c = Queries::TaxonName::Filter.new(
            taxon_name_id: [n.id],
            nomenclature_group: 'Species',
            validity: 'true',
            descendants: 'true'
          ).all  

          json.taxon_name_id n.id
          json.name n.name
          json.count c.count
          json.cite_as "#{p.name} curators. #{Time.now.year}. Valid species for #{label_for_taxon_name(n)} in #{p.name}, a database in TaxonWorks. Accessed #{Time.now} by #{request.url}." 
        end
      end
    end
  end
end

