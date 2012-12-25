
class Snowman
  dt: 1000 / 60
  last_time: Date.now()
  balls: []
  schal: false
  eyes: []
  instructions: false
  carrot: false
  cursor: false
  animals: []
  score: 0
  scores: []

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
      schal: @loadImage('schal.png')
      hat: @loadImage('hut.png')
      animals:
        hoppel: @loadImage('hoppel.png')
        hoppel2: @loadImage('hoppel2.png')
    @animals = []
    @placeAnimals(4)
    @update()
    @draw()
    @cursor = false
    @

  loadImage: (filename) ->
    image = new Image()
    image.src = filename + '?' + Date.now()
    return image

  placeAnimals: (num) ->
    for i in [0..num]
      do (i) =>
        x =  Math.floor(Math.random() * @canvas.width) * 0.8 + @canvas.width * 0.1
        y = Math.floor(Math.random() * @canvas.height*0.5) + @canvas.height* 0.5
        @animals.push({
          x: x,
          y: y,
          scale: (y*y) / (@canvas.height * @canvas.height),
          image: _.values(@images.animals)[i % _.values(@images.animals).length]
        })
  draw: () ->
    @drawGarden()
    @snowfall.draw()
    @drawImage(animal) for animal in @animals
    ball.draw() for ball in @balls
    @drawImage(@schal) if @schal
    @drawImage(@hat) if @hat
    @drawEye(eye) for eye in @eyes
    @drawText(@instructions, 10, 40)
    if @carrot
      @drawCarrot()
    if @cursor
      @context.drawImage(@cursor.image, @cursor.x, @cursor.y)
    @drawText('Alex der Schneemann', 10, 20, '#000000', '20px sans-serif')
    @drawText(@score + ' Punkte', @canvas.width - 120, 20, '#000000', '20px sans-serif')
    @drawText(score, @canvas.width - 120, 35 + i * 20, '#000000', '12px sans-serif') for score, i in @scores
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

  addScore: (score) ->
    score = Math.floor(score)
    return if score == 0
    @score += score
    @scores.push score

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
    @addScore(@ball.radius)
    if @balls.length > 1
      last = @balls[@balls.length - 2]
      # subtract score if not on a line
      @addScore(- Math.abs(@ball.x - last.x))
      # subtract if not touching
      @addScore(- Math.abs((last.y - @ball.y) - (@ball.radius + last.radius)) + @ball.radius/4)
      @addScore(last.radius - @ball.radius)
    @ball.stop()
    @ball = null
    @instructions = 'Und noch eine Kugel'
    if @balls.length >= 3
      @placeSchal()
      @$canvas.unbind('mousedown', @startBall)
      @$canvas.unbind('touchdown', @startBall)
      @startEyes()

  placeSchal: () ->
    b3 = @balls[@balls.length - 1]
    b2 = @balls[@balls.length - 2]
    @schal = {
      x: b3.x - @images.schal.width / 2,
      y: b3.y + b3.radius - b3.radius / 6,
      scale: @images.schal.width / b3.radius * 1.2,
      image: @images.schal
    }
    @hat = {
      x: b3.x - @images.hat.width / 2,
      y: b3.y - b3.radius * 0.7 - @images.hat.height,
      scale: @images.hat.width / b3.radius,
      image: @images.hat
    }

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
        #@addScore(((@eyes.length * last.radius/2) + last.radius/4) - (last.x - event.offsetX))
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
    @context.save()
    @context.translate(el.x, el.y)
    if el.scaleX && el.scaleY
      @context.scale(el.scaleX, el.scaleY)
    if el.scale
      @context.scale(el.scale, el.scale)
    @context.drawImage(el.image, 0, 0)
    @context.restore()
