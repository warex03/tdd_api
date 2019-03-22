require 'rails_helper'

describe ArticlesController do
  describe '#index' do
    subject { get :index }

    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      articles = create_list :article, 2
      subject

      expect(json_data.length).to eq(2)

      Article.recent.each_with_index do |article, index|
        expect(json_data[index]['attributes']).to eq(
          "title" => article.title,
          "content" => article.content,
          "slug" => article.slug
        )
      end
    end

    it 'should return articles in the proper order' do
      old_article = create :article
      newer_article = create :article
      subject
      expect(json_data.first['id']).to eq(newer_article.id.to_s)
      expect(json_data.last['id']).to eq(old_article.id.to_s)
    end

    it 'should paginate results' do
      page = 2
      per_page = 1
      create_list :article, 3
      get :index, params: { page: page, per_page: per_page }
      expect(json_data.length).to eq(per_page)

      expected_article = Article.recent.second.id.to_s
      expect(json_data.first['id']).to eq(expected_article)
    end
  end

  describe '#create' do
    subject { post :create }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:access_token) { create :access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end

        subject { post :create, params: invalid_attributes }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject
          expect(json['errors']).to include(
            {
              'source' => { 'pointer' => '/data/attributes/title' },
              'detail' => "can't be blank"
            },
            {
              'source' => { 'pointer' => '/data/attributes/content' },
              'detail' => "can't be blank"
            },
            {
              'source' => { 'pointer' => '/data/attributes/slug' },
              'detail' => "can't be blank"
            }
          )
        end
      end

      context 'when success request sent' do
        let(:valid_attributes) do
          {
            'data' => {
              'attributes' => {
                'title' => 'Sample title',
                'content' => 'Sample content',
                'slug' => 'sample-title'
              }
            }
          }
        end

        subject { post :create, params: valid_attributes }

        it 'should have 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'should have a proper json body' do
          subject
          expect(json_data['attributes']).to include(
            valid_attributes['data']['attributes'])
        end

        it 'should create the article' do
          expect{ subject }.to change{ Article.count }.by(1)
        end
      end
    end
  end
end
