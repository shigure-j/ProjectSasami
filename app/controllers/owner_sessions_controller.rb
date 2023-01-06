class OwnerSessionsController < ApplicationController
  def create

    if params[:signature].nil?
      @owner = nil
      @message = "Empty Signature"
    else
      @owner = Owner.find_by(name: params[:name])
      signature = params[:signature].read
      if @owner.nil?
        @owner = Owner.new name: owner_params[:name], signature: signature
        @owner.save
        auto_login @owner
        @message = "Create new user #{@owner.name}"
      elsif !@owner.signature.eql? signature
        @owner = nil
        @message = "Signature mismatch"
      else
        auto_login @owner
        @message = "Login as #{@owner.name}"
      end
    end
  end

  def destroy
    logout
    render "log_status", locals: {owner: nil, message: "Logout"}
  end
end
