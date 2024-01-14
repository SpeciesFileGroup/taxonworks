module Press
  module Labels
    def self.unit_tray_header1(taxon_name_id = [])
      return nil if [taxon_name_id].flatten.empty?
      created = 0
      ::TaxonName.where(id: taxon_name_id).each do |t|
        ::Label::Generated::UnitTrayHeader1.create!(
          text: 'Unit tray header to be generated for ' + t.cached,
          total: 1,
          label_object: t,
        )
        created += 1
      end
      return created
    end
  end
end
