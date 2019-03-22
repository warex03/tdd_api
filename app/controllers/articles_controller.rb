class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: [:index, :show]

  def index
    page = params[:page]
    per_page = params[:per_page]
    articles = Article.recent.page(page).per(per_page)

    render json: articles
  end

  def show

  end

  def create
    article = Article.new(article_params)
    article.save!
    render json: article, status: :created
  rescue
    render json: article,
      adapter: :json_api,
      serializer: ErrorSerializer,
      status: :unprocessable_entity
  end

  private

  def article_params
    params
      .require(:data)
      .require(:attributes)
      .permit(:title, :content, :slug) ||
    ActionController::Parameters.new
  end
end
