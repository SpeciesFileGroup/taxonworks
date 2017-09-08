class Tasks::Import::Dwca::PsuImportController < ApplicationController
  include TaskControllerConfiguration

  # rails generate taxonworks:task psu_import "import/dwca/" index:get:psu_import preview_psu_import:post:preview_psu_import do_psu_import:post:do_psu_import

  # GET
  def index
  end

  # POST
  def do_psu_import
    if params[:file]
      psuc_params = import_params.merge(pre_load)
      @result     = BatchLoad::Import::DWCA.new(psuc_params).rows
      digest_cookie(params[:file].tempfile, :psu_import_md5)
      render 'do_psu_import'
    else
      flash[:notice] = "No file provided!"
      redirect_to action: :index
    end
  end

  # POST
  def do_not_psu_import
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :psu_import_md5)
      @result = BatchLoad::Import::DWCA.new(import_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} rows processed."
        render 'collecting_events/batch_load/simple/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :index
  end

  private

  def import_params
    params.permit(:dwca_namespace, :file, :import_level)
      .merge(user_id:    sessions_current_user_id,
             project_id: sessions_current_project_id).to_h.symbolize_keys
  end

  # what to do (because you are PSUC_FEM) before you try to load the entire file
  def pre_load
    p_id            = import_params[:project_id]
    pre_load        = {}
    root            = Protonym.find_or_create_by(name:       'Root',
                                                 rank_class: 'NomenclaturalRank',
                                                 parent_id:  nil,
                                                 project_id: p_id)
    pre_load[:root] = root

    kingdom            = Protonym.find_or_create_by(name:       'Animalia',
                                                    parent_id:  root.id,
                                                    rank_class: 'NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom',
                                                    project_id: p_id)
    pre_load[:kingdom] = kingdom

    cat_no_pred            = Predicate.find_or_create_by(name:       'catalogNumber',
                                                         definition: 'The verbatim value imported from PSUC for "catalogNumber".',
                                                         project_id: p_id)
    pre_load[:cat_no_pred] = cat_no_pred

    geo_rem_kw            = Keyword.find_or_create_by(name:       'georeferenceRemarks',
                                                      definition: 'The verbatim value imported from PSUC for "georeferenceRemarks".',
                                                      project_id: p_id)
    pre_load[:geo_rem_kw] = geo_rem_kw

    repo            = Repository.find_or_create_by(name:                 'Frost Entomological Museum, Penn State University',
                                                   url:                  'http://grbio.org/institution/frost-entomological-museum-penn-state-university',
                                                   status:               'Yes',
                                                   acronym:              'PSUC',
                                                   is_index_herbariorum: false)
    pre_load[:repo] = repo

    # Namespace requires name and short_name to be present, and unique
    namespace            = Namespace.find_or_create_by(institution: 'Penn State University Collection',
                                                       name:        'Frost Entomological Museum',
                                                       short_name:  'PSUC_FEM')
    pre_load[:namespace] = namespace

    pre_load
  end

end
