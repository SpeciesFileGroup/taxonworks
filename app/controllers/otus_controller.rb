class OtusController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_otu, only: [:show, :edit, :update, :destroy, :collection_objects]

  # GET /otus
  # GET /otus.json
  def index
    @recent_objects = Otu.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /otus/1
  # GET /otus/1.json
  def show
  end

  # GET /otus/new
  def new
    @otu = Otu.new
  end

  # GET /otus/1/edit
  def edit
  end

  def list
    @otus = Otu.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /otus
  # POST /otus.json
  def create
    @otu = Otu.new(otu_params)

    respond_to do |format|
      if @otu.save
        format.html { redirect_to @otu,
                                  notice: "Otu '#{@otu.name}' was successfully created." }
        format.json { render action: 'show', status: :created, location: @otu }
      else
        format.html { render action: 'new' }
        format.json { render json: @otu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /otus/1
  # PATCH/PUT /otus/1.json
  def update
    respond_to do |format|
      if @otu.update(otu_params)
        format.html { redirect_to @otu, notice: 'Otu was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @otu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /otus/1
  # DELETE /otus/1.json
  def destroy
    @otu.destroy
    respond_to do |format|
      format.html { redirect_to otus_url }
      format.json { head :no_content }
    end
  end

  # GET /api/v1/otus/1/collection_objects
  def collection_objects
    @collection_objects = Otu.find(params[:id]).collection_objects.pluck(:id)
  end

  def search
    if params[:id].blank?
      redirect_to otus_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to otu_path(params[:id])
    end
  end

  def autocomplete
    @otus = Otu.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)).includes(:taxon_name)

    data = @otus.collect do |t|
      {id:              t.id,
       label:           ApplicationController.helpers.otu_autocomplete_selected_tag(t),
       gid:             t.to_global_id.to_s,
       response_values: {
         params[:method] => t.id
       },
       label_html:      ApplicationController.helpers.otu_tag(t)
      }
    end

    render :json => data
  end

  def batch_load
  end

  def preview_simple_batch_load
    if params[:file]
      @result = BatchLoad::Import::Otus.new(batch_params.merge(user_map))
      digest_cookie(params[:file].tempfile, :batch_otus_md5)
      render('otus/batch_load/simple/preview')
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end

    # @otus = Otu.batch_preview(file: params[:file].tempfile)
    # @file = params[:file].read
    # render 'otus/batch_load/batch_preview'
  end

  def create_simple_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :batch_otus_md5)
      @result = BatchLoad::Import::Otus.new(batch_params.merge(user_map))
      if @result.create
        flash[:notice] = "Successfully processed file, #{@result.total_records_created} otus were created."
        render('otus/batch_load/simple/create') and return
      else
        flash[:alert] = 'Batch import failed.'
      end
      render(:batch_load)
    end
    # if @otus = Otu.batch_create(params.symbolize_keys.to_h)
    #   flash[:notice] = "Successfully batch created #{@otus.count} OTUs."
    # else
    #   # TODOne: more response
    #   flash[:notice] = 'Failed to create the Otus.'
    # end
    # redirect_to otus_path
  end

  def preview_simple_batch_file_load
    if params[:files]
      @result = BatchFileLoad::Import::Otus::SimpleInterpreter.new(batch_params)
      digest_cookie(params[:files][0].tempfile, :batch_file_load_simple_md5)
      render 'otus/batch_file_load/simple/preview'
    else
      flash[:notice] = 'No file(s) provided!'
      redirect_to action: :batch_load
    end
  end

  def create_simple_batch_file_load
    if params[:files] && digested_cookie_exists?(params[:files][0].tempfile, :batch_file_load_simple_md5)
      @result = BatchFileLoad::Import::Otus::SimpleInterpreter.new(batch_params)

      if @result.create
        flash[:notice] = "Successfully processed #{@result.total_files_processed} file(s), #{@result.total_records_created} otus were created."
        render 'otus/batch_file_load/simple/create'
        return
      else
        flash[:alert] = 'Batch import failed.'
        render :batch_load
      end
    end
  end

  # GET /otus/download
  def download
    send_data Otu.generate_download(Otu.where(project_id: sessions_current_project_id)), type: 'text', filename: "otus_#{DateTime.now.to_s}.csv"
  end

  # GET /api/v1/otus/by_name/"name"
  # TODO: @MJY The searches of taxon_names in otu autocomplete (on which this query is modeled) do not
  # TODO: include project_id. Is this intentional?
  def by_name
    @otu_name   = params[:name]
    # @otu_ids  = Otu.find_for_autocomplete(params.merge(term: @otu_name))
    #               .includes(:taxon_name).pluck(:id)
    where_query = where_sql
    @otu_ids    = Otu.includes(:taxon_name)
                    .where(where_query) # project_id is accounted for in each of the sub-queries
                    .references(:taxon_names)
                    .order(name: :asc) # since, as a rule (observed), otu name is empty, this does not really mean much.
                    .pluck(:id)
  end

  private

  def where_sql
    named.or(taxon_name_cached).or(taxon_name_cached_author_year).to_sql
  end

  # SELECT "otus"."id" FROM "otus"
  # LEFT OUTER JOIN "taxon_names" ON "taxon_names"."id" = "otus"."taxon_name_id"
  # WHERE ((("otus"."name" ILIKE '(Bigot, 1884)' AND "otus"."project_id" = 1
  # OR "taxon_names"."cached" ILIKE '(Bigot, 1884)' AND "taxon_names"."project_id" = 1)
  # OR "taxon_names"."cached_author_year" ILIKE '(Bigot, 1884)' AND "taxon_names"."project_id" = 1))
  # ORDER BY "otus"."name" ASC

  def named
    table[:name].eq(@otu_name).and(table[:project_id].eq(params[:project_id]))
  end

  def table
    Otu.arel_table
  end

  def taxon_name_cached
    taxon_name_table[:cached].eq(@otu_name).and(taxon_name_table[:project_id].eq(params[:project_id]))
  end

  # concat("taxon_names".cached, ' ', taxon_names.cached_author_year) = params[:name]
  def taxon_name_cached_author_year
    sql = "concat(\"taxon_names\".\"cached\", \' \', \"taxon_names\".\"cached_author_year\") = \'#{@otu_name}\' " +
      "and \"taxon_names\".\"project_id\" = #{params[:project_id]}"
    Arel::Nodes::SqlLiteral.new(sql)
  end

  def taxon_name_table
    TaxonName.arel_table
  end

  def set_otu
    @otu           = Otu.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @otu
  end

  def otu_params
    params.require(:otu).permit(:name, :taxon_name_id)
  end

  def batch_params
    params.permit(:name, :file, :import_level, :files => []).merge(user_id: sessions_current_user_id, project_id: $project_id).symbolize_keys
  end

  def user_map
    {user_header_map: {'otu' => 'otu_name'}}
  end
end
