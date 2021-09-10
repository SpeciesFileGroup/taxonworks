class DwcaCreateIndexJob < ApplicationJob
  queue_as :dwca_build_index

  # @param klass [String]
  #   the target class of the objects being re-indexed (CollectionObject, TODO: AssertedDistribution)
  # @param sql_scope [String]
  #   a SQL string that when executed returns objects of klass
  def perform(klass, sql_scope: nil)
    errors = {}
    s =  klass.safe_constantize.from('(' + sql_scope + ') as ' + klass.tableize)
    s.find_each do |o|
      begin
        z = o.set_dwc_occurrence
      rescue RGeo::Error::InvalidGeometry => e
        puts Rainbow("Error [#{o.id}] bad geometry not written. #{e}").red.bold
        errors[o.to_global_id.to_s] = e
      end
    end

    errors
  end

end
