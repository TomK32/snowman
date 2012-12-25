
class Snowman
  dt: 1000 / 60
  last_time: Date.now()
  balls: []
  eyes: []
  instructions: false
  carrot: false
  cursor: false
  animals: []

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
    @$canvas.bind('mousemove', @setCursor)
    @$canvas.bind('touchmove', @setCursor)
    @snowfall = new Snowfall(@context)
    _.throttle(@draw, @dt)
    _.throttle(@update, @dt)
    @instructions = 'Klicke/Tippe und fahr herum um drei Kugeln zu machen'
    @images =
      coal: @loadImage('coal.png')
      carrot: @loadImage('carrot.png')
      background: @loadImage('background.png')
      animals:
        hoppel: @loadImage('hoppel.png')
        hoppel2: @loadImage('hoppel2.png')
    @animals = []
    @placeAnimals(4)
    @update()
    @draw()
    @cursor = {x: 0, y: 0, image: @images.carrot}
    @

  loadImage: (filename) ->
    image = new Image()
    image.src = filename + '?' + Date.now()
    return image

  placeAnimals: (num) ->
    for i in [0..num]
      do (i) =>
        @animals.push({
          x: Math.floor(Math.random() * @canvas.width) * 0.8 + @canvas.width * 0.1,
          y: Math.floor(Math.random() * @canvas.height*0.1) + @canvas.height* 0.6,
          image: _.values(@images.animals)[i % _.values(@images.animals).length]
        })
  draw: () ->
    @drawGarden()
    @snowfall.draw()
    @drawImage(animal) for animal in @animals
    ball.draw() for ball in @balls
    @drawEye(eye) for eye in @eyes
    @drawText(@instructions, 10, 40)
    if @carrot
      @drawCarrot()
    if @cursor
      @context.drawImage(@cursor.image, @cursor.x, @cursor.y)
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
    @instructions = 'Und noch eine Kugel'
    if @balls.length >= 3
      @$canvas.unbind('mousedown', @startBall)
      @$canvas.unbind('touchdown', @startBall)
      @startEyes()

  drawText: (text, x, y, color, font) ->
    @context.fillStyle = color || '#000000'
    @context.font = font || '14px serif'
    @context.fillText(text, x||10, y||20)

    @drawText
  drawGarden: ->
    @context.fillStyle = '#DDDDDD'
    @context.fillRect(0, 0, @canvas.width, @canvas.height)
    @context.drawImage(@images.background, 0, 0, @canvas.width, @canvas.height)

  startEyes: ->
    @cursor = {image: @images.coal}
    @instructions = 'Und jetzt setzt die Augen'
    @$canvas.bind('mousedown', @setEye)
    @$canvas.bind('touchdown', @setEye)

  setEye: (event) ->
    last = _.last(@balls)
    if @inCircle(event.offsetX, event.offsetY, last.x, last.y, last.radius)
      if !@eyes[0] || ! @inCircle(event.offsetX - @images.coal.width, event.offsetY - @images.coal.height, @eyes[0].x, @eyes[0].y, @eyes[0].radius)
        @eyes.push({x: event.offsetX - @images.coal.width, y: event.offsetY - @images.coal.height})
    if @eyes.length == 2
      @$canvas.unbind('mousedown', @setEye)
      @$canvas.unbind('touchdown', @setEye)
      @startCarrot()

  startCarrot: ->
    @$canvas.bind('mousedown', @setCarrot)
    @$canvas.bind('touchdown', @setCarrot)
    @cursor.image = @images.carrot
    @instructions = 'Und jetzt noch eine Karotte'

  setCarrot: (event) ->
    last = _.last(@balls)
    if @inCircle(event.offsetX - @images.carrot.width, event.offsetY - @images.carrot.height, last.x, last.y, last.radius)
      @carrot = {x: event.offsetX - @images.carrot.width, y: event.offsetY - @images.carrot.height}
      @$canvas.unbind('mousedown', @setCarrot)
      @$canvas.unbind('touchdown', @setCarrot)
      @cursor = null
      @instructions = 'Fertig :)'

  drawCarrot: ->
    @context.drawImage(@images.carrot, @carrot.x, @carrot.y)

  setCursor: (event) ->
    if ! @cursor
      return
    @cursor.x = event.offsetX - @cursor.image.width
    @cursor.y = event.offsetY - @cursor.image.height

  inCircle: (x1, y1, x2, y2, radius) ->
    sq = (x) -> x * x
    sq(x1 - x2) + sq(y1 - y2) < sq(radius)

  drawEye: (eye) ->
    @context.drawImage(@images.coal, eye.x, eye.y)

  drawImage: (el) ->
    @context.drawImage(el.image, el.x, el.y)
