# frozen_string_literal: true

require 'spec_helper'

describe Admin::DoorCodeController do
  include AuthHelper

  let(:door_code) { create(:door_code) }
  let(:params) { { id: door_code.id } }

  # TODO: add tests for new workflow actions, once they are added
end
