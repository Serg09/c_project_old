# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(->
  $('.book-caption-trigger').hover ->
    parent = $(this)
    css = parent.position()
    css.height = parent.height()
    css.width = parent.width()
    console.log css
    $('figcaption', this).css(css).show "fade", {easing: 'easeInOutExpo'}, 500
    return
  , ->
    $('figcaption', this).hide "fade", {easing: 'easeInOutQuart'}, 500
    return
  return
)
