module Api
  class EmotionTagsController < ApplicationController
    def index
      @tags = EmotionTag.order(:id).select(:id, :name_ja, :name_en)
      render :index
    end
  end
end
