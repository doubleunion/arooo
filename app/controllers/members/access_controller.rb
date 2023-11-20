require 'jwt'

class Members::AccessController < Members::MembersController
  def token
    return head :unprocessable_entity unless current_user.space_access?

    payload = {
      sub: current_user.email,
      nbf: Time.now.to_i - 30,
      exp: Time.now.to_i + 30
    }

    render json: { token: JWT.encode(payload, ENV['ACCESS_CONTROL_SIGNING_KEY'], 'HS256') }
  end
end
