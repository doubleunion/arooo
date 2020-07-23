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
    response = Twilio::TwiML::MessagingResponse.new do |r|
      keycode = params['Body'].strip
      member = get_user_by_code(keycode)
      if member
        # TODO: In the original code, this name was a version of the name that was intended to be pronounceable by
        # Twilio robot. Right now we don't have a place in the database for this "pronounceable name", so we are using
        # the full name instead (which the robot will likely mangle).
        record_authorized_member member.name
        r.message body: 'Access granted. Dial 111 on the keypad now to unlock the door.'
      else
        r.message body: 'Due to the shelter in place order for the city of San Francisco, Double Union is closed until April 7th. Email board@doubleunion.org if you have any questions.'
        # r.message body: 'Invalid code. Please text your six-digit access code.'
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

  # Gets a User object based on a keycode.
  # Returns nil if no matching code was found.
  def get_user_by_code(keycode)
    door_code = DoorCode.find_by(code: keycode)
    return nil unless door_code

    return door_code.user
  end
end
