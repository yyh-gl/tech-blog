// Flyout Menu Functions
var toggles = {
  ".search-toggle": "#search-input",
  ".lang-toggle": "#lang-menu",
  ".share-toggle": "#share-menu",
  ".nav-toggle": "#site-nav-menu"
};

$.each(toggles, function(toggle, menu) {
  $(toggle).on("click", function() {
    if ($(menu).hasClass("active")) {
      $(".menu").removeClass("active");
      $("#wrapper").removeClass("overlay");
    } else {
      $("#wrapper").addClass("overlay");
      $(".menu").not($(menu + ".menu")).removeClass("active");
      $(menu).addClass("active");
      if (menu == "#search-input") {$("#search-results").toggleClass("active");}
    }
  });
});

// Click anywhere outside a flyout to close
$(document).on("click", function(e) {
  if ($(e.target).is(".lang-toggle, .lang-toggle span, #lang-menu, .share-toggle, .share-toggle i, #share-menu, .search-toggle, .search-toggle i, #search-input, #search-results .mini-post, .nav-toggle, .nav-toggle i, #site-nav") === false) {
    $(".menu").removeClass("active");
    $("#wrapper").removeClass('overlay');
  }
});

// Check to see if the window is top if not then display button
$(window).scroll(function() {
  if ($(this).scrollTop()) {
    $('#back-to-top').fadeIn();
  } else {
    $('#back-to-top').fadeOut();
  }
});

// Click event to scroll to top
$('#back-to-top').click(function() {
  $('html, body').animate({scrollTop: 0}, 1000);
  return false;
});
