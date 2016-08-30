class Tasks::LoansController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_filter :set_objects, only: [:complete, :update_status, :return_items, :add_determination]

  def complete
    @loan                = Loan.find(params['id'])
    @taxon_determination = TaxonDetermination.new()
    @loan_item           = LoanItem.new(loan: @loan)
  end

  def update_status
    if params[:disposition].blank?
      flash[:notice] = "Select a status first."
    else
      if LoanItem.batch_update_attribute(ids: loan_item_ids_params, attribute: :disposition, value: params.fetch(:disposition))
        flash[:notice] = "Updated status of #{loan_item_ids_params.count} records."
      else
        flash[:notice] = "Failed to update #{loan_item_ids_params.count} records."
      end
    end

    render :complete
  end

  def return_items
    if params[:date_returned].blank?
      flash[:notice] = "Select a return date first."
    else
      if LoanItem.batch_update_attribute(ids: loan_item_ids_params, attribute: :date_returned, value: params.fetch(:date_returned))
        flash[:notice] = "Updated return of #{loan_item_ids_params.count} records."
      else
        flash[:notice] = "Failed to update #{loan_item_ids_params.count} records."
      end
    end

    render :complete
  end

  def add_determination
    if LoanItem.batch_determine_loan_items(ids: loan_item_ids_params, params: taxon_determination_params)
      flash[:notice] = "Updated determinations."
    else
      flash[:notice] = "Failed to update #{loan_item_ids_params.count} records."
    end

    render :complete
  end

  def act_on_items
    loan_items = params[:loan_items]
    loan_id    = params[:loan_id]
    message    = 'No loan items selected.'
    unless loan_items.nil?
      item_list = []
      # two different commit messages:
      case params['commit']
        when /status/i # parse for changed disposition
          dispo = params[:disposition]
          loan_items.each do |id|
            item             = LoanItem.find(id[0])
            item.disposition = dispo
            item.save
            item_list.push(item.id)
          end
          message = "Loan items #{item_list.to_s} status set to '#{dispo}'."
        when / date/i # parse for date of item return
          save_date = params[:date_returned]
          loan_items.each do |id|
            item                      = LoanItem.find(id[0])
            item.date_returned_jquery = save_date
            item.save
            item_list.push(item.id)
          end
          message = "Loan items #{item_list.to_s} returned on #{save_date}."
        when /create/i # parse the information for taxon determination
          collection_object_ids = []
          loan_items.each do |id| # only collection objects get taxon determination
            item = LoanItem.find(id[0])
            case item.loan_item_object_type
              when /object/i # collection object
                collection_object_ids.push(item.loan_item_object_id)
              when /contain/i # container
                collection_object_ids.push(item.loan_item_object.collection_object_ids)
              else # otu, for instance
                # next
            end
            item_list.push(item.id)
          end
          list = collection_object_ids.flatten
          list.each do |bio_object_id|
            TaxonDetermination.create(local_taxon_determination_params.merge(biological_collection_object_id: bio_object_id))
          end
          message = "#{list.count} Taxon determinations created for loan items: #{item_list.flatten.to_s}."
        else
          # nothing to do, really
      end
    end
    @notice = message
    redirect_to("/tasks/loans/complete/#{loan_id}", notice: message)
  end

  def loan_items_list
    @loan               = Loan.find(params['id'])
    @loan_items         = @loan.loan_items.order(:position)
    @collection_objects = @loan.collection_objects
  end

  private

  def set_objects
    @loan                = Loan.find(params['id'])
    @taxon_determination = TaxonDetermination.new()
  end

  def loan_item_ids_params
    items = params.permit(loan_items: [:id])[:loan_items]
    items ? items.collect { |k, v| v['id'] } : []
  end

  def taxon_determination_params
    params.require(:taxon_determination).permit(:biological_collection_object_id,
                                                :otu_id,
                                                :year_made,
                                                :month_made,
                                                :day_made,
                                                roles_attributes: [:id,
                                                                   :_destroy,
                                                                   :type,
                                                                   :person_id,
                                                                   :position,
                                                                   person_attributes: [:last_name,
                                                                                       :first_name,
                                                                                       :suffix,
                                                                                       :prefix]],
                                                otu_attributes:   [:id,
                                                                   :_destroy,
                                                                   :name,
                                                                   :taxon_name_id]
    )
  end


  def x_taxon_determination_params
    params.require(:taxon_determination).permit(
      :biological_collection_object_id, :otu_id, :year_made, :month_made, :day_made,
      roles_attributes: [:id, :_destroy, :type, :person_id, :position, person_attributes: [:last_name, :first_name, :suffix, :prefix]],
      otu_attributes:   [:id, :_destroy, :name, :taxon_name_id]
    )
  end

end
