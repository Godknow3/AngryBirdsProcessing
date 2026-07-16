
abstract class Box extends HitBody
{

  float m_hp;
  float m_maxHp;

  // Constructor
  Box(float x, float y, float w, float h)
  {
    super(HitBodyType.Box);
    
    m_w = w; m_h = h;
    makeBody(new Vec2(x, y), w, h);
    m_maxHp = getDurability();
    m_hp = m_maxHp;
    m_enableCollision = true;
  }

  boolean done()
  {
    return false;
  }

  void onVelocityCollision(float relativeSpeed, HitBody other)
  {
    if(relativeSpeed <= 0.75) return;

    float damage = relativeSpeed - 0.75;
    if(other != null && other.m_type == HitBodyType.Bird){
      Bird bird = (Bird)other;
      float birdPower = bird.getImpactPower();
      damage *= getBirdDamageMultiplier() * birdPower;
      damage = max(damage, m_maxHp * getMinimumBirdDamageRatio() * birdPower);
    }

    m_hp = max(0, m_hp - damage);
  }

  void onDisplay()
  {
    Vec2 pos = box2d.getBodyPixelCoord(m_body);
    float a = m_body.getAngle();
    float lifeRatio = constrain(m_hp / m_maxHp, 0, 1);
    int damageStage = lifeRatio > 0.75 ? 0 : lifeRatio > 0.5 ? 1 : lifeRatio > 0.25 ? 2 : 3;
    PImage texture = getTextures()[damageStage];

    pushMatrix();
    pushStyle();
    imageMode(CENTER);
    translate(pos.x, pos.y);
    rotate(-a);
    if(m_w >= m_h){
      image(texture, 0, 0, m_w, m_h);
    }else{
      rotate(HALF_PI);
      image(texture, 0, 0, m_h, m_w);
    }
    popStyle();
    popMatrix();
  }
  
  abstract FixtureDef getFixture();
  abstract float getDurability();
  abstract PImage[] getTextures();
  float getBirdDamageMultiplier() { return 1.0; }
  float getMinimumBirdDamageRatio() { return 0.35; }
  float getLinearDamping() { return 0.1; }
  float getAngularDamping() { return 0.7; }

  protected void makeBody(Vec2 center, float w, float h)
  {
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w / 2);
    float box2dH = box2d.scalarPixelsToWorld(h / 2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    FixtureDef fd = getFixture();
    fd.shape = sd;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.linearDamping = getLinearDamping();
    bd.angularDamping = getAngularDamping();
    bd.position.set(box2d.coordPixelsToWorld(center));

    m_body = box2d.createBody(bd);
    m_body.createFixture(fd);
    m_body.setUserData(this);
    //body.setMassFromShapes();
  }

}
