class Ice extends Box
{
  Ice(float x, float y, float w, float h)
  {
    super(x, y, w, h);
  }

  float getDurability() { return 5.0; }
  PImage[] getTextures() { return imgIceBlocks; }
  float getBirdDamageMultiplier() { return 1.0; }
  float getMinimumBirdDamageRatio() { return 1.05; }

  FixtureDef getFixture()
  {
    FixtureDef fd = new FixtureDef();
    fd.density = 22;
    fd.friction = 0.4;
    fd.restitution = 0.05;
    return fd;
  }
}
