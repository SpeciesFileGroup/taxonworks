namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'

      desc 'time rake tw:project_import:sf_import:load_onedb data_directory=~/src/onedb2tw/working/'
      LoggedTask.define load_onedb: [:data_directory, :environment] do |logger|
        old_logger = ActiveRecord::Base.logger
        ActiveRecord::Base.logger = nil
        
        [
          [SF::SpeciesFile, 'tblFiles.txt'],
          [SF::FileUser, 'tblFileUsers.txt'],
          [SF::AuthUser, 'tblAuthUsers.txt'],
          [SF::Rank, 'tblRanks.txt'],
          [SF::Taxon, 'tblTaxa.txt'],
          [SF::GenusName, 'tblGenusNames.txt'],
          [SF::SpeciesName, 'tblSpeciesNames.txt'],
          [SF::Nomenclator, 'tblNomenclator.txt'],
          [SF::Cite, 'tblCites.txt']
        ].each do |table|
          logger.info "Loading #{table[1]} into secondary database..."
          table[0].delete_all

          file = CSV.read(@args[:data_directory] + table[1], col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          using ProgressBar::Refinements::Enumerator
          file.each.with_progressbar(format: '%a |%b%i| %p%% %t %e') do |row|
            table[0].insert(row.to_h)
          end

          nullable_fk_cols = table[0].columns.map { |c| [c.name, c.type] }
            .select { |c| c[0] =~ /ID$/ && c[1] == :integer }
            .reject { |c| table[0].primary_key == c[0] }
          
          nullable_fk_cols.each do |col| 
            logger.info "Nulled #{table[0].where(col[0] => 0).update_all(col[0] => nil)} #{table[0]}.#{col[0]} instances previously set to 0"
          end

          nullable_string_cols = table[0].columns.map { |c| [c.name, c.type] }
            .select { |c| c[1] == :string }
          
          nullable_string_cols.each do |col| 
            logger.info "Nulled #{table[0].where(col[0] => '').update_all(col[0] => nil)} #{table[0]}.#{col[0]} instances previously set to ''"
          end

          logger.info "Deleted #{table[0].delete(0)} #{table[0]} instance(s) with #{table[0].primary_key} set to 0"

          logger.info "#{table[1]} loaded."
        end

        ActiveRecord::Base.logger = old_logger
      end
    end
  end
end
