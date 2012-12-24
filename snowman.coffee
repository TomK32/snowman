
class Snowman
  dt: 1000 / 60
  last_time: Date.now()
  balls: []
  eyes: []
  messages: []
  carrot: {x: 20, y: 30}#false

  constructor: () ->
    _.bindAll(@)
    @$canvas = $("#canvas")
    @canvas = @$canvas[0]
    #canvas dimensions
    @canvas.width = window.innerWidth
    @canvas.height = window.innerHeight
    @context = @canvas.getContext("2d")
    @$canvas.bind('mousedown', @startBall)
    @$canvas.bind('touchdown', @startBall)
    @snowfall = new Snowfall(@context)
    _.throttle(@draw, @dt)
    _.throttle(@update, @dt)
    @images =
      coal: @loadImage('coal.png')
      carrot: @loadImage('carrot.png')
    @update()
    @draw()
    @

  loadImage: (filename) ->
    image = new Image()
    image.src = filename
    return image

  draw: () ->
    @drawGarden()
    @snowfall.draw()
    ball.draw() for ball in @balls
    @drawEye(eye) for eye in @eyes
    @drawText(message, 10, 40 + 20 * i) for message, i in @messages
    if @carrot
      @drawCarrot()

    @drawText('Alex der Schneemann', 10, 20, '#000000', '20px sans-serif')
    window.setTimeout(@draw, @dt)

  update: ->
    new_time = Date.now()
    dt = (new_time - @last_time) / 1024
    @last_time = new_time
    window.setTimeout(@update, @dt)
    @snowfall.update(dt)
    if @ball
      @ball.update(dt)
    #

  startBall: (event) ->
    if @balls.length >= 3
      return
    @ball = new Ball(@balls.length, @)
    @balls.push(@ball)
    @$canvas.bind('mouseup', @endBall)
    @$canvas.bind('touchup', @endBall)

  endBall: (event) ->
    @$canvas.unbind('mouseup', @endBall)
    @$canvas.unbind('touchup', @endBall)
    @ball.stop()
    @ball = null
    if @balls.length >= 3
      @$canvas.unbind('mousedown', @startBall)
      @$canvas.unbind('touchdown', @startBall)
      @messages.push('Und jetzt setzt die Augen')
      @startEyes()

  drawText: (text, x, y, color, font) ->
    @context.fillStyle = color || '#000000'
    @context.font = font || '14px serif'
    @context.fillText(text, x||10, y||20)

    @drawText
  drawGarden: ->
    @context.fillStyle = '#DDDDDD'
    @context.fillRect(0, 0, @canvas.width, @canvas.height)

  startEyes: ->
    @$canvas.bind('mousedown', @setEye)
    @$canvas.bind('touchdown', @setEye)

  setEye: (event) ->
    last = _.last(@balls)
    if @inCircle(event.offsetX, event.offsetY, last.x, last.y, last.radius)
      if !@eyes[0] || ! @inCircle(event.offsetX, event.offsetY, @eyes[0].x, @eyes[0].y, @eyes[0].radius)
        @eyes.push({x: event.offsetX, y: event.offsetY, radius: 10})
    if @eyes.length == 2
      @$canvas.unbind('mousedown', @setEye)
      @$canvas.unbind('touchdown', @setEye)
      @startCarrot()

  startCarrot: ->
    @$canvas.bind('mousedown', @setCarrot)
    @$canvas.bind('touchdown', @setCarrot)

  setCarrot: (event) ->
    last = _.last(@balls)
    if @inCircle(event.offsetX, event.offsetY, last.x, last.y, last.radius)
      @carrot = {x: event.offsetX, y: event.offsetY - 20}
      @$canvas.unbind('mousedown', @setCarrot)
      @$canvas.unbind('touchdown', @setCarrot)

  drawCarrot: ->
    @context.drawImage(@images.carrot, @carrot.x, @carrot.y)

  inCircle: (x1, y1, x2, y2, radius) ->
    sq = (x) -> x * x
    sq(x1 - x2) + sq(y1 - y2) < sq(radius)

  drawEye: (eye) ->
    @context.drawImage(@images.coal, eye.x - eye.radius/2, eye.y - eye.radius/2)

