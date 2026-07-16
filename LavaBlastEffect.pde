class LavaBlastEffect
{
  LavaBird m_source;
  float m_x;
  float m_y;
  float m_powerScale;
  int m_age;
  PVector[] m_sparks;
  PVector[] m_velocities;
  final int BLAST_LIFE = 48;
  final int LIFE = 105;

  LavaBlastEffect(LavaBird source, float x, float y, float powerScale)
  {
    m_source = source;
    m_x = x;
    m_y = y;
    m_powerScale = powerScale;
    m_age = 0;
    m_sparks = new PVector[18];
    m_velocities = new PVector[m_sparks.length];
    for(int i = 0; i < m_sparks.length; i++){
      float angle = random(TWO_PI);
      float speed = random(3.2, 8.5) * sceneScale();
      m_sparks[i] = new PVector(x, y);
      m_velocities[i] = new PVector(cos(angle) * speed, sin(angle) * speed);
    }
  }

  void updateAndDisplay()
  {
    m_age++;
    float progress = constrain((float)m_age / BLAST_LIFE, 0, 1);
    float alpha = 255 * (1.0 - progress);

    pushStyle();

    if(m_age <= 8){
      float flashSize = lerp(36, 150 * sceneScale() * m_powerScale, (float)m_age / 8);
      noStroke();
      fill(255, 245, 190, 245 - m_age * 20);
      ellipse(m_x, m_y, flashSize, flashSize);
    }

    float fireProgress = constrain(progress * 1.8, 0, 1);
    float fireSize = lerp(30, 205 * sceneScale() * m_powerScale, fireProgress);
    noStroke();
    fill(225, 48, 18, alpha * 0.65);
    ellipse(m_x, m_y, fireSize, fireSize);
    fill(255, 132, 18, alpha * 0.8);
    ellipse(m_x, m_y, fireSize * 0.68, fireSize * 0.68);
    fill(255, 230, 105, alpha);
    ellipse(m_x, m_y, fireSize * 0.34, fireSize * 0.34);

    for(int i = 0; i < m_sparks.length; i++){
      m_velocities[i].mult(0.94);
      m_velocities[i].y += 0.08 * sceneScale();
      m_sparks[i].add(m_velocities[i]);
      float sparkSize = max(2, (9 - progress * 6) * sceneScale());
      fill(i % 3 == 0 ? color(255, 235, 120, alpha) : color(255, 83, 20, alpha));
      ellipse(m_sparks[i].x, m_sparks[i].y, sparkSize, sparkSize);
    }

    float diameter = lerp(45, 350 * sceneScale() * m_powerScale, progress);
    noFill();
    strokeWeight(max(2, 12 * sceneScale() * (1.0 - progress)));
    stroke(255, 185, 28, alpha);
    ellipse(m_x, m_y, diameter, diameter);
    stroke(235, 65, 24, alpha * 0.85);
    ellipse(m_x, m_y, diameter * 0.76, diameter * 0.76);

    if(m_age >= 14){
      float poolProgress = constrain((float)(m_age - 14) / (LIFE - 14), 0, 1);
      float poolAlpha = 210 * (1.0 - poolProgress);
      noStroke();
      fill(92, 25, 20, poolAlpha * 0.8);
      ellipse(m_x, m_y + 18 * sceneScale(), 210 * sceneScale() * m_powerScale,
        44 * sceneScale() * m_powerScale);
      fill(255, 82, 16, poolAlpha);
      ellipse(m_x, m_y + 16 * sceneScale(), 165 * sceneScale() * m_powerScale,
        25 * sceneScale() * m_powerScale);
      fill(255, 208, 58, poolAlpha * 0.8);
      ellipse(m_x, m_y + 14 * sceneScale(), 96 * sceneScale() * m_powerScale,
        12 * sceneScale() * m_powerScale);
    }
    popStyle();

    if(m_age == 20 || m_age == 42 || m_age == 64){
      float burnScale = m_powerScale > 1.0 ? 1.1 : 0.8;
      scene.burnLavaArea(m_source, m_x, m_y, burnScale);
    }
  }

  boolean done()
  {
    return m_age >= LIFE;
  }
}
