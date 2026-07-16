class TriggerWood extends Wood
{
  TriggerWood(float x, float y, float w, float h)
  {
    super(x, y, w, h);
  }

  // Lightweight wood used only for deliberate chain-reaction mechanisms.
  FixtureDef getFixture()
  {
    FixtureDef fixture = new FixtureDef();
    fixture.density = 24;
    fixture.friction = 0.55;
    fixture.restitution = 0.0;
    return fixture;
  }

  float getLinearDamping() { return 0.03; }
  float getAngularDamping() { return 0.18; }
}
