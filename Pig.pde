
abstract class Pig extends HitBody
{
  
  int m_timer;
  int m_timeDying;
  int m_durationDying;
  float m_hp;
  float m_maxHp;
  float m_density;
  boolean m_physicsDisabled;
  boolean m_scoreAwarded;

  final float MIN_DAMAGE_SPEED = 1.0;
  int m_spawnProtectionFrames = 45;

  // Constructor
  Pig(float x, float y, float w, float h, float density)
  {
    super(HitBodyType.Pig);
    
    m_w = w; m_h = h;
    m_density = density;
    m_enableCollision = true;

    makeBody(new Vec2(x, y), m_w, m_h);

    m_timer = 0;
    m_timeDying = -1; m_durationDying = 30;
    m_physicsDisabled = false;
    m_scoreAwarded = false;
  }
  
  boolean isDying(){return m_timeDying >= 0;}
  
  void onVelocityCollision(float relativeSpeed, HitBody other)
  {
    if(isDying() || relativeSpeed <= MIN_DAMAGE_SPEED) return;
    if(!shotLaunched && m_timer < m_spawnProtectionFrames) return;

    m_hp -= relativeSpeed;
    if(m_hp <= 0){
      m_hp = 0;
      awardDeathScore();
      m_timeDying = m_timer;
      m_enableCollision = false;
    }
  }
  
  boolean done()
  {
    boolean hasDone = false;
    
    Vec2 pixelPos = box2d.getBodyPixelCoord(m_body);
    if(pixelPos.x < -m_w || pixelPos.x > width + m_w ||
       pixelPos.y < -height || pixelPos.y > height + m_h){
      m_hp = 0;
      awardDeathScore();
      if(m_timeDying < 0) m_timeDying = m_timer;
      m_enableCollision = false;
    }

    if(m_hp <= 0){
      if(m_timeDying < 0){
        m_timeDying = m_timer;
        m_enableCollision = false;
      }
      if(!m_physicsDisabled){
        m_body.setActive(false);
        m_physicsDisabled = true;
      }
      if(m_timer - m_timeDying > m_durationDying){
        hasDone = true;
      }
    }
    return hasDone;
  }

  void awardDeathScore()
  {
    if(m_scoreAwarded) return;
    m_scoreAwarded = true;
    awardScore(5000);
  }

  // Drawing the box
  void onDisplay()
  {
    m_timer++;
    Vec2 pos = box2d.getBodyPixelCoord(m_body);
    float a = m_body.getAngle();
    pushMatrix();
    pushStyle();
    onDraw(pos.x, pos.y, -a);
    popStyle();
    popMatrix();
  }

  abstract void onDraw(float x, float y, float a);
  abstract Shape getShape();
  abstract FixtureDef getFixture();

  protected void makeBody(Vec2 center, float w, float h)
  {
    Shape sd = getShape();

    // Define a fixture
    FixtureDef fd = getFixture();
    fd.shape = sd;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    m_body = box2d.createBody(bd);
    m_body.createFixture(fd);
    m_body.setUserData(this);
    //body.setMassFromShapes();
  }

}
