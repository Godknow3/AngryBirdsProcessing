
class Scene
{

  ArrayList<Box>      m_boxes;
  ArrayList<Boundary> m_boundaries;
  ArrayList<HitBody>  m_obstacles;
  
  ArrayList<Bird>     m_birds;
  ArrayList<Pig>      m_pigs;
  
  PVector             m_catapultCenter;
  PVector             m_catapultInner;
  PVector             m_catapultOuter;
  
  boolean             m_dragging;
  boolean             m_levelBodiesFrozen;

  Scene()
  {
    m_boundaries = new ArrayList<Boundary>();
    m_boundaries.add(new Boundary(width / 2, -10, width, 20));  //top
    m_boundaries.add(new Boundary(width / 2, groundY + 10, width, 20));  //playfield floor
    m_boundaries.add(new Boundary(-10, height / 2, 20, height));  //left
    m_boundaries.add(new Boundary(width + 10, height / 2, 20, height)); //right
    
    m_boxes = new ArrayList<Box>();
    m_obstacles = new ArrayList<HitBody>();
    m_birds = new ArrayList<Bird>();
    m_pigs = new ArrayList<Pig>();

    float s = sceneScale();
    // The fork is roughly 55 px below the top of the 201 px catapult art.
    // Keep the physics launch point at that fork, not at the sprite centre.
    m_catapultCenter = new PVector(width * 0.21, groundY - 145 * s);
    m_catapultInner = new PVector(m_catapultCenter.x + 17 * s, m_catapultCenter.y);
    m_catapultOuter = new PVector(m_catapultCenter.x - 17 * s, m_catapultCenter.y);

    m_dragging = false;
    m_levelBodiesFrozen = false;
  }
  
  void addPig(Pig pig) { m_pigs.add(pig); }
  void addBox(Box box) { m_boxes.add(box); }
  void addObstacle(HitBody obstacle) { m_obstacles.add(obstacle); }

  void explodeLavaBird(LavaBird source, float pixelX, float pixelY, float powerScale)
  {
    Vec2 origin = box2d.coordPixelsToWorld(pixelX, pixelY);
    float radiusMultiplier = 1.0 + (powerScale - 1.0) * 0.45;
    float radius = box2d.scalarPixelsToWorld(195 * sceneScale() * radiusMultiplier);

    for(Box box : m_boxes) applyExplosionToBody(box, source, origin, radius, powerScale);
    for(Pig pig : m_pigs) applyExplosionToBody(pig, source, origin, radius, powerScale);
  }

  void applyExplosionToBody(HitBody target, LavaBird source, Vec2 origin, float radius, float powerScale)
  {
    if(target.m_body == null || !target.m_body.isActive()) return;
    Vec2 center = target.m_body.getWorldCenter();
    Vec2 delta = center.sub(origin);
    float distance = delta.length();
    if(distance >= radius) return;

    float falloff = 1.0 - distance / radius;
    if(distance < 0.001) delta.set(0, 1);
    else delta.mulLocal(1.0 / distance);

    float velocityKick = 17.0 * powerScale * falloff;
    Vec2 impulse = delta.mul(target.m_body.getMass() * velocityKick);
    target.m_body.applyLinearImpulse(impulse, center, true);
    target.onVelocityCollision((11.0 + 18.0 * falloff) * powerScale, source);
  }

  void lavaAirBurst(LavaBird source, float pixelX, float pixelY)
  {
    Vec2 origin = box2d.coordPixelsToWorld(pixelX, pixelY);
    float radius = box2d.scalarPixelsToWorld(105 * sceneScale());
    for(Box box : m_boxes) applyAirBurstToBody(box, source, origin, radius);
    for(Pig pig : m_pigs) applyAirBurstToBody(pig, source, origin, radius);
  }

  void applyAirBurstToBody(HitBody target, LavaBird source, Vec2 origin, float radius)
  {
    if(target.m_body == null || !target.m_body.isActive()) return;
    Vec2 center = target.m_body.getWorldCenter();
    Vec2 delta = center.sub(origin);
    float distance = delta.length();
    if(distance >= radius) return;
    float falloff = 1.0 - distance / radius;
    if(distance < 0.001) delta.set(0, 1);
    else delta.mulLocal(1.0 / distance);
    Vec2 impulse = delta.mul(target.m_body.getMass() * 7.0 * falloff);
    target.m_body.applyLinearImpulse(impulse, center, true);
    target.onVelocityCollision(1.5 + 2.5 * falloff, source);
  }

  void burnLavaArea(LavaBird source, float pixelX, float pixelY, float powerScale)
  {
    Vec2 origin = box2d.coordPixelsToWorld(pixelX, pixelY);
    float radius = box2d.scalarPixelsToWorld(105 * sceneScale() * powerScale);
    for(Box box : m_boxes) applyLavaBurn(box, source, origin, radius, powerScale);
    for(Pig pig : m_pigs) applyLavaBurn(pig, source, origin, radius, powerScale);
  }

  void applyLavaBurn(HitBody target, LavaBird source, Vec2 origin, float radius, float powerScale)
  {
    if(target.m_body == null || !target.m_body.isActive()) return;
    float distance = target.m_body.getWorldCenter().sub(origin).length();
    if(distance >= radius) return;
    float falloff = 1.0 - distance / radius;
    target.onVelocityCollision((2.0 + 3.0 * falloff) * powerScale, source);
  }

  void freezeLevelBodies()
  {
    m_levelBodiesFrozen = true;
    for(Box box : m_boxes){
      box.m_body.setType(BodyType.STATIC);
      box.m_body.setAwake(false);
    }
    for(Pig pig : m_pigs){
      pig.m_body.setType(BodyType.STATIC);
      pig.m_body.setAwake(false);
    }
  }

  void releaseLevelBodies()
  {
    for(Box box : m_boxes){
      box.m_body.setType(BodyType.DYNAMIC);
      box.m_body.setAwake(false);
    }
    for(Pig pig : m_pigs){
      pig.m_body.setType(BodyType.DYNAMIC);
      pig.m_body.setAwake(false);
    }
    m_levelBodiesFrozen = false;
  }
  int birdCount() { return m_birds.size(); }
  int pigCount() { return m_pigs.size(); }
  int unusedBirdCount()
  {
    int count = 0;
    for(Bird bird : m_birds) if(!bird.gone()) count++;
    return count;
  }
  boolean isWon() { return m_pigs.isEmpty(); }
  boolean isLost() { return m_birds.isEmpty() && !m_pigs.isEmpty(); }

  void addBird(Bird bird)
  {
    m_birds.add(bird); int i = m_birds.size() - 1;
    if(i == 0){
      bird.m_pos.set(m_catapultCenter);
    }else{
      bird.m_pos.set(m_catapultCenter.x - i * 36 * sceneScale(), groundY - 20 * sceneScale());
    }
  }

  void onDraw()
  {
      drawEnvironment();

      pushMatrix();
      pushStyle();
      if(m_levelBodiesFrozen && shotLaunched && !m_birds.isEmpty()){
        Bird launchedBird = m_birds.get(0);
        if(launchedBird.gone()){
          Vec2 birdPos = box2d.getBodyPixelCoord(launchedBird.m_body);
          float s = sceneScale();
          float towerX = width * 0.75;
          boolean insideTowerX = birdPos.x > towerX - 230 * s && birdPos.x < towerX + 200 * s;
          boolean insideTowerY = birdPos.y > groundY - 430 * s && birdPos.y < groundY + 20 * s;
          if(insideTowerX && insideTowerY) releaseLevelBodies();
        }
      }
      // We must always step through time!
      box2d.step();
    
      // Boxes that leave the screen, we delete them
      // (note they have to be deleted from both the box2d world and our list
    
      for(Boundary b : m_boundaries){
        b.onUpdate();
      }

      for(HitBody obstacle : m_obstacles){
        obstacle.onUpdate();
      }
    
      for(int i = m_boxes.size() - 1; i >= 0; i--){
        Box b = m_boxes.get(i);
        b.onUpdate();
        if(b.onIntrospect()){
          m_boxes.remove(i);
        }
      }
        
      for(int i = m_pigs.size() - 1; i >= 0; i--){
        Pig p = m_pigs.get(i);
        p.onUpdate();
        if(p.onIntrospect()){
          m_pigs.remove(i);
        }
      }

      PVector birdJoint = new PVector(-1.0, -1.0);
      if(!m_birds.isEmpty()){
        Bird b = m_birds.get(0);
        if(!b.gone()){
          birdJoint.set(b.m_pos.x <= m_catapultCenter.x ? b.m_pos.x - b.m_w / 2 : b.m_pos.x + b.m_w / 2, b.m_pos.y);
        }
      }
      
      imageMode(CENTER);
      float s = sceneScale();
      image(imgCatapultRight, m_catapultCenter.x, groundY - 100 * s, 92 * s, 201 * s);

      if(!m_birds.isEmpty() && m_dragging && !m_birds.get(0).gone()){
        drawTrajectory(m_birds.get(0));
      }

      if(birdJoint.x >= 0 && birdJoint.y >= 0){
        strokeWeight(5);
        stroke(0);
        line(birdJoint.x, birdJoint.y, m_catapultInner.x, m_catapultInner.y);
      }
      
      for(int i = m_birds.size() - 1; i >= 0; i--){
        Bird b = m_birds.get(i);
        b.onUpdate();
        if(b.onIntrospect()){
          m_birds.remove(i);
          if(!m_birds.isEmpty()){
            Bird nextBird = m_birds.get(0);
            nextBird.m_pos.set(m_catapultCenter.x, m_catapultCenter.y);
          }
        }
      }

      if(birdJoint.x >= 0 && birdJoint.y >= 0){
        strokeWeight(5);
        stroke(0);
        line(birdJoint.x, birdJoint.y, m_catapultOuter.x, m_catapultOuter.y);
      }

      imageMode(CENTER);
      image(imgCatapultLeft, m_catapultCenter.x, groundY - 100 * s, 92 * s, 201 * s);

      popStyle();
      popMatrix();
  }
  
  void onCursorDragged(float x, float y)
  {
    if(levelFinishedAt >= 0) return;
    if(!m_birds.isEmpty()){
      Bird b = m_birds.get(0);
      if(!b.gone() && b.m_pos.x - b.m_w / 2 < x && x < b.m_pos.x + b.m_w / 2 && b.m_pos.y - b.m_h / 2 < y && y < b.m_pos.y + b.m_h / 2){
        if(!m_dragging) m_dragging = true;
      }
      if(m_dragging){
        float s = sceneScale();
        float radiusX = 70 * s;
        float radiusY = 45 * s;
        float offsetX = x - m_catapultCenter.x;
        float offsetY = y - m_catapultCenter.y;
        float ellipseDistance = sq(offsetX / radiusX) + sq(offsetY / radiusY);

        if(ellipseDistance > 1.0){
          float clampScale = 1.0 / sqrt(ellipseDistance);
          offsetX *= clampScale;
          offsetY *= clampScale;
        }
        b.m_pos.set(m_catapultCenter.x + offsetX, m_catapultCenter.y + offsetY);
      }
    }
  }
  
  void onCursorReleased(float x, float y)
  {
    if(levelFinishedAt >= 0) return;
    if(m_dragging){
      m_dragging = false;
      if(!m_birds.isEmpty()){
        Bird b = m_birds.get(0);
        if(!b.gone()){
          shotLaunched = true;
          shotsUsed++;
          b.go(new Vec2(m_catapultCenter.x, m_catapultCenter.y));
        }
      }
    }
  }

  // Step the preview with the same velocity, gravity and timestep as Box2D.
  void drawTrajectory(Bird bird)
  {
    float dx = m_catapultCenter.x - bird.m_pos.x;
    float dy = m_catapultCenter.y - bird.m_pos.y;
    float dragDistance = sqrt(dx * dx + dy * dy);
    if(dragDistance < 2) return;

    Vec2 position = box2d.coordPixelsToWorld(bird.m_pos.x, bird.m_pos.y);
    Vec2 velocity = bird.getLaunchVelocity(new Vec2(m_catapultCenter.x, m_catapultCenter.y));
    Vec2 gravity = new Vec2(0, WORLD_GRAVITY_Y);
    float dotSize = max(3, 7 * sceneScale());

    pushStyle();
    noStroke();
    int dotIndex = 0;
    for(int frame = 1; frame <= 120; frame++){
      velocity.x += gravity.x * PHYSICS_TIME_STEP;
      velocity.y += gravity.y * PHYSICS_TIME_STEP;
      position.x += velocity.x * PHYSICS_TIME_STEP;
      position.y += velocity.y * PHYSICS_TIME_STEP;

      if(frame % 4 == 0){
        Vec2 pixelPos = box2d.coordWorldToPixels(position);
        if(pixelPos.x < 0 || pixelPos.x > width || pixelPos.y < 0 || pixelPos.y > groundY) break;
        fill(255, max(45, 245 - dotIndex * 8));
        ellipse(pixelPos.x, pixelPos.y, dotSize, dotSize);
        dotIndex++;
      }
    }
    popStyle();
  }

}
