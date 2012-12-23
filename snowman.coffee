class Snowman

  load: () ->
    _.bind(@)
    Crafty.init(400, 336);
    Crafty.scene "game", () =>
      @garden = @createGarden()
      @ball = @createBall()
      Crafty.e("2D, Canvas, Text").attr({ w: 100, h: 20, x: 10, y: 0 }).text("Alex der Schneemann").textColor('#222222');
      Crafty.bind('mousedown', @startBall)
      @
    Crafty.scene("game")
    @

  startBall: (event) ->
    @drawBall = true
  moveBall: (event) ->
    if @drawBall #&& @ball
      console.log(@)
      Crafty.e('Particles').attr({x: event.realX, y: event.realY, angle: 200}).particles(
        {x: event.realX, y: event.realY, duration: 1, gravity: { x: 0, y: 0.01 },
        startColour: [255, 255, 255, 1], endColour: [250, 250, 255, 1],
        startColourRandom: [0, 0, 5, 0], endColourRandom: [0, 0, 20, 0],
        angle: 180
        })

      window.snowman.ball.x = event.realX - window.snowman.ball.w / 2
      window.snowman.ball.y = event.realY - window.snowman.ball.h / 2
      window.snowman.ball.h += 1
      window.snowman.ball.w += 1
      window.snowman.ball.draw()
  endBall: (event) ->
    window.snowman.ball = window.snowman.createBall()
    @drawBall = false

  createBall: () ->
    return Crafty.e('2D, Canvas, Circle, Color')
      .color('#FFFFFF') # 00
      #.bind 'Draw', (e) ->
        #e.ctx.fillStyle = '#FFFFFFFF'
        # e.ctx.fillRect(e.pos._x, e.pos._y, e.pos._w, e.pos._h)

  createGarden: ->
    Crafty.e('2D, Canvas, Input, Mouse, Color')
      .attr({w: Crafty.viewport.width, h: Crafty.viewport.height})
      .color('#AAAAAA')
      .areaMap(
        [0,0],
        [Crafty.viewport.width, 0],
        [Crafty.viewport.width, Crafty.viewport.height],
        [0, Crafty.viewport.height]
     )
     .bind('MouseDown', @startBall)
     .bind('MouseUp', @endBall)
     .bind('MouseMove', @moveBall)
     .bind('TouchDown', @startBall)

