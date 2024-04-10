class ObservationMatricesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_observation_matrix, only: [
    :show, :api_show, :edit, :update, :destroy,
    :nexml, :tnt, :nexus, :csv, :otu_content, :descriptor_list,
    :reorder_rows, :reorder_columns, :row_labels, :column_labels]
  after_action -> { set_pagination_headers(:observation_matrices) }, only: [:index, :api_index], if: :json_request?

  # GET /observation_matrices
  # GET /observation_matrices.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = ObservationMatrix.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @observation_matrices = ::Queries::ObservationMatrix::Filter.new(params).all
          .where(project_id: sessions_current_project_id)
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /observation_matrices/1
  # GET /observation_matrices/1.json
  def show
  end

  def list
    @observation_matrices = ObservationMatrix.with_project_id(sessions_current_project_id).page(params[:page]).per(params[:per])
  end

  # GET /observation_matrices/new
  def new
    redirect_to new_matrix_task_path, notice: 'Redirecting to new task.'
  end

  # GET /observation_matrices/1/edit
  def edit
  end

  # POST /observation_matrices
  # POST /observation_matrices.json
  def create
    @observation_matrix = ObservationMatrix.new(observation_matrix_params)

    respond_to do |format|
      if @observation_matrix.save
        format.html { redirect_to @observation_matrix, notice: 'Matrix was successfully created.' }
        format.json { render :show, status: :created, location: @observation_matrix }
      else
        format.html { render :new }
        format.json { render json: @observation_matrix.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /observation_matrices/1
  # PATCH/PUT /observation_matrices/1.json
  def update
    respond_to do |format|
      if @observation_matrix.update(observation_matrix_params)
        format.html { redirect_to @observation_matrix, notice: 'Matrix was successfully updated.' }
        format.json { render :show, status: :ok, location: @observation_matrix }
      else
        format.html { render :edit }
        format.json { render json: @observation_matrix.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observation_matrices/1
  # DELETE /observation_matrices/1.json
  def destroy
    @observation_matrix.destroy
    respond_to do |format|
      format.html { redirect_to observation_matrices_url, notice: 'Matrix was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # .json
  def batch_create
    o = ObservationMatrix.batch_create(params.merge(project_id: sessions_current_project_id))
    if o.kind_of?(Hash)
      render json: o
    else
      render json: o, status: :unprocessable_entity
    end
  end

  # .json
  def batch_add
    o = ObservationMatrix.batch_add(params.merge(project_id: sessions_current_project_id))
    if o.kind_of?(Hash)
      render json: o
    else
      render json: o, status: :unprocessable_entity
    end
  end

  def reorder_rows
    if @observation_matrix.reorder_rows(params.require(:by))
      render json: :success
    else
      render json:  :error, status: :unprocessable_entity
    end
  end

  def reorder_columns
    @observation_matrix.reorder_columns(params.require(:by))
  end

  def autocomplete
    @observation_matrices = ObservationMatrix.where(project_id: sessions_current_project_id).where('name ilike ?', "%#{params[:term]}%")
  end

  # TODO: deprecate
  def search
    if params[:id].blank?
      redirect_to observation_matrices_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to observation_matrix_path(params[:id])
    end
  end

  def row_labels
  end

  def column_labels
  end

  # TODO export formats can move to a concern controller

  def nexml
    @options = nexml_params
    respond_to do |format|
      base =  '/observation_matrices/export/nexml/'
      format.html { render base + 'index' }
      format.rdf {
        s = render_to_string(partial: base + 'nexml', layout: false, formats: [:rdf])
        send_data(s, filename: "nexml_#{DateTime.now}.xml", type: 'text/plain')
      }
    end
  end

  def otu_content
    @options = otu_content_params
    respond_to do |format|
      base ='/observation_matrices/export/otu_content/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'otu_content', layout: false, formats: [:html])
        send_data(s, filename: "otu_content_#{DateTime.now}.csv", type: 'text/plain')
      }
    end
  end

  def descriptor_list
    respond_to do |format|
      base = '/observation_matrices/export/descriptor_list/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'descriptor_list', locals: { as_file: true }, layout: false, formats: [:html])
        send_data(s, filename: "descriptor_list_#{DateTime.now}.csv", type: 'text/plain')
      }
    end
  end

  def tnt
    respond_to do |format|
      base = '/observation_matrices/export/tnt/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'tnt', locals: { as_file: true }, layout: false, formats: [:html])
        send_data(s, filename: "tnt_#{DateTime.now}.tnt", type: 'text/plain')
      }
    end
  end

  def csv
    respond_to do |format|
      base = '/observation_matrices/export/csv/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'csv', locals: { as_file: true }, layout: false, formats: [:html])
        send_data(s, filename: "csv_#{DateTime.now}.csv", type: 'text/plain')
      }
    end
  end

  def nexus
    respond_to do |format|
      base = '/observation_matrices/export/nexus/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'nexus', locals: { as_file: true }, layout: false, formats: [:html])
        send_data(s, filename: "nexus_#{DateTime.now}.nex", type: 'text/plain')
      }
    end
  end

  # GET /observation_matrices/row.json?observation_matrix_row_id=1
  # TODO: Why is this here? (used in Matrix Row Coder)
  def row
    @observation_matrix_row = ObservationMatrixRow.where(project_id: sessions_current_project_id).find(params.require(:observation_matrix_row_id))
  end

  def column
    @observation_matrix_column = ObservationMatrixColumn.where(project_id: sessions_current_project_id).find(params.require(:observation_matrix_column_id))
  end

  def download
    send_data Export::CSV.generate_csv(ObservationMatrix.where(project_id: sessions_current_project_id)), type: 'text', filename: "observation_matrices_#{DateTime.now}.tsv"
  end

  def download_contents
    send_data Export::CSV.generate_csv(ObservationMatrix.where(project_id: sessions_current_project_id)), type: 'text', filename: "observation_matrices_#{DateTime.now}.csv"
  end

  def otus_used_in_matrices
    # ObservationMatrix.with_otu_ids_array([13597, 25680])
    if params[:otu_ids].present?
      p = ObservationMatrix.with_otu_id_array(params[:otu_ids].split('|')).pluck(:id)
      if p.nil?
        render json: {otus_used_in_matrices: ''}.to_json
      else
        render json: {otus_used_in_matrices: p}.to_json
      end
    else
      render json: {otus_used_in_matrices: ''}.to_json
    end
  end

  # GET /api/v1/observation_matrices
  def api_index
    @observation_matrices = Queries::ObservationMatrix::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .page(params[:page])
      .per(params[:per])
    render '/observation_matrices/api/v1/index'
  end

  # GET /api/v1/observation_matrices/:id
  def api_show
    render '/observation_matrices/api/v1/show'
  end

  # GET /observation_matrices/nexus_data.json
  def nexus_data
    begin
      nexus_doc = Document.find(params[:nexus_document_id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: 'Document not found' },
        status: :unprocessable_entity
      return
    end

    begin
      nf = Vendor::NexusParser.document_to_nexus(nexus_doc)
    rescue NexusParser::ParseError => e
      render json: { errors: "Nexus parse error: #{e}" },
        status: :unprocessable_entity
      return
    end

    # TODO: Deal with repeated taxa
    taxa_names = nf.taxa.collect{ |t| t.name }.sort().uniq
    otus = Otu
      .joins(:taxon_name)
      .where(project_id: sessions_current_project_id)
      .where(taxon_names: { name: taxa_names })
      .or(Otu.where(taxon_names: { cached: taxa_names }))
      .select('otus.*, taxon_names.cached as tname')
      .order('tname')

    # TODO: the nexus description says character name repeats aren't allowed,
    # but the parser currently allows them.
    descriptor_names = nf.characters.collect{ |c| c.name }.sort().uniq
    # TODO: the actual import also requires that states and labels match before
    # a TW descriptor is used, we should do the same check here.
    # Also need to make this list uniq.
    descriptors = Descriptor
      .where(project_id: sessions_current_project_id)
      .where(name: descriptor_names)
      .order(:name)

    @otus = merge_name_and_ar_lists(taxa_names, otus.to_a, 'tname')
    @descriptors = merge_name_and_ar_lists(
      descriptor_names, descriptors.to_a, 'name'
    )
  end

  # POST /observation_matrices/import_nexus.json
  def import_from_nexus
    #ImportNexusJob.perform_later(
    runit(
      params[:nexus_document_id],
      sessions_current_user_id,
      sessions_current_project_id,
      nexus_import_options_params
    )

    head :no_content
  end

  private

  # TODO: Not all params are supported yet.
  def nexml_params
    { observation_matrix: @observation_matrix,
      target: '',
      include_otus: 'true',
      include_collection_objects: 'true',
      include_descriptors: 'true',
      include_otu_depictions: 'true',
      include_matrix: 'true',
      include_trees: 'false',
      rdf: false }.merge!(
        params.permit(
          :include_otus,
          :include_collection_objects,
          :include_descriptors,
          :include_matrix,
          :include_trees,
          :rdf
        ).to_h
      )
  end

  def otu_content_params
    { observation_matrix: @observation_matrix,
      target: '',
      include_otus: 'true',
      include_collection_objects: 'false',
      include_contents: 'true',
      include_distribution: 'true',
      include_type: 'true',
      taxon_name: 'true',
      include_nomenclature: 'true',
      include_autogenerated_description: 'true',
      include_depictions: 'true',
      rdf: false }.merge!(
        params.permit(
          :include_otus,
          :include_collection_objects,
          :include_matrix,
          :include_contents,
          :include_distribution,
          :include_type,
          :taxon_name,
          :include_nomenclature,
          :include_autogenerated_description,
          :include_depictions,
          :rdf
        ).to_h
      )
  end

  def set_observation_matrix
    @observation_matrix = ObservationMatrix.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def observation_matrix_params
    params.require(:observation_matrix).permit(:name)
  end

  def nexus_import_options_params
    params.require(:options).permit(:matrix_name, :match_otu_to_taxonomy_name,
      :match_otu_to_name)
  end

  # Given a list of names and a list of ActiveRecords with a name_attr,
  # return the names list where any names matching an AR are replaced with the
  # AR.
  # !! Assumes both names and ars are ordered by name, ars' names are a
  # subset of those on the names list, and each list is uniq.
  # TODO: spec this if it stays
  def merge_name_and_ar_lists(names, ars, name_attr)
    a = []
    names.each_with_index { |n, i|
      if ars.empty?
        return a + names[i..]
      elsif n == ars.first[name_attr]
        a.push ars.shift
      else
        a.push n
      end
    }

    a
  end

  def runit(nexus_doc_id, uid, project_id, options)
    Current.user_id = uid
    Current.project_id = project_id

    begin
      nexus_doc = Document.find(nexus_doc_id)
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { nexus_document_id: nexus_doc_id }
      )
      raise
    end

    begin
      nf = Vendor::NexusParser.document_to_nexus(nexus_doc)
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { nexus_document_id: nexus_doc_id }
      )
      raise
    end


=begin
      @opt = {
          :title => false,
          :generate_short_chr_name => false,
          :generate_otu_name_with_ds_id => false, # data source, not dataset
          :generate_chr_name_with_ds_id => false,
          :match_otu_to_db_using_name => false,
          :match_otu_to_db_using_matrix_name => false,
          :match_chr_to_db_using_name => false,
          :generate_chr_with_ds_ref_id => false, # data source, not dataset
          :generate_otu_with_ds_ref_id => false,
          :generate_tags_from_notes => false,
          :generate_tag_with_note => false
        }.merge!(options)

      # run some checks on options
      raise if @opt[:generate_otu_name_with_ds_id] && !DataSource.find(@opt[:generate_otu_name_with_ds_id])
      raise if @opt[:generate_chr_name_with_ds_id] && !DataSource.find(@opt[:generate_chr_name_with_ds_id])
      raise if @opt[:generate_chr_with_ds_ref_id] && !Ref.find(@opt[:generate_chr_with_ds_ref_id])
      raise if @opt[:generate_otu_with_ds_ref_id] && !Ref.find(@opt[:generate_otu_with_ds_ref_id])
      raise ':generate_tags_from_notes must be true when including note' if @opt[:generate_tag_with_note] && !@opt[:generate_tags_from_notes]
=end

    new_otus = []
    new_chrs = []
    new_states = []

    begin
      ObservationMatrix.transaction do
        nf = assign_gap_names(nf)

        # TODO: generated title can't be used to create! twice in the same minute.
        title = options[:matrix_name].present? ?
          options[:matrix_name] :
          "Converted matrix created #{Time.now().to_formatted_s(:long)} by #{User.find(uid).name}"
        m = ObservationMatrix.create!(name: title)
        puts Rainbow("Created matrix #{title}").orange.bold

        # Find/create OTUs, add them to the matrix as we do so,
        # and add them to an array for reference during coding.
        nf.taxa.each_with_index do |o, i|
          otu = nil
          if (options[:match_otu_to_taxonomy_name] ||
            options[:match_otu_to_name])

            conditions = []
            values = []
            if options[:match_otu_to_name]
              conditions << 'name = ?'
              values << o.name
            end
            if options[:match_otu_to_taxonomy_name]
              conditions << 'taxon_names.cached = ?'
              values << o.name
            end
            condition = conditions.join(' OR ')
            otu = Otu
              .joins(:taxon_name)
              .where(project_id: sessions_current_project_id)
              .find_by(condition, *values)
          end

          if !otu
            puts Rainbow("Creating Otu #{o.name}").orange.bold
            otu = Otu.create!(name: o.name)
          else
            puts Rainbow("Found Otu #{o.name}").orange.bold
          end

          new_otus << otu
          ObservationMatrixRow.create!(
            observation_matrix: m, observation_object: otu
          )
        end

        # Find/create characters.
        nf.characters.each_with_index do |nxs_chr, i|
          tw_chr = nil
          new_states[i] = {}

          if true # @opt[:match_chr_to_db_using_name]
            # TODO: allow other types somehow?
            tw_chrs = Descriptor
              .where(project_id: sessions_current_project_id)
              .where(type: 'Descriptor::Qualitative')
              .where(name: nxs_chr.name)

            tw_chrs.each do |twc|
              # Require state labels/names from nexus and TW to match.
              # Other operations are conceivable, for instance updating the
              # chr with the new states, but the combinatorics gets very tricky
              # very quickly.

              tw_chr_states = CharacterState
                .where(project_id: sessions_current_project_id)
                .where(descriptor: twc)

              if !same_state_names_and_labels(nxs_chr.states, tw_chr_states)
                next
              end

              tw_chr = twc
              tw_chr_states.each do |twcs|
                new_states[i][twcs.label] = twcs
              end

              break
            end
          end

          if !tw_chr
            name = nxs_chr.name

            new_tw_chr_states = []
            nxs_chr.state_labels.each do |nex_state|
              new_tw_chr_states << {
                label: nex_state,
                name: nf.characters[i].states[nex_state].name
              }
              if nf.characters[i].states[nex_state].name == ''
                puts Rainbow(' NO NAME ').orange.bold
              end
            end

            tw_chr = Descriptor.create!({
              name:,
              type: 'Descriptor::Qualitative',
              character_states_attributes: new_tw_chr_states
            })

            puts Rainbow('Created states').orange.bold
            tw_chr.character_states.each do |cs|
              new_states[i][cs.label] = cs
            end
          end

          new_chrs << tw_chr
          ObservationMatrixColumn.create!(
            observation_matrix_id: m.id, descriptor: tw_chr
          )
        end

        # Create codings.
        nf.codings[0..nf.taxa.size].each_with_index do |y, i| # y is a rowvector of NexusFile::Coding
          y.each_with_index do |x, j| # x is a NexusFile::Coding
            x.states.each do |z|
              if z != '?'
                o = Observation
                  .where(project_id: sessions_current_project_id)
                  .where(type: 'Observation::Qualitative')
                  .find_by(
                    descriptor: new_chrs[j],
                    observation_object: new_otus[i],
                    character_state: new_states[j][z]
                  )

                if o.nil?
                  Observation.create!(
                    type: Observation::Qualitative,
                    descriptor: new_chrs[j],
                    observation_object: new_otus[i],
                    character_state: new_states[j][z]
                  )
                end
              end
            end
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => ex
      ExceptionNotifier.notify_exception(ex,
        data: { nexus_document_id: nexus_doc_id }
      )
      raise
    end
  end

  def same_state_names_and_labels(nex_states, tw_states)
    if nex_states.keys.sort() != tw_states.map{ |s| s.label }.sort()
      return false
    end

    tw_states.each do |s|
      if nex_states[s.label].name != s.name
        return false
      end
    end
    puts Rainbow('Character states matched').orange.bold
    true
  end

  # Assign a name to all gap states (nexus_parser outputs gap states that have
  # no name, but TW requires a name).
  # @param a nexus file object as returned by nexus_parser
  def assign_gap_names(nf)
    gap_label = nf.vars[:gap]
    if gap_label.nil?
      return nf
    end

    nf.characters.each do |c|
      if c.state_labels.include? gap_label
        c.states[gap_label].name = gap_name_for_states(c.state_labels)
      end
    end
    nf
  end

  def gap_name_for_states(states)
    if !states.include?('tw_gap')
      return 'tw_gap'
    else
      i = 1
      while states.include?("tw_gap_#{i}")
        i = i + 1
      end
      return "tw_gap#{i}"
    end
  end


end