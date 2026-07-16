
abstract class Bird extends HitBody
{

  PVector m_pos; float m_rotation;
  
  int m_timer;
  int m_timeImpact;
  int m_timeSlow;
  boolean m_deathEffectSpawned;

  // 创建小鸟
  Bird(float w, float h)
  {
    super(HitBodyType.Bird);
    
    m_pos = new PVector(); m_rotation = 0.0;
    m_w = w; m_h = h;

    m_timer = 0;
    m_timeImpact = -1;
    m_timeSlow = -1;
    m_deathEffectSpawned = false;
  }
  
  boolean done()
  {
    if(m_body == null) return false;

    Vec2 pixelPos = box2d.getBodyPixelCoord(m_body);
    float speed = m_body.getLinearVelocity().length();
    boolean shouldDie = pixelPos.x < -m_w || pixelPos.x > width + m_w ||
      pixelPos.y < -height || pixelPos.y > height + m_h;

    if(m_timeImpact >= 0){
      if(speed < 0.7){
        if(m_timeSlow < 0) m_timeSlow = m_timer;
        if(m_timer - m_timeSlow >= 15) shouldDie = true;
      }else{
        m_timeSlow = -1;
      }

      if(m_timer - m_timeImpact >= 90) shouldDie = true;
    }

    if(shouldDie && !m_deathEffectSpawned){
      spawnDeathVisual(pixelPos.x, pixelPos.y);
      m_deathEffectSpawned = true;
    }
    return shouldDie;
  }

  void onVelocityCollision(float relativeSpeed, HitBody other)
  {
    if(gone() && m_timeImpact < 0) m_timeImpact = m_timer;
  }

  void spawnDeathVisual(float x, float y) { }

    // 绘制小鸟
  void onDisplay()
  {
    m_timer++;
    
    pushMatrix();
    pushStyle();
      // 物理对象创建前使用初始坐标绘制
    if(m_body != null){
      Vec2 pos = box2d.getBodyPixelCoord(m_body);
      float a = m_body.getAngle();
      onDraw(pos.x, pos.y, -a);
    }else{
      onDraw(m_pos.x, m_pos.y, m_rotation);
    }
    popStyle();
    popMatrix();
  }

  abstract void onDraw(float x, float y, float a);
  abstract void onEmit();

  abstract Shape getShape();
  abstract FixtureDef getFixture();

  float getImpactPower() { return 1.0; }
  
  Vec2 getLaunchVelocity(Vec2 target)
  {
    Vec2 start = box2d.coordPixelsToWorld(m_pos.x, m_pos.y);
    Vec2 worldTarget = box2d.coordPixelsToWorld(target.x, target.y);
    Vec2 velocity = worldTarget.sub(start);
    velocity.mulLocal(SLINGSHOT_POWER);
    return velocity;
  }

  void go(Vec2 target)
  {
    makeBody(new Vec2(m_pos.x, m_pos.y), m_w, m_h);
    m_enableCollision = true;
    m_body.setLinearVelocity(getLaunchVelocity(target));
  }
  
  boolean gone()
  {
    return m_body != null;
  }

  protected void makeBody(Vec2 center, float w, float h)
  {
    Shape sd = getShape();

    // 设置碰撞形状
    FixtureDef fd = getFixture();
    fd.shape = sd;

    // 创建动态刚体
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    m_body = box2d.createBody(bd);
    m_body.createFixture(fd);
    m_body.setUserData(this);
  }

}
