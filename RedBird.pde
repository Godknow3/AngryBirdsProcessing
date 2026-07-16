
class RedBird extends Bird
{

  // 创建红鸟
  RedBird()
  {
    super(36 * sceneScale(), 36 * sceneScale());
  }

    // 红鸟较轻，适合攻击暴露目标和不稳定支撑
  float getImpactPower() { return 0.31; }

  void spawnDeathVisual(float x, float y)
  {
    spawnBirdDeathEffect(x, y);
  }

  void onDraw(float x, float y, float a)
  {
    imageMode(CENTER);
    ellipseMode(CENTER);
    pushMatrix();
    translate(x, y);
    rotate(a);
    image(m_timeImpact >= 0 ? imgRedBirdDeath : imgRedBird, 0, 0, m_w, m_h);
    popMatrix();
  }
  
  Shape getShape()
  {
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(m_w / 2);
    return cs;
  }

  FixtureDef getFixture()
  {
    // 设置碰撞形状
    FixtureDef fd = new FixtureDef();
    // 设置物理参数
    fd.density = 19;
    fd.friction = 0.5;
    fd.restitution = 0.0;
    return fd;
  }
  
  void onEmit()
  {
    // 红鸟没有特殊技能
  }

}
