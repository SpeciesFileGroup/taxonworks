# net/http helpers
module TaxonworksNet

  # @return [String]
  #  the commit date of the current commit based
  #  on the Capistrano provided 'REVISION' as
  #  supplied by githubs API
  def self.commit_date
    revision = commit_sha
    if revision
      uri = URI("https://api.github.com/repos/SpeciesFileGroup/taxonworks/commits/#{revision}")
      begin
        response = Net::HTTP.get( uri )
        JSON.parse(response)['commit']['author']['date']
      rescue
        return 'UNKNOWN (failed to contact Github or response not parsable)'
      end
    else
      'UNKNOWN (no REVISION available)'
    end
  end

  def self.commit_sha
    file = Rails.root + 'REVISION'
    if File.exist?(file)
      File.read(file).strip
    else
      nil
    end
  end

end


