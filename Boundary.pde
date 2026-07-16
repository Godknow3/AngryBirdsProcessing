
class Boundary extends HitBody
{

  // 创建矩形边界
  float m_x;
  float m_y;
  
  boolean done() { return false; }

  Boundary(float x, float y, float w, float h)
  {
    super(HitBodyType.Boundary);
    
    m_x = x; m_y = y; //<>//
    m_w = w; m_h = h;

    makeBody(new Vec2(x, y), w, h);
  }
  
  protected void makeBody(Vec2 center, float w, float h)
  {
    // 设置矩形形状
    PolygonShape sd = new PolygonShape();
    // 转换为 Box2D 坐标
    float box2dW = box2d.scalarPixelsToWorld(w / 2);
    float box2dH = box2d.scalarPixelsToWorld(h / 2);
    sd.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    fd.density = 10;
    fd.friction = 30.0;
    fd.restitution = 0.0;
    
    // 创建静态刚体
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    
    m_body = box2d.createBody(bd);
    m_body.createFixture(fd);
    m_body.setUserData(this);
  }

    // 边界仅参与碰撞
  void onDisplay() {
    // 保持不可见
  }

}
