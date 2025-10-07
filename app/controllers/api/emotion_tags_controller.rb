module Api
  class EmotionTagsController < ApplicationController
    before_action :authenticate_api_user!
    def index
      @tags = EmotionTag.order(:id).select(:id, :name_ja, :name_en)
      render :index
    end
  end
end
