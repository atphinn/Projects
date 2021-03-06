class EventsController < ApplicationController

	def new
		@event = Event.new
	end

	def create
		@event = Event.new(permit_event)
		@event.user_id = current_user.id
		if @event.save
		redirect_to event_path(@event)
	else
		flash[:red] = @events.errors.full_messages
		render "new"
	end
	end

	def index
		@events = Event.where(user_id: current_user.id)
		# right now this says all events
		# make it so that it only gets the events that belongs to the current user logged in
	end

	def show
		@event = Event.find(params[:id])
	end

	def destroy
		@event = Event.find(params[:id])
		if @event.user_id == current_user_id@event.delete
		redirect_to events_path
		else
		flash[:red] = "You cannot delete this event"
		redirect_to events_path
		end	
	end

	def payment
		@event = Event.find(params[:id])
	end

	def sendpayment
  		@event = Event.find(params[:id])
		token = params[:stripeToken]
		begin
		  charge = Stripe::Charge.create(
		    :amount => (@event.price * 100).to_i,
		    :currency => "usd",
		    :source => token,
		    :description => @event.title
		  )
		rescue Stripe::CardError => e
		    flash[:red] = "error"
			redirect_to event_path(@event)
		end  
		flash[:success] = "Purchase complete"
		redirect_to event_path
    end

	private

		def permit_event
			params.require(:event).permit(:title, :description, :price, :time, :cover, :confirm)
		end
end
