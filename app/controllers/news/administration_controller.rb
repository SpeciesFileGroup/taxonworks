#
# This is a top-level class documentation comment for the Administration Controller
#
# POST/PATCH is still handled in NewController
#
class News::AdministrationController < NewsController



 # GET /news or /news.json
  def index
    respond_to do |format|
      format.json {
        @news = News::Administration
          .page(params[:page])
          .per(params[:per])
          .order(created_at: :desc)
          
     
        @news = @news.where(type: params[:type]) if params[:type].present?
      }

    end
    render '/news/index'
  end

  def show
    @news = News::Administration.find(params[:id])
    render '/news/show'
  end

end
