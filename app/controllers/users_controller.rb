class UsersController < ApplicationController
    #before_filter :skip_first_page, :only => :new

    def new
      session.delete('ref') if session.has_key?('ref')
      @bodyId = 'home'
      @is_mobile = mobile_device?

      @user = User.new
      if current_user.nil?
        if params.has_key?('ref')
          @user = User.find_by_referral_code(params[:ref]);
          unless @user.nil?
            session[:ref] = params[:ref]
          end

          if @user.nil?
            @status = false
          else
            @status = true
          end
        else
          respond_to do |format|
            format.html # new.html.erb
          end
        end
      else
        respond_to do |format|
          format.html # new.html.erb
        end
      end

    end

    def create
      @user = User.find_by_email(params[:user][:email]);
      if session.has_key?('ref')
        if @user.nil?
          redirect_to '/users/sign_up?email='+params[:user][:email]
        else
          redirect_to '/users/sign_in?email='+params[:user][:email]
        end
      else
        if @user.nil?
            @status = false
            render 'new'
        else
          redirect_to '/users/sign_in?email='+params[:user][:email]
        end
        # redirect_to '/users/sign_in?email='+params[:user][:email]
      end
    #    # Get user to see if they have already signed up
    #    @user = User.find_by_email(params[:user][:email]);
    #
    #    # If user doesnt exist, make them, and attach referrer
    #    if @user.nil?
    #
    #        cur_ip = IpAddress.find_by_address(request.env['HTTP_X_FORWARDED_FOR'])
    #
    #        if !cur_ip
    #            cur_ip = IpAddress.create(
    #                :address => request.env['HTTP_X_FORWARDED_FOR'],
    #                :count => 0
    #            )
    #        end
    #
    #        if cur_ip.count > 2
    #            return redirect_to root_path
    #        else
    #            cur_ip.count = cur_ip.count + 1
    #            cur_ip.save
    #        end
    #
    #        @user = User.new(:email => params[:user][:email])
    #
    #        @referred_by = User.find_by_referral_code(cookies[:h_ref])
    #
    #        puts '------------'
    #        puts @referred_by.email if @referred_by
    #        puts params[:user][:email].inspect
    #        puts request.env['HTTP_X_FORWARDED_FOR'].inspect
    #        puts '------------'
    #
    #        if !@referred_by.nil?
    #            @user.referrer = @referred_by
    #        end
    #
    #        @user.save
    #    end
    #
    #    # Send them over refer action
    #    respond_to do |format|
    #        if !@user.nil?
    #            cookies[:h_email] = { :value => @user.email }
    #            format.html { redirect_to '/refer-a-friend' }
    #        else
    #            format.html { redirect_to root_path, :alert => "Something went wrong!" }
    #        end
    #    end
    end

    def refer
        email = cookies[:h_email]

        @bodyId = 'refer'
        @is_mobile = mobile_device?

        #@user = User.find_by_email(email)
        @user = current_user
        respond_to do |format|
            if !@user.nil?
                format.html #refer.html.erb
            else
                format.html { redirect_to root_path, :alert => "Something went wrong!" }
            end
        end
    end

    def policy

    end  

    def redirect
        redirect_to root_path, :status => 404
    end

    private 

    def skip_first_page
        if !Rails.application.config.ended
            email = cookies[:h_email]
            if email and !User.find_by_email(email).nil?
                redirect_to '/refer-a-friend'
            else
                cookies.delete :h_email
            end
        end
    end

end
