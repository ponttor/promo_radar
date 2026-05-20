class LandingController < ApplicationController
  def index
    render inertia: 'Landing', props: {
      godFatherImageUrl: helpers.asset_path('god_father.png'),
      taxiDriverImageUrl: helpers.asset_path('taxi_driver.png')
    }
  end
end
