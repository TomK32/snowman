
class Ball
  x: 0
  y: 0
  level: 0
  game: null
  radius: 0
  tworPI: 2*Math.PI
  active: false

  constructor: (@level, @game) ->
    _.bindAll(@)
    $(@game.canvas).bind('mousemove', @moveBall)
    $(@game.canvas).bind('touchmove', @moveBall)

  moveBall: (event) ->
    @x = event.offsetX - @radius / 2
    @y = event.offsetY - @radius / 2
    @radius += 1
    @draw()

  stop: ->
    $(@game.canvas).unbind('mousemove', @moveBall)
    $(@game.canvas).unbind('touchmove', @moveBall)

  update: (dt) ->

  draw: () ->
    @game.context.beginPath()
    @game.context.stroke();
    @game.context.fillStyle = '#FFFFFF'
    @game.context.beginPath()
    @game.context.arc(@x, @y, @radius, 0, @tworPI)
    @game.context.fill()
    @game.context.fillStyle = '#ffffff00'


