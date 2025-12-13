// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "hamburger"

// イベント送信の共通関数（先に定義）
window.trackEvent = function (name, params = {}) {
  if (typeof gtag !== "function") return;

  gtag("event", name, {
    ...params,
    ui_language: document.documentElement.lang || "ja"
  });
};

function trackPageView() {
  if (typeof gtag !== "function") return;

  gtag("event", "page_view", {
    page_location: window.location.href,
    page_path: window.location.pathname + window.location.search,
    page_title: document.title,
    ui_language: document.documentElement.lang || "ja"
  });
}

// Turbo遷移ごとにPV送信
document.addEventListener("turbo:load", trackPageView);


// PWAインストール
window.addEventListener("appinstalled", () => {
  window.trackEvent("pwa_install");
});
