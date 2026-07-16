class StoneBall extends Box
{
  StoneBall(float x, float y, float size)
  {
    super(x, y, size, size);
    // 巨石受支撑移动或碰撞后才开始运动
    m_body.setAwake(false);
  }

  float getDurability() { return 50.0; }
  PImage[] getTextures() { return imgStoneBalls; }
  float getBirdDamageMultiplier() { return 0.35; }
  float getMinimumBirdDamageRatio() { return 0.1; }

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
    image(imgStoneBalls[damageStage], 0, 0, m_w, m_h);
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
    bodyDef.bullet = true;
    bodyDef.position.set(box2d.coordPixelsToWorld(center));
    m_body = box2d.createBody(bodyDef);
    m_body.createFixture(fixture);
    m_body.setUserData(this);
  }

  FixtureDef getFixture()
  {
    FixtureDef fixture = new FixtureDef();
    fixture.density = 180;
    fixture.friction = 0.3;
    fixture.restitution = 0.0;
    return fixture;
  }
}
