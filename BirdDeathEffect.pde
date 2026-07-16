class BirdDeathEffect
{
  PVector[] m_positions;
  PVector[] m_velocities;
  float[] m_angles;
  float[] m_spins;
  int m_age;
  final int LIFE = 42;

  BirdDeathEffect(float x, float y)
  {
    int featherCount = 8;
    m_positions = new PVector[featherCount];
    m_velocities = new PVector[featherCount];
    m_angles = new float[featherCount];
    m_spins = new float[featherCount];
    m_age = 0;

    for(int i = 0; i < featherCount; i++){
      m_positions[i] = new PVector(x + random(-5, 5), y + random(-5, 5));
      m_velocities[i] = new PVector(random(-2.8, 2.8), random(-4.2, -1.2));
      m_angles[i] = random(TWO_PI);
      m_spins[i] = random(-0.22, 0.22);
    }
  }

  void updateAndDisplay()
  {
    m_age++;
    float alpha = map(m_age, 0, LIFE, 255, 0);

    pushStyle();
    imageMode(CENTER);
    tint(255, constrain(alpha, 0, 255));

    if(m_age < 24){
      float smokeSize = map(m_age, 0, 24, 22, 58) * sceneScale();
      float centerX = 0;
      float centerY = 0;
      for(PVector position : m_positions){
        centerX += position.x;
        centerY += position.y;
      }
      centerX /= m_positions.length;
      centerY /= m_positions.length;
      image(imgBirdSmoke, centerX, centerY, smokeSize, smokeSize);
    }

    for(int i = 0; i < m_positions.length; i++){
      m_velocities[i].y += 0.16;
      m_positions[i].add(m_velocities[i]);
      m_angles[i] += m_spins[i];

      pushMatrix();
      translate(m_positions[i].x, m_positions[i].y);
      rotate(m_angles[i]);
      float featherSize = (12 + i % 3 * 2) * sceneScale();
      image(imgRedFeather, 0, 0, featherSize, featherSize);
      popMatrix();
    }
    noTint();
    popStyle();
  }

  boolean done()
  {
    return m_age >= LIFE;
  }
}
