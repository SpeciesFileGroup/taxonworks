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
            TaxonDetermination.create(params[:taxon_determination])
            item_list.push(item.id)
          end
          message = "Taxon determinations created for loan items: #{item_list.to_s}."
        else
          # nothing to do, really
      end
    end
    @notice = message
      # redirect_to("/tasks/loans/complete/#{loan_id}", notice: message)
  end

  def loan_items_list
    @loan               = Loan.find(params['id'])
    @loan_items         = @loan.loan_items
    @collection_objects = Loan.find(params['id']).collection_objects
  end
end
