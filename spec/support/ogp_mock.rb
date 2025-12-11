RSpec.configure do |config|
  config.before(:each, ogp_mock: true) do
    allow(MetaInspector).to receive(:new) do |url, **_opts|
      double(
        "MetaInspector",
        best_title: "ダミー商品",
        images: double("Images", best: "https://example.com/a.jpg")
      )
    end

    allow(URI).to receive(:open).and_call_original
    allow(URI).to receive(:open).with("https://example.com/a.jpg", any_args) do
      io = StringIO.new("fake")
      io.define_singleton_method(:content_type) { "image/jpeg" }
      io
    end
  end
end
