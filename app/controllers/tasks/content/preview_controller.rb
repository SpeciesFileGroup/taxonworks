class Tasks::Content::PreviewController < ApplicationController
  include TaskControllerConfiguration

  def otu_content
    @otu = Otu.find(params[:otu_id]) 
  end

  def otu_content_for_layout
    @otu = Otu.find(params[:otu_id]) 
    @otu_page_layout = OtuPageLayout.find(params[:otu_page_layout_id])

    # render the partial response here
  end

end
