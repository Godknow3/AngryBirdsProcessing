class Ramp extends HitBody
{
  float m_topWidth;

  Ramp(float x, float y, float w, float h, float topWidth)
  {
    super(HitBodyType.Boundary);
    m_w = w;
    m_h = h;
    m_topWidth = topWidth;
    makeBody(new Vec2(x, y), w, h);
  }

  boolean done() { return false; }

  void onDisplay()
  {
    Vec2 pos = box2d.getBodyPixelCoord(m_body);
    float slopeWidth = (m_w - m_topWidth) / 2.0;

    pushMatrix();
    pushStyle();
    imageMode(CENTER);
    translate(pos.x, pos.y);

    pushMatrix();
    translate(m_topWidth / 2 + slopeWidth / 2, 0);
    image(imgStoneRamp, 0, 0, slopeWidth, m_h);
    popMatrix();

    pushMatrix();
    scale(-1, 1);
    translate(m_topWidth / 2 + slopeWidth / 2, 0);
    image(imgStoneRamp, 0, 0, slopeWidth, m_h);
    popMatrix();

    noStroke();
    fill(83, 70, 61);
    rectMode(CENTER);
    rect(0, 0, m_topWidth + 2, m_h);
    popStyle();
    popMatrix();
  }

  protected void makeBody(Vec2 center, float w, float h)
  {
    float halfW = box2d.scalarPixelsToWorld(w / 2);
    float halfH = box2d.scalarPixelsToWorld(h / 2);
    float halfTop = box2d.scalarPixelsToWorld(m_topWidth / 2);
    Vec2[] vertices = {
      new Vec2(-halfW, -halfH),
      new Vec2( halfW, -halfH),
      new Vec2( halfTop, halfH),
      new Vec2(-halfTop, halfH)
    };

    PolygonShape shape = new PolygonShape();
    shape.set(vertices, vertices.length);
    FixtureDef fixture = new FixtureDef();
    fixture.shape = shape;
    fixture.friction = 0.8;
    fixture.restitution = 0.0;

    BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.STATIC;
    bodyDef.position.set(box2d.coordPixelsToWorld(center));
    m_body = box2d.createBody(bodyDef);
    m_body.createFixture(fixture);
    m_body.setUserData(this);
  }
}
