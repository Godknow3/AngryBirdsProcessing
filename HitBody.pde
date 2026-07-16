
enum HitBodyType{None, Boundary, Box, Bird, Pig};

abstract class HitBody
{

  HitBodyType m_type;

  Body m_body;
  float m_w; float m_h;

  boolean m_enableCollision;

  HitBody(HitBodyType type)
  {
    m_type = type;
    m_enableCollision = false;
  }

  void onUpdate()
  {
    onDisplay();
  }

  abstract boolean done();
  boolean onIntrospect()
  {
    boolean d = done();
    if(d) killBody();
    return d;
  }

  abstract void onDisplay();

  protected abstract void makeBody(Vec2 center, float w, float h);
  void killBody()
  {
    box2d.destroyBody(m_body);
  }
  
  // 根据碰撞冲量计算强度
  float averageNormalImpulse(ContactImpulse impulse)
  {
    float total = 0.0;
    for(int i = 0; i < impulse.normalImpulses.length; i++){
      total += impulse.normalImpulses[i];
    }
    return total / impulse.normalImpulses.length;
  }
  
  float maximumNormalImpulse(ContactImpulse impulse)
  {
    float max = 0.0;
    for(int i = 0; i < impulse.normalImpulses.length; i++){
      if(max < impulse.normalImpulses[i]) max = impulse.normalImpulses[i];
    }
    return max;
  }
  
  void onImpulseCollision(ContactImpulse impulse) { /* 默认不处理 */ }

  void onVelocityCollision(float relativeSpeed, HitBody other) { /* 默认不处理 */ }

}
