json.extract! @project, :id, :name

if !params[:past_days].nil?
  json.recent_records do
    Project::MANIFEST.sort{|a,b| a <=> b}.each do |k|
      next if %w{Role DatasetRecord DatasetRecordField}.include? k
      j = k.safe_constantize
      r = j.where(project: @project).where('updated_at > ?', params[:past_days].to_i.days.ago)
      if r.count > 0
        json.set!(k.tableize.humanize) do
          if self.respond_to?("api_v1_#{k.tableize}_path".to_sym)
            json.api_route "/api/v1/#{k.tableize}"
          end
          json.count r.count
          json.ids r.pluck(:id)
        end
      end
    end
  end
end
