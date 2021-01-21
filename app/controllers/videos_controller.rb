class VideosController < ApplicationController
  before_action :require_video, only: [:show]

  def index
    if params[:query]
      data = VideoWrapper.search(params[:query])
    else
      data = Video.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @video.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  def create
    errors = []

    params[:videos].each do |video_params|
      video = Video.create(
          title: video_params[:title],
          overview: video_params[:overview],
          release_date: video_params[:release_date],
          image_url: video_params[:image_url],
          external_id: video_params[:external_id],
          inventory: 1,
          )

      if !video.valid?
        errors << video.errors.messages
      end

    end

    # videos_params[:videos].each do |video_params|
    #   Video.create(video_params)
    # end

    render(
        status: :ok,
        json: {errors: errors}
    )
  end

  private

  def require_video
    @video = Video.find_by(title: params[:title])
    unless @video
      render status: :not_found, json: { errors: { title: ["No video with title #{params["title"]}"] } }
    end
  end

  def videos_params
    params.permit(videos: [:title, :overview, :release_date, :image_url, :external_id])
  end
end
