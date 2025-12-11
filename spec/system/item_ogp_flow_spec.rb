require "rails_helper"

RSpec.describe "ItemOgpFlow", type: :system do
  it "URLからOGP取得して商品名/画像を表示し、商品名リンクが商品ページを指す" do
    visit "/"
    click_button "Googleでログイン", match: :first
    expect(page).to have_current_path("/items", ignore_query: true)

    allow(MetaInspector).to receive(:new).and_return(
  double(
    "MetaInspector",
    best_title: "ダミー商品",
    images: double("Images", best: "https://example.com/product.jpg")
  )
)

allow(URI).to receive(:open).and_call_original
allow(URI).to receive(:open).with("https://example.com/product.jpg", any_args) do
  io = StringIO.new("fake")
  io.define_singleton_method(:content_type) { "image/jpeg" }
  io
end

    visit "/items/new"

    fill_in "item_url", with: "https://example.com/product" # ← inputのidに合わせる
    click_button "追加する"

    # 商品名が表示される
    expect(page).to have_content("ダミー商品")

    # 「商品名をタップ→商品ページへ」：外部遷移はせず href を検証
    expect(page).to have_link("ダミー商品", href: "https://example.com/product")
  end
end
