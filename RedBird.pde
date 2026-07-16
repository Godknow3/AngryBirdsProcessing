
class RedBird extends Bird
{

  // Constructor
  RedBird()
  {
    super(36 * sceneScale(), 36 * sceneScale());
  }

  // The classic red bird is a basic, relatively light bird. It is effective
  // at exposed pigs and unstable supports, but not at brute-force demolition.
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
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    // Parameters that affect physics
    fd.density = 19;
    fd.friction = 0.5;
    fd.restitution = 0.0;
    return fd;
  }
  
  void onEmit()
  {
    // No effect
  }

}
