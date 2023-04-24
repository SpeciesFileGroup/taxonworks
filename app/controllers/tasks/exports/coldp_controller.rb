require 'colrapi'

class Tasks::Exports::ColdpController < ApplicationController
  include TaskControllerConfiguration


    # GET
  def index
    @coldp_profiles = ColdpProfile.where(project_id: Current.project_id)
  end

  def show
  end

  def new
    @coldp_profile = ColdpProfile.new
    render :new
  end

  def edit
    @profile = ColdpProfile.find(params[:id])
    @taxon_name = TaxonName.find(Otu.find(@profile.otu_id).taxon_name_id)
    @otu = Otu.find(@profile.otu_id)
    @render_otu = "[#{[@taxon_name.cached, @taxon_name.cached_author_year].join(' ')}]"
    @metadata = Colrapi.dataset(dataset_id: @profile.checklistbank)
    @metadata['description'] = ERB::Util.json_escape(@metadata['description'])
    @metadata.delete("citation")  # citation is not editable or needed
  end

  def create
    data = params[:post]
    @coldp_profile = ColdpProfile.new(project_id: data[:project_id],
                                      title_alias: data[:title_alias],
                                      otu_id: params[:otu_id],
                                      prefer_unlabelled_otu: data[:prefer_unlabelled_otu],
                                      checklistbank: data[:checklistbank],
                                      export_interval: data[:export_interval])

    respond_to do |format|
      if @coldp_profile.save
        format.html { redirect_to export_coldp_task_url(@coldp_profile), notice: "Coldp profile was successfully created." }
        format.json { render :show, status: :created, location: @coldp_profile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @coldp_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @coldp_profile = ColdpProfile.find(params[:id])
    @coldp_profile.destroy

    respond_to do |format|
      format.html { redirect_to export_coldp_task_url, notice: "Coldp profile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def download
    redirect_to export_coldp_task_path, notice: 'Nothing selected' and return unless !params[:otu_id].blank?

    @coldp_profile = ColdpProfile.find(params[:id])
    @coldp_profile[:otu_id] = params[:otu_id]
    @coldp_profile[:prefer_unlabelled_otu] = params[:prefer_unlabelled_otu]
    @coldp_profile[:title_alias] = params[:title_alias]
    @coldp_profile[:checklistbank] = params[:checklistbank]
    @coldp_profile.save

    @otu = Otu.where(project_id: sessions_current_project_id).find(params.require(:otu_id))
    if @otu.taxon_name
      # TODO: because of GDPR, Colrapi has to be authenticated (as an admin?) in order to get email addresses, so the current implementation will drop email addresses

      contact = JSON.parse(params[:contact]) unless params[:contact].blank?
      publisher = JSON.parse(params[:publisher]) unless params[:publisher].blank?
      creator = JSON.parse(params[:creator]) unless params[:creator].blank?
      editor = JSON.parse(params[:editor]) unless params[:editor].blank?
      contributor = JSON.parse(params[:contributor]) unless params[:contributor].blank?

      metadata = {
        'title' => params[:title],
        'alias' => params[:title_alias],
        'issued' => params[:issued],
        'platform' => 'TaxonWorks',
        'version' => params[:version],
        'doi' => params[:doi],
        'description' => params[:description],
        'contact' => contact,
        'publisher' => publisher,
        'creator' => creator,
        'editor' => editor,
        'contributor' => contributor,
        'taxonomicScope' => params[:taxonomic_scope],
        'geographicScope' => params[:geographic_scope],
        'temporalScope' => params[:temporal_scope],
        'license' => params[:license],
        'confidence' => params[:confidence],
        'completeness' => params[:completeness]
      }
      # In development you must have the background job proccessor working: `rails jobs:work`
      download = ::Export::Coldp.download_async(@otu, metadata, request.url, prefer_unlabelled_otus: !!params[:prefer_unlabelled_otus])
      redirect_to file_download_path(download)
    else
      redirect_to export_coldp_task_path, notice: 'Please select an OTU that is linked to the nomenclature (has a taxon name).'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_coldp_profile
    @coldp_profile = ColdpProfile.find(params[:id])
  end

    # Only allow a list of trusted parameters through.
  def coldp_profile_params
    params.require(:coldp_profile).permit(:title_alias, :project_id, :otu_id, :prefer_unlabelled_otu, :checklistbank, :export_interval)
  end

end
