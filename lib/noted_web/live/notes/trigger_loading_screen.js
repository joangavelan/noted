export default TriggerLoadingScreen = {
  mounted() {
    this.el.addEventListener("submit", () => {
      document.querySelector("#loading-screen").classList.remove("hidden");
    });
  },
};
