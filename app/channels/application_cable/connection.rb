module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = get_current_user
    end

  private
    def get_current_user
      Owner.find_by id: cookies.signed[:owner_id]
    end
  end
end
