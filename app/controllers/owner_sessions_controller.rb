class OwnerSessionsController < ApplicationController

  def new
    if logged_in?
      @owner = current_user
    else
      @owner = nil
    end
    @message = nil
  end

  def status
    if logged_in?
      @owner = current_user
    else
      @owner = nil
    end
  end

  def create

    #raise :js if request.accepts.select do |n| n.symbol.eql?( :javascript ) end.size.zero?
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
        remember_me!
        @message = "Create new user #{@owner.name}"
      elsif !@owner.signature.eql? signature
        @owner = nil
        @message = "Signature mismatch"
      else
        auto_login @owner
        remember_me!
        @message = "Login as #{@owner.name}"
      end
    end
    render :new if @owner.nil?
  end

  def destroy
    logout
  end
end
