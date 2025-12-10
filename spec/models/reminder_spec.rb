require 'rails_helper'

RSpec.describe Reminder, type: :model do
  describe "associations" do
    it { should belong_to(:user).required }
    it { should belong_to(:item).required }
  end

  describe "validations" do
    it "is valid with a user and item" do
      reminder = create(:reminder)
      expect(reminder).to be_valid
    end

    it "is invalid without an item" do
      reminder = build(:reminder, item: nil)
      expect(reminder).not_to be_valid
    end
  end
end
