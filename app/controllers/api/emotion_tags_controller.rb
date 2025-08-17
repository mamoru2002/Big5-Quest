module Api
  class EmotionTagsController < ApplicationController
    def index
      tags = EmotionTag.order(:id).select(:id, :name, :color)
      render json: tags
    end
  end
end
