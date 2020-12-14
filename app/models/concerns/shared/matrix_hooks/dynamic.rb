
module Shared
  module MatrixHooks

    # Code to update (dynamic) matrix content based on what goes on with this instance.
    #
    #  This code handles first creates and changes, not use increments nor destroys.  It ensures there 
    #  are rows/columns created when changes happens, that's it.
    #
    # This module handles a once-removed abstraction edge case.
    #
    # !! All modules including this code must implement either one or both (row/column) of the in/out "Interface" methods
    #
    # See spec/models/taxon_name/matrix_hook_spec.rb for specs and exercising.
    module Dynamic

      extend ActiveSupport::Concern

      included do
        before_save :dynamic_inspect_matrices
        after_save :dynamic_syncronize_matrices, if: -> {dynamic_update_matrix_row_items? || dynamic_update_matrix_column_items?} # must happen after closure_tree updates the hierarchy

        attr_accessor :dynamic_row_items_in, :dynamic_row_items_out, :dynamic_row_out_map
        attr_accessor :dynamic_column_items_in, :dynamic_column_items_out, :dynamic_column_out_map
      end

      module ClassMethods
      end

      # "Interface"
      # These methods must be implemented in all classes that include this code

      def in_scope_observation_matrix_row_items
        []
      end

      def out_of_scope_observation_matrix_row_items
        []
      end

      def in_scope_observation_matrix_column_items
        []
      end

      def out_of_scope_observation_matrix_column_items
        []
      end

      # Shared code

      def dynamic_update_matrix_row_items?
        dynamic_row_items_out && dynamic_row_items_in != dynamic_row_items_out
      end

      def dynamic_update_matrix_column_items?
        dynamic_column_items_out && dynamic_column_items_in != dynamic_column_items_out
      end

      def dynamic_remove_from_matrix_row_items
        out_of_scope_observation_matrix_row_items - (out_of_scope_observation_matrix_row_items & in_scope_observation_matrix_row_items)
      end

      def dynamic_add_to_matrix_row_items
        in_scope_observation_matrix_row_items - (in_scope_observation_matrix_row_items & out_of_scope_observation_matrix_row_items)
      end

      def dynamic_remove_from_matrix_column_items
        out_of_scope_observation_matrix_column_items - (out_of_scope_observation_matrix_column_items & in_scope_observation_matrix_column_items)
      end

      def dynamic_add_to_matrix_column_items
        in_scope_observation_matrix_column_items - (in_scope_observation_matrix_column_items & out_of_scope_observation_matrix_column_items)
      end

      def dynamic_row_items_in 
        @dynamic_row_items_in ||= in_scope_observation_matrix_row_items
      end

      def dynamic_row_items_out
        @dynamic_row_items_out ||= out_of_scope_observation_matrix_row_items
      end

      def dynamic_cleanup_in_scope_row_items(rows)
        rows.each do |mri|
          mri.row_objects.each do |o|
            p = mri.find_or_build_row(o)
            if p.persisted?
             #if p.row_object == o
             #  p.update_column(:reference_count,  p.reference_count + 1) 
             #end
            else
              p.reference_count = 1
              p.save!
            end
          end
        end
      end

      def dynamic_cleanup_out_of_scope_row_items(rows)
        rows.each do |mri|
          dynamic_row_out_map[mri.id].each do |o|
            mri.cleanup_single_matrix_row(o)
          end
        end
      end

      def dynamic_column_items_in 
        @dynamic_column_items_in ||= in_scope_observation_matrix_column_items
      end

      def dynamic_column_items_out
        @dynamic_column_items_out ||= out_of_scope_observation_matrix_column_items
      end

      # adding, incrementing
      def dynamic_cleanup_in_scope_column_items(columns)
        columns.each do |mci|
          mci.column_objects.each do |o|
            p = mci.find_or_build_column(o)
            if p.persisted?
             # See row version.  
             #if p.descriptor == o
             #  #byebug
             #  #p.update_column(:reference_count,  p.reference_count + 1) 
             #end
              #  see "only added observation_matrix column is incremented" spec  # mci.increment_matrix_column_reference_count(p)
            else
              p.reference_count = 1
              p.save!
            end
          end
        end
      end

      # removing, decrementing
      def dynamic_cleanup_out_of_scope_column_items(columns)
        columns.each do |mci|
          dynamic_column_out_map[mci.id].each do |o|
            mci.cleanup_single_matrix_column(o)
          end
        end
      end

      def dynamic_syncronize_matrices
        dynamic_cleanup_out_of_scope_row_items(@dynamic_row_items_out) if @dynamic_row_items_out
        dynamic_cleanup_in_scope_row_items(@dynamic_row_items_in) if @dynamic_row_items_in

        dynamic_cleanup_out_of_scope_column_items(@dynamic_column_items_out) if @dynamic_column_items_out
        dynamic_cleanup_in_scope_column_items(@dynamic_column_items_in) if @dynamic_column_items_in
      end

      def prepare_matrix_items
        # Rows 
     
        @dynamic_row_items_in = in_scope_observation_matrix_row_items
        @dynamic_row_items_out = out_of_scope_observation_matrix_row_items

        # After save our out maps don't capture items that *were* there, 
        # so we cache those records that need to be popped off the matrix row stack
        @dynamic_row_out_map = {}
        @dynamic_row_items_out.each do |mri|
          @dynamic_row_out_map[mri.id] = mri.row_objects
        end

        # Columns 
       
        @dynamic_column_items_in = in_scope_observation_matrix_column_items
        @dynamic_column_items_out = out_of_scope_observation_matrix_column_items
        
        # After save our out maps don't capture items that *were* there, 
        # so we cache those records that need to be popped off the matrix column stack
        @dynamic_column_out_map = {}
        @dynamic_column_items_out.each do |mci|
          @dynamic_column_out_map[mci.id] = mci.column_objects
        end
      end

      def dynamic_inspect_matrices
        # TODO: strengthen checks for whether this is necessary
        if ObservationMatrix.where(project_id: project_id).any?
          prepare_matrix_items
        end      
      end

    end
  end
end
