
class Wood extends Box
{

  Wood(float x, float y, float w, float h){
    super(x, y, w, h);
  }
  
  float getDurability() { return 10.0; }
  PImage[] getTextures() { return imgWoodBlocks; }
  float getBirdDamageMultiplier() { return 1.0; }
  float getMinimumBirdDamageRatio() { return 1.05; }

  FixtureDef getFixture()
  {
    // 设置碰撞形状
    FixtureDef fd = new FixtureDef();
    // 设置物理参数
    fd.density = 45;
    fd.friction = 0.9;
    fd.restitution = 0.0;
    return fd;
  }

}
