json.array!(@leads) do |lead|
  if params[:load_root_otus]
    json.otu do
      if lead.otu.nil?
        json.nil!
      else
        json.partial! '/otus/attributes', otu: lead.otu, extensions: false
      end
    end
  end
  json.partial! 'attributes', lead:
end