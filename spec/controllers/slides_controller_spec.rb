# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  modified_at    :datetime
#  key            :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#

require 'rails_helper'

RSpec.describe SlidesController, type: :controller do
  let(:first_user) { create(:first_user) }

  describe 'GET #index' do
    it 'render index' do
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template :index
    end

    it 'assigns the @latest_slides' do
      @latest_slides = create_list(:slide, 2)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:latest_slides).to_a).to eq(@latest_slides)
    end
  end

  describe 'GET #show' do
    it 'assigns @comment if user logged in' do
      slide = create(:slide)
      login_by_user first_user
      get :show, params: { id: slide.id }
      expect(assigns(:comment)).to be_an_instance_of(Comment)
    end
  end

  describe 'GET #new' do
    it 'render new' do
      login_by_user first_user
      get :new
      expect(response.status).to eq(200)
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    it 'succeed to create record' do
      allow(SlideHub::Cloud::Engine::AWS).to receive(:send_message).and_return(true)
      data = build(:slide)
      login_by_user first_user
      post :create, params: { slide: data.attributes }
      id = Slide.where(object_key: data.object_key).first.id
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{id}"
    end

    it 'faled to create record because of validation' do
      allow(SlideHub::Cloud::Engine::AWS).to receive(:send_message).and_return(true)
      data = build(:slide)
      data.category_id = nil # cause validation error
      login_by_user first_user
      post :create, params: { slide: data.attributes }
      expect(response.status).to eq(200)
      expect(response).to render_template 'slides/aws/new'
    end

    it 'failed to create record because of duplicate key' do
      allow(SlideHub::Cloud::Engine::AWS).to receive(:send_message).and_return(true)
      slides = create_list(:slide, 2)
      first_key = slides[0].object_key
      login_by_user first_user
      slides[1].object_key = first_key
      post :create, params: { slide: slides[1].attributes }
      expect(response.status).to eq(302)
      expect(response).to redirect_to slides_path
    end
  end

  describe 'GET #edit' do
    it 'render edit' do
      create(:slide)
      login_by_user first_user
      slide_id = Slide.where("user_id = #{first_user.id}").first.id
      get :edit, params: { id: slide_id }
      expect(response.status).to eq(200)
      expect(response).to render_template 'slides/aws/edit'
    end

    it 'redirect to show' do
      create(:slide)
      general_user = create(:general_user)
      login_by_user general_user
      slide_id = Slide.where("user_id = #{first_user.id}").first.id
      get :edit, params: { id: slide_id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{slide_id}"
    end
  end

  describe 'POST #update' do
    it 'failed to update record because the user is not the owner' do
      data = create(:slide)
      general_user = create(:general_user)
      login_by_user general_user
      post :update, params: { id: data.id, slide: data.attributes }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{data.id}"
    end

    it 'failed to update the record because of validation error and then render edit' do
      data = create(:slide)
      data.convert_status = 100
      data.name = nil
      login_by_user first_user
      post :update, params: { id: data.id, slide: data.attributes }
      expect(response.status).to eq(200)
      expect(response).to render_template 'slides/aws/edit'
    end

    it 'succeeds to update the record without running conversion' do
      data = create(:slide)
      data.convert_status = 100
      data.name = 'Engawa'
      login_by_user first_user
      post :update, params: { id: data.id, slide: data.attributes }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{data.id}"
      saved_record = Slide.find(data.id)
      expect(saved_record.name).to eq(data.name)
    end

    it 'succeeds to update the record with running conversion' do
      allow(SlideHub::Cloud::Engine::AWS).to receive(:send_message).and_return(true)
      data = create(:slide)
      data.convert_status = 0 # Not converted yet...
      data.name = 'Engawa'
      login_by_user first_user
      post :update, params: { id: data.id, slide: data.attributes }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{data.id}"
      saved_record = Slide.find(data.id)
      expect(saved_record.name).to eq(data.name)
    end
  end

  describe 'DELETE #destroy' do
    it 'failed to delete the slide because the user is not the owner' do
      data = create(:slide)
      general_user = create(:general_user)
      login_by_user general_user
      delete :destroy, params: { id: data.id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{data.id}"
    end

    it 'succeeds to update the record with running conversion' do
      allow(SlideHub::Cloud::Engine::AWS).to receive(:delete_slide).and_return(true)
      allow(SlideHub::Cloud::Engine::AWS).to receive(:delete_generated_files).and_return(true)
      data = create(:slide)
      login_by_user first_user
      delete :destroy, params: { id: data.id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to '/slides/index'
      expect(Slide.exists?(data.id)).to eq(false)
    end
  end
end
