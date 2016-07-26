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
      page_loan = params['loan']
      # two different commit messages:
      case params[:commit]
        when /update/i # parse for date of item return
          date = params['loan']
          # save_date = Date.new(date['date(1i)'].to_i,
          #                      date['date(2i)'].to_i,
          #                      date['date(3i)'].to_i)
          loan_items.each do |id|
            # item               = LoanItem.find(id[0])
            # item.date_returned =
            # item_list.push(item.id)
            # item.save
          end
          message = "Loan items #{item_list.to_s} returned on #{'save_date'}."
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
    @collection_objects = Loan.find(params['id']).collection_objects
  end

  private

  def local_taxon_determination_params
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
