module  Shared
  module MatrixHooks

    # Code to update matrices based on what happens with this instance.
    # In this case we check whether updating an attribute might remove
    # this object from a matrix due to direct reference to a corresponding
    # matrix row item.
    # 
    # # !! All modules including this code must implement either one or both (row/column) of the in/out "Interface" methods
    #
    # See spec/models/taxon_name/matrix_hook_spec.rb for specs and exercising.
    module Member

      extend ActiveSupport::Concern
      included do
        around_save :member_syncronize_matrices
      end

      module ClassMethods
      end

      # "Interface"
      # To be defined as needed in member including classes.  
      # See app/models/taxon_name/matrix_hooks.rb for an example.

      def member_of_old_matrix_row_items
        []
      end

      def member_of_new_matrix_row_items
        []
      end

      def member_of_old_matrix_column_items
        []
      end

      def member_of_new_matrix_column_items
        []
      end

      # Shared code 

      # @return [Boolean]
      #   True if we need to update based on matrix row items
      #
      def member_update_matrix_items?(of_type = 'row')
        old = send("member_of_old_matrix_#{of_type}_items").to_a
        new = send("member_of_new_matrix_#{of_type}_items").to_a
        old && new != old # intersections assume row_items are not duplicated, which should be the case, but if errors arrise check
      end

      def member_remove_from_matrix_items(of_type = 'row')
        old = send("member_of_old_matrix_#{of_type}_items")
        new = send("member_of_new_matrix_#{of_type}_items")
        old - (old & new)
      end

      def member_add_to_matrix_items(of_type = 'row')
        old = send("member_of_old_matrix_#{of_type}_items")
        new = send("member_of_new_matrix_#{of_type}_items")
        new - (new & old)
      end

      # TODO: we could `of_type` abstract this as well
      #
      
      # Rows

       def member_add_matrix_rows(rows)
        rows.each do |mri|
          mri.update_single_matrix_row(self)
        end
      end

      def member_remove_matrix_rows(rows)
        rows.each do |mri|
          mri.cleanup_single_matrix_row(self)
        end
      end

      # Columns 

      def member_add_matrix_columns(columns)
        columns.each do |mci|
          mci.update_single_matrix_column(self)
        end
      end

      def member_remove_matrix_columns(columns)
        columns.each do |mci|
          mci.cleanup_single_matrix_column(self)
        end
      end

      def member_syncronize_matrices
        # TODO: refine to eliminate other possibilities
        # Don't bother with the overhead if there are no matrices
        if ObservationMatrix.where(project_id: project_id).any?

          if member_update_matrix_items?('row') || member_update_matrix_items?('column')

            add_rows = member_add_to_matrix_items('row')
            remove_rows = member_remove_from_matrix_items('row')

            add_columns = member_add_to_matrix_items('column')
            remove_columns = member_remove_from_matrix_items('column')

            yield

            member_remove_matrix_rows(remove_rows)
            member_add_matrix_rows(add_rows)

            member_remove_matrix_columns(remove_columns)
            member_add_matrix_columns(add_columns)
          else
            yield
          end
        else
          yield
        end
      end

    end
  end
end

