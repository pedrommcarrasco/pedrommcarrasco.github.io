// $('.smoothScroll').click(function() {
//
//   $('html, body').animate({
//     scrollTop: $($.attr(this, 'href')).offset().top - 56
//   });
// });

var scroll = new SmoothScroll('a[href*="#"]', {
  speed: 500,
  offset: 56
});

window.sr = ScrollReveal();
sr.reveal('#about');
sr.reveal('#personal');
sr.reveal('#timeline');
sr.reveal('#contact');
