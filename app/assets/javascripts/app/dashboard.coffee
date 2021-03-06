#= require jquery
#= require jquery-stay-in-web-app

addToHomeConfig =
  touchIcon: true

$ ->
  # if running on a small screen, redirect to the smartphone interface
  if screen.width < 600
    window.location = '/smartphone'

  # if running as full-screen "app" on iPad, make sure to stay in the same window
  $.stayInWebApp()

  $('.dashboard-button').hover(
    -> $(this).css 'background-image', $(this).css('background-image').replace('gray', 'blue')
    -> $(this).css 'background-image', $(this).css('background-image').replace('blue', 'gray')
  )