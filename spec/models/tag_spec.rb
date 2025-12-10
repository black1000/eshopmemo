require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "name があれば有効" do
      tag = Tag.new(name: "SampleTag", user: user)
      expect(tag).to be_valid
    end

    it "name がなければ無効" do
      tag = Tag.new(name: nil, user: user)
      expect(tag).not_to be_valid
    end

    it "同じユーザー内で name が重複すると無効" do
      Tag.create!(name: "買い物", user: user)
      duplicate = Tag.new(name: "買い物", user: user)
      expect(duplicate).not_to be_valid
    end

    it "別ユーザーなら同じ name でも有効" do
      Tag.create!(name: "買い物", user: user)

      other_user = create(:user)
      tag = Tag.new(name: "買い物", user: other_user)

      expect(tag).to be_valid
    end
  end

  describe "associations" do
    it "user に属している" do
      tag = Tag.new(name: "カテゴリ", user: user)
      expect(tag.user).to eq(user)
    end

    it "items を複数持てる" do
      tag = create(:tag, user: user)
      item1 = create(:item, user: user, tag: tag)
      item2 = create(:item, user: user, tag: tag)

      expect(tag.items).to include(item1, item2)
    end
  end
end
