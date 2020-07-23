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
end
