class Members::DuesController < Members::MembersController
  def show
    @user = current_user

    if current_user.stripe_customer_id
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      @subscription = customer.subscriptions.first
      @current_plan = amount_plan_name.fetch(@subscription.plan.amount, nil) if @subscription
    end
  end

  def cancel
    message = "You don't have an active membership dues subscription"
    if current_user.stripe_customer_id
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      @subscription = customer.subscriptions.first

      if @subscription
        @subscription.delete
        message = "Your dues have now been canceled, and the membership coordinator will remove you from mailing lists shortly."
      end
    end
    CancelMembershipMailer.cancel(current_user).deliver_now
    flash[:notice] = message
    redirect_to members_user_dues_path(current_user)
  end

  def update
    @user = current_user

    if current_user.stripe_customer_id
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      if params[:token]
        # Only try to update card if there is one. We can imagine a future scenario where a member can update their dues without inputting their CC info again.
        customer.source = params[:token]
        customer.save
      end
      subscription = customer.subscriptions.first
      if subscription
        subscription.plan = params[:plan]
        subscription.save
      else # subscription may have been canceled due to non-payment
        customer.subscriptions.create({plan: params[:plan]})
      end

    else
      stripe_customer = Stripe::Customer.create(
        email: @user.email,
        name: @user.name,
        plan: params[:plan],
        source: params[:token]
      )

      current_user.update_attribute(:stripe_customer_id, stripe_customer.id)
    end

    redirect_to redirect_target, notice: "Your dues have been updated."
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to redirect_target
  end

  def scholarship_request
    DuesMailer.scholarship_requested(current_user, params[:reason]).deliver_now

    redirect_to members_user_dues_path, notice: "Your scholarship request has been submitted"
  end

  private

  def redirect_target
    if request.referer && URI(request.referer).path =~ /setup/
      members_user_setup_path(current_user)
    else
      members_user_dues_path(current_user)
    end
  end

  def amount_plan_name
    { 10000 => "extra_large_monthly",
      7500 => "75_monthly",
      5000 => "large_monthly",
      4500 => "45_monthly",
      4000 => "40_monthly",
      3500 => "35_monthly",
      3000 => "30_monthly",
      2500 => "medium_monthly",
      2000 => "20_monthly",
      1500 => "15_monthly",
      1000 => "small_monthly" }
  end
end
