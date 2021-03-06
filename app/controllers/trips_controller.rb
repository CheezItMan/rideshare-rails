class TripsController < ApplicationController
    before_action :find_trip, only: [:show, :edit, :destroy, :update]
    before_action :find_passenger, only: [:create]

  def show;  end

  def edit
  end

  def update
    @trip.date = trip_params[:date]
    @trip.rating = trip_params[:rating]
    @trip.price = trip_params[:price]
    @trip.driver_id = trip_params[:driver_id].to_i
    @trip.passenger_id = trip_params[:passenger_id].to_i

    if @trip.save
      redirect_to passenger_trip_path(@trip.passenger.id, @trip.id)
    end
  end

  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy
    if ! request.referer.include?( passenger_trip_path(@trip.passenger.id, @trip.id))
      redirect_to request.referer
    else
      redirect_to passenger_path(@trip.passenger.id)
    end
  end

  def create
    trip = @passenger.request_ride!
    if trip
      redirect_to [@passenger, trip]
    else
      redirect_to @passenger, alert: "Could not find any available drivers"
    end
  rescue RideRequestError => e
    redirect_to @passenger, alert: "Could not start a trip: #{e.message}"
  end

  private
    def find_trip
      @trip = Trip.find(params[:id])
    end

    def find_passenger
      @passenger = Passenger.find(params[:passenger_id])
    end

    def trip_params
        trip = params[:trip]
        params[:trip]["date"] = Date.new trip["date(1i)"].to_i, trip["date(2i)"].to_i, trip["date(3i)"].to_i
        params.require(:trip).permit(:date, :rating, :driver_id, :passenger_id, :price, :rating)
    end

end
