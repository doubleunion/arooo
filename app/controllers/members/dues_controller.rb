class Members::DuesController < Members::MembersController

  def show
    @user = current_user

    if current_user.stripe_customer_id
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      @subscription = customer.subscriptions.first
    end
  end

  def update
    @user = current_user

    if current_user.stripe_customer_id
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      if params[:token]
        # Only try to update card if there is one. We can imagine a future scenario where a member can update their dues without inputting their CC info again.
        customer.card = params[:token]
        customer.save
      end
      subscription = customer.subscriptions.first
      if subscription
        subscription.plan = params[:plan]
        subscription.save
      else # subscription may have been canceled due to non-payment
        customer.subscriptions.create({:plan => params[:plan]})
      end

    else
      stripe_customer = Stripe::Customer.create(
        email: params[:email],
        plan: params[:plan],
        card: params[:token]
      )

      current_user.update_attribute(:stripe_customer_id, stripe_customer.id)
    end

    redirect_to members_user_dues_path, :notice => "Your dues have been updated."

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to members_user_dues_path
  end

  def scholarship_request
    DuesMailer.scholarship_requested(current_user, params[:reason]).deliver

    redirect_to members_user_dues_path, :notice => "Your scholarship request has been submitted"
  end
end
