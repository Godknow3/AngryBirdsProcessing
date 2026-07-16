
class NormalPig extends Pig
{

  // Constructor
  NormalPig(float x, float y)
  {
    this(x, y, 52);
  }

  NormalPig(float x, float y, float size)
  {
    this(x, y, size, PIG_MEDIUM);
  }

  NormalPig(float x, float y, float size, int pigSizeType)
  {
    super(x, y, size, size, pigSizeType == PIG_SMALL ? 10.0 : 30.0);
    m_pigSizeType = pigSizeType;
    m_maxHp = pigSizeType == PIG_SMALL ? 2.0 : pigSizeType == PIG_BIG ? 6.0 : 4.0;
    m_hp = m_maxHp;
  }

  int m_pigSizeType;

  // Drawing the box
  void onDraw(float x, float y, float a)
  {
    imageMode(CENTER);
    pushMatrix();
    translate(x, y);
    rotate(a);
    fill(0, 200, 0);
    stroke(0, 100, 0);
    if(isDying()){
      image(imgPigDying, 0, 0, m_w, m_h);
    }else{
      PImage[] sprites = m_pigSizeType == PIG_SMALL ? imgPigSmall :
        m_pigSizeType == PIG_BIG ? imgPigBig : imgPigMedium;
      int damageStage = m_hp <= m_maxHp * 0.5 ? 1 : 0;
      image(sprites[damageStage], 0, 0, m_w, m_h);
    }
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
    fd.density = m_density;
    fd.friction = 3.0;
    fd.restitution = 0.0;
    return fd;
  }

}
