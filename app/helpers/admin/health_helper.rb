module Admin::HealthHelper

  # @return Hash
  #   project_name => total missing records of kind
  def dwc_occurrence_ghosts(kind = 'CollectionObject')
    table = kind.tableize
    ApplicationRecord.connection.execute("select dwc.project_id, count(dwc.project_id) t from dwc_occurrences dwc left join #{table} tbl on dwc.dwc_occurrence_object_id = tbl.id where tbl.id is null and dwc.dwc_occurrence_object_type = '#{kind}' group by dwc.project_id;").inject({}){|hsh, v| hsh[ Project.find(v['project_id']).name ] =  v['t']; hsh}
  end

  # @return Hash
  #   project_name => total missing records of kind
  def delayed_job_queue
    h = Hash.new(0)

    ::Delayed::Job.all.each do |j|
      h[j.queue] += 1
    end
    h
  end

end
