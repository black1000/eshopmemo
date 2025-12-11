require 'rails_helper'


RSpec.describe Item, type: :model do
  let(:user) { create(:user) }
  let(:tag)  { create(:tag, user: user) }

  it "ユーザーが存在すれば有効である" do
    expect(build(:item, user: user)).to be_valid
  end

  it "memo が30文字以内なら有効" do
    expect(build(:item, user: user, memo: "あ" * 30)).to be_valid
  end

  it "memo が31文字だと無効" do
    expect(build(:item, user: user, memo: "あ" * 31)).not_to be_valid
  end

  it "tag が無くても有効" do
    expect(build(:item, user: user, tag: nil)).to be_valid
  end

  it "tag があっても有効" do
    expect(build(:item, user: user, tag: tag)).to be_valid
  end

  context "dependent destroy" do
    it "reminders が一緒に削除される" do
      item = create(:item, :with_reminder, user: user)
      expect { item.destroy }.to change(Reminder, :count).by(-1)
    end
  end
end
