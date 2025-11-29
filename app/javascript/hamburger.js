document.addEventListener('turbo:load', () => {
  const button = document.getElementById("hamburger");
  const menu = document.getElementById("hamburger-menu");

  if (button && menu) {
    button.addEventListener("click", () => {
      // isMobileの条件を削除し、クリックされたら必ず表示/非表示を切り替える
      menu.style.display = menu.style.display === "block" ? "none" : "block";
    });
  }
});