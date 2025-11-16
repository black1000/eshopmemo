document.addEventListener('turbo:load', () => {
  const button = document.getElementById("hamburger");
  const menu = document.getElementById("hamburger-menu");

  if (button && menu) {
    button.addEventListener("click", () => {
      menu.style.display = menu.style.display === "block" ? "none" : "block";
    });
  }
});