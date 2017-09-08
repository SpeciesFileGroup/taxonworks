class RefactorMatrixToObservationMatrix < ActiveRecord::Migration[4.2]
  def change

    #  matrix 
    rename_table :matrices, :observation_matrices
  
    #  matrix_rows
    remove_foreign_key :matrix_rows, column: :matrix_id
    remove_index :matrix_rows, :matrix_id
    rename_column :matrix_rows, :matrix_id, :observation_matrix_id
    
    rename_table :matrix_rows, :observation_matrix_rows

    add_index :observation_matrix_rows, :observation_matrix_id, name: 'omr_om_index' 
    add_foreign_key :observation_matrix_rows, :observation_matrices

    #  matrix_columns
    remove_foreign_key :matrix_columns, column: :matrix_id
    remove_index :matrix_columns, :matrix_id
    rename_column :matrix_columns, :matrix_id, :observation_matrix_id

    rename_table :matrix_columns, :observation_matrix_columns
    add_index :observation_matrix_columns, :observation_matrix_id, name: 'imc_om_index'
    add_foreign_key :observation_matrix_columns, :observation_matrices

    # matrix_row_items
    
    remove_foreign_key :matrix_row_items, column: :matrix_id
    remove_index :matrix_row_items, :matrix_id


    # length issues
    remove_index :matrix_row_items, :controlled_vocabulary_term_id
    remove_foreign_key :matrix_row_items, :controlled_vocabulary_terms
    remove_index :matrix_row_items, :collection_object_id
    remove_foreign_key :matrix_row_items, :collection_objects

    rename_table :matrix_row_items, :observation_matrix_row_items

    rename_column :observation_matrix_row_items, :matrix_id, :observation_matrix_id

    add_index :observation_matrix_row_items, :observation_matrix_id, name: 'omri_om_index' 
    add_foreign_key :observation_matrix_row_items, :observation_matrices

    add_index :observation_matrix_row_items, :controlled_vocabulary_term_id, name: 'omri_cvt_index' 
    add_foreign_key :observation_matrix_row_items, :controlled_vocabulary_terms

    add_index :observation_matrix_row_items, :collection_object_id, name: 'omri_co_index' 
    add_foreign_key :observation_matrix_row_items, :collection_objects 


    # matrix_column_items

    # length 
    remove_index :matrix_column_items, :controlled_vocabulary_term_id
    remove_foreign_key :matrix_column_items, :controlled_vocabulary_terms
    remove_index :matrix_column_items, :descriptor_id
    remove_foreign_key :matrix_column_items, :descriptors

    remove_foreign_key :matrix_column_items, column: :matrix_id
    remove_index :matrix_column_items, :matrix_id
    rename_column :matrix_column_items, :matrix_id, :observation_matrix_id

    rename_table :matrix_column_items, :observation_matrix_column_items
    add_index :observation_matrix_column_items, :observation_matrix_id, name: 'omci_om_index'
    add_foreign_key :observation_matrix_column_items, :observation_matrices

    add_index :observation_matrix_column_items, :descriptor_id, name: 'omci_d_index' 
    add_foreign_key :observation_matrix_column_items, :descriptors

    add_index :observation_matrix_column_items, :controlled_vocabulary_term_id, name: 'omrc_cvt_index' 
    add_foreign_key :observation_matrix_column_items, :controlled_vocabulary_terms

  end
end
