require "redis"
require "twilio-ruby"

class DoorbellController < ApplicationController

  def welcome
    response = Twilio::TwiML::VoiceResponse.new do |r|
      name = use_authorized_member
      if name
        r.say message: "Welcome #{name}!", voice: 'alice'
        r.play digits: '9'
      else
        r.say message: 'Due to the shelter in place order for the city of San Francisco, Double Union is closed.', voice: 'alice'
        r.say message: 'Contact the Double Union board via email or slack if you have any questions.', voice: 'alice'
        # r.say message: 'If you are a guest or a member without a keycode, stay on the line.', voice: 'alice'
        # r.say message: 'If you are a member with a keycode, text it to 415-214-8843 and try again.', voice: 'alice'
        # r.dial do |dial|
        #   dial.number('+14154890104')
        # end
      end
    end
    render xml: response.to_xml
  end

 def sms
    raise NoMethodError, 'Required doorcode was not provided' unless params['Body'].present?
  
    response = Twilio::TwiML::MessagingResponse.new do |r|
      keycode = params['Body'].strip
      member = get_user_by_code(keycode)
      if member
        record_authorized_member get_name_to_say(member)
        r.message body: 'Access granted. Dial 111 on the keypad now to unlock the door.'
      else
        r.message body: 'Due to the shelter in place order for the city of San Francisco, Double Union is closed until April 7th. Email board@doubleunion.org if you have any questions.'
        # r.message body: 'Invalid code. Please text your six-digit access code.'
      end
    end
    render xml: response.to_xml
  end

  def gather_ismember
    # only 1 or 2 is a valid selection
    redirect_to action: "welcome" and return unless %w[guest member].include?(params['SpeechResult'])
    if params['SpeechResult'] == 'guest'
      # they are a guest, just call the landline
      response = redirect_call_response('Calling the landline.')
    elsif params['SpeechResult'] == 'member'
      # they are a member, ask for a code
      response = Twilio::TwiML::VoiceResponse.new do |r|
        r.gather(input: 'speech', hints: '1, 2, 3, 4, 5, 6, 7, 8, 9, 0', speechTimeout: 'auto',
                 speechModel: 'numbers_and_commands', action: doorbell_gather_keycode_path, method: 'get') do |g|
          g.say message: 'Please say your Double Union keycode.', voice: 'alice'
        end
      end
    end
    render xml: response.to_xml
  end

  def gather_keycode
    keycode = params['SpeechResult'].gsub(' ','')

    member = get_user_by_code(keycode)
    if member
      # they are a key member, let them in
      response = Twilio::TwiML::VoiceResponse.new do |r|
        r.say message: "Welcome #{member.name}!", voice: 'alice'
        r.play digits: '9'
      end
    else
      # invalid code, try again
      response = Twilio::TwiML::VoiceResponse.new do |r|
        r.gather(input: 'speech', numDigits: '6', hints: '1, 2, 3, 4, 5, 6, 7, 8, 9, 0',
                 speechModel: 'numbers_and_commands', action: doorbell_gather_keycode_path, method: 'get') do |g|
          g.say message: 'I’m sorry, I didn’t quite get that. Please say your code again.', voice: 'alice'
        end
      end
    end
    render xml: response.to_xml
  end

  private
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

  # returns a response object that redirects the call to the DU landline
  def redirect_call_response(explanation)
    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.say message: explanation, voice: 'alice'
      r.dial number: '+14154890104'
      r.say message: 'The call failed. Please try again.', voice: 'alice'
    end
    response
  end

  # Gets a User object based on a keycode.
  # Returns nil if no matching code was found.
  def get_user_by_code(keycode)
    door_code = DoorCode.enabled.find_by(code: keycode)
    return nil unless door_code

    return door_code.user
  end

  # @return [String] The user's pronounceable name, if they have one, or their full name.
  def get_name_to_say(user)
    return user.pronounceable_name if user.pronounceable_name

    user.name
  end
end
