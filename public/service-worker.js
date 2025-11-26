const CACHE_NAME = "eshopmemo-cache-v1";

// Rails のビルドされた CSS / JS は fingerprint を含むので
// 「ディレクトリ単位」でキャッシュするリクエスト処理にする
const urlsToCache = [
  "/",
  "/manifest.json",
];

// install —— ルートや manifest など最低限をプリキャッシュ
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache))
  );
  self.skipWaiting();
});

// activate —— 古いキャッシュの削除
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(key => key !== CACHE_NAME)
            .map(key => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

// fetch —— CSS/JS ファイルもオフラインで使えるようにキャッシュ
self.addEventListener("fetch", (event) => {

  // POST/PUT などはキャッシュしない
  if (event.request.method !== "GET") return;

  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;

      return fetch(event.request).then(response => {
        // /assets/〜 の静的ファイルだけ動的にキャッシュする
        if (event.request.url.includes("/assets/")) {
          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, response.clone());
          });
        }
        return response;
      })
    })
  );
});