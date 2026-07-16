class RollingLog extends Box
{
  boolean m_birdBoosted;

  RollingLog(float x, float y, float size)
  {
    super(x, y, size, size);
    m_birdBoosted = false;
  }

  float getDurability() { return 30.0; }
  PImage[] getTextures() { return imgWoodLogs; }
  float getBirdDamageMultiplier() { return 0.6; }
  float getMinimumBirdDamageRatio() { return 0.25; }

  void onVelocityCollision(float relativeSpeed, HitBody other)
  {
    super.onVelocityCollision(relativeSpeed, other);
    if(m_birdBoosted || other == null || other.m_type != HitBodyType.Bird || other.m_body == null) return;

    Vec2 birdVelocity = other.m_body.getLinearVelocity();
    float birdSpeed = birdVelocity.length();
    if(birdSpeed < 0.1) return;

    Vec2 direction = new Vec2(birdVelocity.x / birdSpeed, birdVelocity.y / birdSpeed);
    float boostSpeed = constrain(relativeSpeed * 0.32, 2.8, 5.0);
    Vec2 impulse = direction.mul(m_body.getMass() * boostSpeed);
    m_body.applyLinearImpulse(impulse, m_body.getWorldCenter(), true);
    m_birdBoosted = true;
  }

  void onDisplay()
  {
    Vec2 pos = box2d.getBodyPixelCoord(m_body);
    float a = m_body.getAngle();
    float lifeRatio = constrain(m_hp / m_maxHp, 0, 1);
    int damageStage = lifeRatio > 0.75 ? 0 : lifeRatio > 0.5 ? 1 : lifeRatio > 0.25 ? 2 : 3;

    pushMatrix();
    pushStyle();
    imageMode(CENTER);
    translate(pos.x, pos.y);
    rotate(-a);
    image(imgWoodLogs[damageStage], 0, 0, m_w, m_h);
    popStyle();
    popMatrix();
  }

  protected void makeBody(Vec2 center, float w, float h)
  {
    CircleShape shape = new CircleShape();
    shape.m_radius = box2d.scalarPixelsToWorld(min(w, h) / 2);

    FixtureDef fixture = getFixture();
    fixture.shape = shape;

    BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.position.set(box2d.coordPixelsToWorld(center));
    m_body = box2d.createBody(bodyDef);
    m_body.createFixture(fixture);
    m_body.setUserData(this);
  }

  FixtureDef getFixture()
  {
    FixtureDef fixture = new FixtureDef();
    // 滚木保留足够动量，用于撞开猪群和冰门
    fixture.density = 26;
    fixture.friction = 1.2;
    fixture.restitution = 0.05;
    return fixture;
  }
}
