class Stone extends Box
{
  Stone(float x, float y, float w, float h)
  {
    super(x, y, w, h);
  }

  float getDurability() { return 20.0; }
  PImage[] getTextures() { return imgStoneBlocks; }
  float getBirdDamageMultiplier() { return 1.0; }
  float getMinimumBirdDamageRatio() { return 0.45; }

  FixtureDef getFixture()
  {
    FixtureDef fd = new FixtureDef();
    fd.density = 140;
    fd.friction = 1.3;
    fd.restitution = 0.0;
    return fd;
  }
}
