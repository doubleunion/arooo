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

    context "with a recently authorized member name" do
      let!(:member_name) { "Ariel" }

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
    let(:door_code) { create(:door_code) }
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
      it "records the authorized member in Redis" do
        expect(redis_double).to receive(:set).with("member", door_code.user.name, ex: 120)
        subject
      end

      it "responds with a message to dial 111" do
        subject
        xml = Nokogiri::XML(response.body)
        expect(xml.at("Message").text).to include("Dial 111")
      end
    end
  end
end
