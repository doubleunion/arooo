class DoorCode < ActionController::Base
  get '/sms' do
    Twilio::TwiML::MessagingResponse.new do |r|
      keycode = params['Body'].strip
      if keycode.length == 6 && keymembers.key?(keycode)
        name = keymembers[keycode] || 'Member'
        record_authorized_member name
        # don't actually text the name here, because the names are written in a way the
        # speech processor can pronounce and may not actually be how they spell their name
        r.message body: 'Access granted. Dial 111 on the keypad now to unlock the door.'
      else
        # TODO allow longer access codes
        r.message body: 'Invalid code. Please text your six-digit access code.'
      end
    end.to_s
  end

  get '/' do
    Twilio::TwiML::VoiceResponse.new do |r|
      name = use_authorized_member
      if name
        r.say message: "Welcome #{name}!", voice: 'alice'
        r.play digits: '9'
      else
        r.say message: 'If you are a guest or a member without a keycode, stay on the line.', voice: 'alice'
        r.say message: "If you are a member with a keycode, text it to #{ENV['DU_PHONE']} and try again.", voice: 'alice' # TODO set DU_PHONE
        r.dial do |dial|
          dial.number('+14154890104')
        end
      end
    end.to_s
  end

  # records the last authorized member for 2 minutes, or until the door is opened
  def record_authorized_member(member)
    redis = Redis.new(url: ENV['REDIS_URL'])
    redis.set('member', member, ex: 120)
  end

  # fetches and deletes the last authorized member
  def use_authorized_member
    redis = Redis.new(url: ENV['REDIS_URL'])
    member = redis.get('member')
    redis.del('member') if member
    member
  end

  # get '/' do
  #   Twilio::TwiML::Response.new do |r|
  #     r.Gather input: 'speech', timeout: 2, hints: 'member, guest', speechTimeout: 'auto', speechModel: 'numbers_and_commands', action: '/handle-gather-ismember', method: 'get' do |g|
  #       g.Say 'Welcome to Double Union!', voice: 'alice'
  #       g.Say 'If you are a guest or member without a keycode, say guest.', voice: 'alice'
  #       g.Say 'If you are a member with a keycode, say member.', voice: 'alice'
  #       g.Say 'Say anything else to start over.', voice: 'alice'
  #     end
  #   end.text
  # end

  get '/handle-gather-ismember' do
    # only 1 or 2 is a valid selection
    redirect '/' unless %w[guest member].include?(params['SpeechResult'])
    if params['SpeechResult'] == 'guest'
      # they are a guest, just call the landline
      response = redirect_call_response('Calling the landline.')
    elsif params['SpeechResult'] == 'member'
      # they are a member, ask for a code
      response = Twilio::TwiML::VoiceResponse.new do |r|
        r.gather input: 'speech', hints: '1, 2, 3, 4, 5, 6, 7, 8, 9, 0', speechTimeout: 'auto', speechModel: 'numbers_and_commands', action: '/handle-gather-keycode', method: 'get' do |g|
          g.say message: 'Please say your Double Union keycode.', voice: 'alice'
        end
      end
    end
    response.text
  end

  get '/handle-gather-keycode' do
    keycode = params['SpeechResult'].gsub(' ', '')

    if keymembers.key?(keycode)
      # they are a key member, let them in
      name = keymembers[keycode] || 'Member'
      response = Twilio::TwiML::Response.new do |r|
        r.say message: "Welcome #{name}!", voice: 'alice'
        r.play digits: '9'
      end

    else
      # invalid code, try again
      response = Twilio::TwiML::VoiceResponse.new do |r|
        r.gather input: 'speech', numDigits: '6', hints: '1, 2, 3, 4, 5, 6, 7, 8, 9, 0', speechModel: 'numbers_and_commands', action: '/handle-gather-keycode', method: 'get' do |g|
          g.say message: 'I’m sorry, I didn’t quite get that. Please say your code again.', voice: 'alice'
        end
      end
    end
    response.text
  end

  # returns a response object that redirects the call to the DU landline
  def redirect_call_response(explanation)
    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.say message: explanation, voice: 'alice'
      r.dial '+14154890104'
      r.say message: 'The call failed. Please try again.', voice: 'alice'
    end
    response
  end
end
