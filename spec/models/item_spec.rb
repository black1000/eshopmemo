require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:user) { create(:user) }
  let(:tag)  { Tag.create(name: "TestTag") }

  it "ユーザーが存在すれば有効である" do
    item = Item.new(user: user)
    expect(item).to be_valid
  end

  it "memo が30文字以内なら有効" do
    item = Item.new(user: user, memo: "あ" * 30)
    expect(item).to be_valid
  end

  it "memo が31文字だと無効" do
    item = Item.new(user: user, memo: "あ" * 31)
    expect(item).not_to be_valid
  end

  it "tag が無くても有効" do
    item = Item.new(user: user)
    expect(item).to be_valid
  end

  it "tag があっても有効" do
    item = Item.new(user: user, tag: tag)
    expect(item).to be_valid
  end
end