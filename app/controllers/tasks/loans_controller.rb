class Tasks::LoansController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def complete
    @loan               = Loan.find(params['id'])
    @collection_objects = @loan.collection_objects
  end

  # def add_determination
  # end

  def act_on_items
    loan_items = params[:loan_items]
    loan_id    = params[:loan_id]
    message    = 'No loan items selected.'
    unless loan_items.nil?
      item_list = []
      # two different commit messages:
      case params[:commit]
        when /update/i # parse for date of item return
          date      = params[:date_returned]
          save_date = Date.new(date['date(1i)'].to_i,
                               date['date(2i)'].to_i,
                               date['date(3i)'].to_i)
          loan_items.each do |id|
            item               = LoanItem.find(id[0])
            item.date_returned = save_date
            item_list.push(item.id)
            item.save
          end
          message = "Loan items #{item_list.to_s} returned on #{save_date}."
        when /create/i # parse the information for taxon determination
          loan_items.each do |item|
            TaxonDetermination.create(taxon_determination_params)
            item_list.push(item[0])
          end
          message = "Taxon determinations created for loan items: #{item_list.to_s}."
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
    @collection_objects = Loan.find(params['id']).collection_objects
  end

  private

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
end
