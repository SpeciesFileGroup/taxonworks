namespace :tw do
  namespace :maintenance do
    namespace :otus do

      desc 'report cross-project contamination of OTUs'
      task  missplaced_references: [:environment] do |t|

        s = [@project_id]
        s = Project.order(:id).all

        gt = 0

        s.each do |p|
          errors = []
          t = 0
          Otu.reflect_on_all_associations.each do |r|
            begin
              a = Otu.joins(r.name.to_sym).where(project: p).where("otus.project_id != #{r.table_name}.project_id")

              if a.count > 0
                errors.push " * [ ] #{r.name}: " + a.count.to_s + "\n" + a.all.collect{|c| "   * [ ] #{c.id}: #{c.name} / #{c.taxon_name_id ? c.taxon_name.cached : nil}"}.join("\n")
                t += a.count
              end
            rescue ActiveRecord::StatementInvalid
            end
          end

          if !errors.empty?
            puts "* [ ] #{p.name} (#{p.id})"
            puts errors.join("\n")
            puts "    total: " + t.to_s
            gt = gt + t
          end
        end
        puts " -- Grand total: " + gt.to_s
      end
    end
  end
end
