class ArticlesController < ApplicationController
  def index
    # articles = Article.recent
    page = params[:page]
    per_page = params[:per_page]
    articles = Article.recent.page(page).per(per_page)

    render json: articles
  end

  def show

  end
end
