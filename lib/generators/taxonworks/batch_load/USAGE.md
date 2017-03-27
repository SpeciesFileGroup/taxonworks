Description:
    Stubs out the basic needed files for a new TaxonWorks batch loader 

Example:
    rails generate taxonworks:batch_load otu my_otu_batchloader_name

    model_name = otu 

    name = my_otu_batchloader_name 
    
    The result of this command will be:
      
       create  lib/batch_load/import/otus/my_otu_batchloader_name_interpreter.rb
       route  # routes added to otus by batch_load generator
        resource :otus do
          collection do
            get :preview_my_otu_batchloader_name_batch_load
            post :create_my_otu_batchloader_name_batch_load
          end
        end

        create/skip  app/views/otus/batch_load.html.erb
        append  app/views/otus/batch_load.html.erb
        create  app/views/otus/batch_load/my_otu_batchloader_name/_batch_load.html.erb
        create  app/views/otus/batch_load/my_otu_batchloader_name/_form.html.erb
        create  app/views/otus/batch_load/my_otu_batchloader_name/create.html.erb
        create  app/views/otus/batch_load/my_otu_batchloader_name/preview.html.erb
        insert  app/controllers/otus_controller.rb

    The batch loader should be stubbed and immediately visible under the respective model.
    Batch loaders reference interpreters in lib/batchload/import/.  Interpreters inherit
    from lib/import. 

    After running this generate the next steps are typrically to:
    1) Describe the batch loader to the user in _batch_load.html.erb  
    2) Provide additional user-provided parameters in _form.html
    3) Tweak create.html.erb and preview.html.erb to provide a response specific to this batch load
    4) Write tests and code the interpreter
