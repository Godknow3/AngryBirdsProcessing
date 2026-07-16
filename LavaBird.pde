class LavaBird extends Bird
{
  boolean m_exploded;
  boolean m_meteorMode;
  int m_armedAt;
  int m_explodedAt;
  int m_meteorActivatedAt;
  ArrayList<PVector> m_trailPositions;
  ArrayList<Integer> m_trailAges;
  final int ARM_DELAY = 28;
  final int EXPLOSION_LINGER = 48;

  LavaBird()
  {
    super(40 * sceneScale(), 42 * sceneScale());
    m_exploded = false;
    m_meteorMode = false;
    m_armedAt = -1;
    m_explodedAt = -1;
    m_meteorActivatedAt = -1;
    m_trailPositions = new ArrayList<PVector>();
    m_trailAges = new ArrayList<Integer>();
  }

  void onDisplay()
  {
    if(m_meteorMode && m_body != null && m_armedAt < 0 && !m_exploded){
      Vec2 velocity = m_body.getLinearVelocity();
      velocity.x *= 0.992;
      velocity.y = max(velocity.y - 0.30, -21.0);
      m_body.setLinearVelocity(velocity);

      Vec2 pos = box2d.getBodyPixelCoord(m_body);
      if(m_timer % 3 == 0){
        m_trailPositions.add(new PVector(pos.x, pos.y));
        m_trailAges.add(0);
      }
      if(m_timer % 12 == 0) scene.burnLavaArea(this, pos.x, pos.y, 0.45);
    }
    drawMeteorTrail();
    super.onDisplay();
    int delay = m_meteorMode ? 18 : ARM_DELAY;
    if(m_armedAt >= 0 && !m_exploded && m_timer - m_armedAt >= delay) explodeNow();
  }

  void drawMeteorTrail()
  {
    pushStyle();
    noStroke();
    for(int i = m_trailPositions.size() - 1; i >= 0; i--){
      int age = m_trailAges.get(i) + 1;
      if(age >= 28){
        m_trailPositions.remove(i);
        m_trailAges.remove(i);
        continue;
      }
      m_trailAges.set(i, age);
      PVector pos = m_trailPositions.get(i);
      float fade = 1.0 - (float)age / 28;
      float size = (16 + age * 1.1) * sceneScale();
      fill(235, 48, 15, 150 * fade);
      ellipse(pos.x, pos.y, size, size);
      fill(255, 196, 38, 190 * fade);
      ellipse(pos.x, pos.y, size * 0.48, size * 0.48);
    }
    popStyle();
  }

  boolean done()
  {
    if(m_body == null) return false;

    Vec2 pixelPos = box2d.getBodyPixelCoord(m_body);
    boolean outside = pixelPos.x < -m_w || pixelPos.x > width + m_w ||
      pixelPos.y < -height || pixelPos.y > height + m_h;
    if(outside) return true;

    if(m_exploded) return m_timer - m_explodedAt >= EXPLOSION_LINGER;
    if(m_armedAt >= 0) return false;
    return super.done();
  }

  void onDraw(float x, float y, float a)
  {
    boolean charging = !gone() && scene != null && scene.m_dragging &&
      !scene.m_birds.isEmpty() && scene.m_birds.get(0) == this;
    boolean armed = m_armedAt >= 0 && !m_exploded;
    boolean meteor = m_meteorMode && !m_exploded;
    boolean flying = gone() && !m_exploded;
    int activeDelay = meteor ? 18 : ARM_DELAY;
    float armedProgress = armed ? constrain((float)(m_timer - m_armedAt) / activeDelay, 0, 1) : 0;
    float pulse = armed ? 1.0 + 0.10 * sin(m_timer * 0.9) : 1.0;
    float bodyScale = (charging ? 1.12 : meteor ? 1.28 : 1.0) * pulse;

    pushMatrix();
    pushStyle();
    translate(x, y);
    rotate(a);
    scale(bodyScale * sceneScale() * 0.75);
    noStroke();

    if(m_exploded){
      float lingerProgress = constrain((float)(m_timer - m_explodedAt) / EXPLOSION_LINGER, 0, 1);
      fill(45, 34, 31, 220 * (1.0 - lingerProgress));
      ellipse(0, 8, 38, 34);
      fill(255, 92, 20, 180 * (1.0 - lingerProgress));
      ellipse(0, 6, 18, 15);
      popStyle();
      popMatrix();
      return;
    }

    if(charging){
      for(int ring = 3; ring >= 1; ring--){
        fill(255, 190, 20, 22);
        ellipse(0, 0, m_w + ring * 13, m_h + ring * 13);
      }
    }

    if(meteor){
      noStroke();
      fill(255, 72, 18, 75);
      ellipse(0, -34, 40, 72);
      fill(255, 190, 35, 105);
      ellipse(0, -28, 25, 54);
      fill(255, 245, 175, 90);
      ellipse(0, 2, 66, 66);

      int pulseAge = m_timer - m_meteorActivatedAt;
      if(pulseAge >= 0 && pulseAge < 20){
        float pulseProgress = (float)pulseAge / 20;
        noFill();
        stroke(255, 205, 48, 220 * (1.0 - pulseProgress));
        strokeWeight(max(2, 7 * (1.0 - pulseProgress)));
        float pulseSize = lerp(60, 180, pulseProgress);
        ellipse(0, 0, pulseSize, pulseSize);
      }
    }

    drawFuse(charging || armed, flying);

    // 绘制上窄下宽的熔岩身体
    int normalBody = charging ? color(255, 156, 24) : color(239, 91, 25);
    int activeBody = meteor ? color(255, 205, 45) : normalBody;
    fill(armed ? lerpColor(activeBody, color(255, 250, 185), armedProgress) : activeBody);
    ellipse(0, 3, 49, 51);
    ellipse(0, 11, 54, 43);

    // 绘制熔岩裂纹与蓄力亮光
    strokeWeight(3);
    stroke(armed ? lerpColor(color(255, 210, 45), color(255), armedProgress) :
      charging ? color(255, 210, 45) : color(145, 35, 28));
    noFill();
    line(-20, -5, -13, -1);
    line(-13, -1, -17, 6);
    line(17, -9, 11, -3);
    line(11, -3, 17, 3);
    line(21, 12, 14, 14);
    line(-19, 16, -12, 12);

    // 绘制腹部
    noStroke();
    fill(250, 226, 166);
    ellipse(0, 18, 35, 25);

    // 绘制眼睛
    fill(255);
    ellipse(-9, -5, 19, 18);
    ellipse(9, -5, 19, 18);
    fill(25);
    ellipse(-5, -4, 5, 6);
    ellipse(5, -4, 5, 6);

    // 绘制眉毛
    fill(18);
    quad(-24, -18, -3, -11, -5, -5, -25, -12);
    triangle(-5, -11, 1, -8, -4, -5);
    quad(24, -18, 3, -11, 5, -5, 25, -12);
    triangle(5, -11, -1, -8, 4, -5);

    // 绘制鸟喙
    fill(92, 98, 102);
    triangle(-9, 2, 10, 2, 1, 17);
    fill(35, 40, 42);
    triangle(0, 15, 4, 11, 5, 16);

    popStyle();
    popMatrix();
  }

  void drawFuse(boolean charging, boolean flying)
  {
    int fuseColor = charging ? color(255, 225, 35) : color(145, 40, 32);
    fill(fuseColor);
    triangle(-13, -22, -11, -43, -3, -23);
    triangle(-5, -24, 0, -47, 6, -23);
    triangle(4, -23, 13, -42, 14, -20);

    if(charging || flying){
      fill(255, 220);
      ellipse(-6, -50, 7, 7);
      ellipse(6, -55, 5, 5);
      ellipse(-1, -62, 4, 4);
    }
  }

  Shape getShape()
  {
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(m_w / 2);
    return cs;
  }

  FixtureDef getFixture()
  {
    FixtureDef fd = new FixtureDef();
    fd.density = 135;
    fd.friction = 2.5;
    fd.restitution = 0.05;
    return fd;
  }

  void onEmit()
  {
    if(m_body == null || m_exploded || m_armedAt >= 0 || m_meteorMode) return;
    m_meteorMode = true;
    m_meteorActivatedAt = m_timer;
    Vec2 pos = box2d.getBodyPixelCoord(m_body);
    scene.lavaAirBurst(this, pos.x, pos.y);
    Vec2 velocity = m_body.getLinearVelocity();
    velocity.x *= 1.08;
    velocity.y -= 4.0;
    m_body.setLinearVelocity(velocity);
  }

  void explodeNow()
  {
    if(m_exploded || m_body == null) return;
    m_exploded = true;
    m_explodedAt = m_timer;
    Vec2 pos = box2d.getBodyPixelCoord(m_body);
    float powerScale = m_meteorMode ? 1.7 : 1.0;
    scene.explodeLavaBird(this, pos.x, pos.y, powerScale);
    spawnLavaBlastEffect(this, pos.x, pos.y, powerScale);
    m_body.setLinearVelocity(new Vec2(0, 0));
    m_body.setAngularVelocity(0);
    m_body.setActive(false);
  }

  void onVelocityCollision(float relativeSpeed, HitBody other)
  {
    super.onVelocityCollision(relativeSpeed, other);
    if(m_armedAt < 0 && !m_exploded){
      m_armedAt = m_timer;
      Vec2 velocity = m_body.getLinearVelocity();
      velocity.mulLocal(0.55);
      m_body.setLinearVelocity(velocity);
    }
  }

  float getImpactPower() { return 1.6; }

  void spawnDeathVisual(float x, float y)
  {
    if(!m_exploded){
      spawnLavaBlastEffect(this, x, y, m_meteorMode ? 1.7 : 1.0);
    }
  }
}
