
class Snowfall
  angle: 0
  particles: []
  height: 0
  width: 0
  max_particles: 25

  constructor: (@ctx) ->
    _.bindAll(@)
    #canvas init
    if(!@ctx)
      canvas = document.getElementById("canvas")
      #canvas dimensions
      @height = window.innerWidth
      @height = window.innerHeight
      canvas.width = @width
      canvas.height = @height
      @ctx = canvas.getContext("2d")
    else
      @width  = @ctx.canvas.width
      @height = @ctx.canvas.height
    #snowflake particles
    @addParticle() for i in [0..@max_particles]
    #setInterval(@draw, 33)


  addParticle: () ->
    @particles.push({
      x: Math.random()*@width, #x-coordinate
      y: Math.random()*@height, #y-coordinate
      r: Math.random()*4+1, #radius
      d: Math.random()*@max_particles #density
    })

  #Lets draw the flakes
  draw: () ->
    @ctx.fillStyle = "rgba(255, 255, 255, 0.8)"
    @ctx.beginPath()
    halfpi = Math.PI/2
    pi = Math.PI*2
    for i in [0..@max_particles]
      p = @particles[i]
      @ctx.moveTo(p.x, p.y)
      @ctx.arc(p.x, p.y, p.r, 0, pi, true)
    @ctx.fill()
    @ctx.strokeStyle = 'rgba(100,100,155, 0.6)'
    for i in [0..@max_particles]
      p = @particles[i]
      @ctx.beginPath()
      @ctx.arc(p.x, p.y, p.r, 0, halfpi)
      @ctx.stroke()


  #to move the snowflakes
  #angle will be an ongoing incremental flag. Sin and Cos functions will be applied to it to create vertical and horizontal movements of the flakes
  update: (dt) ->
    s = dt * 300
    for i in [0..@max_particles]
      p = @particles[i]
      #Updating X and Y coordinates
      #We will add 1 to the cos to prevent negative values which will lead flakes to move upwards
      #Every particle has its own density which can be used to make the downward movement different for each flake
      #Lets make it more random by adding in the radius
      p.y += Math.cos(@angle+p.d) + p.r/2
      p.x += Math.sin(@angle) + dt * 10 * p.r

      #Sending flakes back from the top when it exits
      #Lets make it a bit more organic and let flakes enter from the left and right also.
      if(p.x > @widthW+5 || p.x < -5 || p.y > @height)
        if(i%3 > 0) #66.67% of the flakes
          @particles[i] = {x: Math.random()*@width, y: -10, r: p.r, d: p.d}
        else
          #If the flake is exitting from the right
          if(Math.sin(@angle) > 0)
            #Enter from the left
            @particles[i] = {x: -5, y: Math.random()*@heightH, r: p.r, d: p.d}
          else
            #Enter from the right
            @particles[i] = {x: @widthW+5, y: Math.random()*@heightH, r: p.r, d: p.d}

