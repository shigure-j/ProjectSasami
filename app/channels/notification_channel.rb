class NotificationChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_for nil
    if current_user.nil?
      owner_name = "Guest" 
    else
      owner_name = current_user.name.upcase_first
      stream_for current_user
    end
    #broadcast_to current_user, {
    #  title: "Information",
    #  body: "Welcome! #{owner_name}.",
    #  time: (Time.now.strftime "%a %m/%d %H:%M"),
    #  timeout: 5000
    #}
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
