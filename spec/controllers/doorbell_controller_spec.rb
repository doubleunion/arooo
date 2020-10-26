require "spec_helper"

describe DoorbellController do
  let(:redis_double) { double(Redis) }

  before do
    allow(Redis).to receive(:new).and_return(redis_double)
    allow(redis_double).to receive(:set)
    allow(redis_double).to receive(:del)
    allow(redis_double).to receive(:get).and_return(nil)
  end

  describe "#welcome" do
    subject { get :welcome }
    context "without a recently authorized member name" do
      it "responds with a default welcome message" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.search("Say").count).to eq(2)
        expect(xml.search("Say").first.text).to include("Double Union")
      end
    end

    context "with a recently authorized member" do
      let!(:member_name) { "Ariel Jones" }

      before do
        allow(redis_double).to receive(:get).and_return(member_name)
      end

      it "welcomes the member" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.search("Say").first.text).to include(member_name)
      end

      it "plays the digit 9" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Play").attribute("digits").value).to eq("9")
      end
    end
  end

  describe "#sms" do
    let(:door_code) { create(:door_code, enabled: true) }
    let(:key_code) { door_code.code }

    subject { get :sms, params: { Body: key_code } }

    context "with an invalid keycode" do
      let(:key_code) { "bogus_code" }

      it "responds with a generic message" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Message").text).to include("is closed")
      end

      it "does not record any authorized member in Redis" do
        expect(redis_double).not_to receive(:set)
        subject
      end
    end

    context "with a valid keycode" do
      it "records the authorized member's pronounceable name in Redis" do
        door_code.user.update!(pronounceable_name: "Cee Jay")
        expect(redis_double).to receive(:set).with("member", door_code.user.reload.pronounceable_name, ex: 120)
        subject
      end

      it "records the member name in Redis if they don't have a pronounceable name" do
        door_code.user.update!(pronounceable_name: nil)
        expect(redis_double).to receive(:set).with("member", door_code.user.name, ex: 120)
        subject
      end

      it "responds with a message to dial 111" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Message").text).to include("Dial 111")
      end
    end

    context "with a valid, but disabled keycode" do
      let(:door_code) { create(:door_code, enabled: false)}

      it "responds with a generic message" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Message").text).to include("is closed")
      end

      it "does not record any authorized member in Redis" do
        expect(redis_double).not_to receive(:set)
        subject
      end
    end
    
   context "without a doorcode" do
      subject { get :sms }

      it "should raise a NoMethodError with clearer error message" do
        expect { subject }.to raise_error.with_message(/Required doorcode was not provided/)
     end
   end
  end

  describe "#gather_ismember" do
    let(:selected_option) { "guest" }
    subject { get :gather_ismember, params: { SpeechResult: selected_option } }

    context "with an invalid selection" do
      let(:selected_option) { "bogus_stuff" }

      it "redirects to doorbell welcome message" do
        expect(subject).to redirect_to(action: :welcome)
      end
    end

    context "with a guest selection" do
      let(:selected_option) { "guest" }

      it "redirects to calling the landline" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Dial").text).not_to be_empty
      end
    end

    context "with a member selection" do
      let(:selected_option) { "member" }

      it "redirects to the gather-keycode action" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Gather").attribute("action").value).to eq(doorbell_gather_keycode_path)
      end
    end
  end

  describe "#gather_keycode" do
    let(:door_code) { create(:door_code, enabled: true) }
    let(:key_code) { door_code.code }

    subject { get :gather_keycode, params: { SpeechResult: key_code } }

    context "with valid keycode" do
      it "welcomes the member" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.search("Say").first.text).to include(door_code.user.name)
      end

      it "plays the digit 9" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Play").attribute("digits").value).to eq("9")
      end
    end

    context "with invalid keycode" do
      let(:key_code) { "what is this i can't even" }

      it "redirects to gather keycode" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Gather").attribute("action").value).to eq(doorbell_gather_keycode_path)
      end
    end

    context "with disabled keycode" do
      let(:door_code) { create(:door_code, enabled: false) }

      it "redirects to gather keycode" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Gather").attribute("action").value).to eq(doorbell_gather_keycode_path)
      end
    end
  end
end
