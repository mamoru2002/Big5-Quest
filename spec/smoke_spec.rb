require 'rails_helper'

RSpec.describe "Smoke" do
  it "boots Rails" do
    expect(Rails.application).to be_a(Rails::Application)
  end
end
