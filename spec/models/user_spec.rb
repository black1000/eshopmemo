require 'rails_helper'

RSpec.describe User, type: :model do
    # アソシエーション
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:tags).dependent(:destroy) }
    it { should have_many(:reminders).dependent(:destroy) }

  describe ".from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456",
        info: {
          name: "Test User",
          email: "test@example.com"
        }
      )
    end

    context "ユーザーが既に存在する場合" do
      let!(:existing_user) do
        User.create!(
          provider: "google_oauth2",
          uid: "123456",
          name: "Existing User",
          email: "test@example.com",
          password: "password123"
        )
      end

      it "既存のユーザーを返す" do
        expect(User.from_omniauth(auth)).to eq(existing_user)
      end
    end

    context "ユーザーが存在しない場合" do
      it "新しいユーザーを作成する" do
        user = User.from_omniauth(auth)
        expect(user).to be_persisted
        expect(user.provider).to eq("google_oauth2")
        expect(user.uid).to eq("123456")
        expect(user.email).to eq("test@example.com")
      end
    end
  end
end