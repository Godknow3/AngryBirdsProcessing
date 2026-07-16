import ddf.minim.*;

import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.callbacks.ContactListener;
import org.jbox2d.callbacks.ContactImpulse;
import java.io.File;

// Box2D 物理世界
Box2DProcessing box2d;
Minim minim;
AudioPlayer backgroundMusic;

// 游戏场景与关卡状态
Scene scene;
int currentLevel = 1;
final int LEVEL_COUNT = 6;
final int SCREEN_LEVEL_SELECT = 0;
final int SCREEN_GAME = 1;
final int PIG_SMALL = 0;
final int PIG_MEDIUM = 1;
final int PIG_BIG = 2;
int currentScreen = SCREEN_LEVEL_SELECT;
int levelFinishedAt = -1;
boolean levelWon = false;
boolean shotLaunched = false;
float groundY;

int currentScore = 0;
int shotsUsed = 0;
int resultStars = 0;
int[] bestStars = new int[LEVEL_COUNT];
int[] bestScores = new int[LEVEL_COUNT];
int[] parShots = {1, 1, 1, 2, 2, 2};
boolean lavaBirdUnlocked = false;

final float WORLD_GRAVITY_Y = -20.0;
final float GAMEPLAY_ZOOM = 0.78;
final float SLINGSHOT_POWER = 12.0 / GAMEPLAY_ZOOM;
final float PHYSICS_TIME_STEP = 1.0 / 60.0;

// 图片资源
PImage imgCatapultLeft;
PImage imgCatapultRight;
  
PImage[] imgWoodBlocks;
PImage[] imgIceBlocks;
PImage[] imgStoneBlocks;
PImage[] imgWoodLogs;
PImage[] imgStoneBalls;
PImage imgStoneRamp;

PImage imgRedBird;
PImage imgRedBirdDeath;
PImage imgRedFeather;
PImage imgBirdSmoke;
  
PImage imgPig;
PImage imgPigDying;
PImage[] imgPigSmall;
PImage[] imgPigMedium;
PImage[] imgPigBig;

PImage imgSelectLevelTitle;
PImage imgLevelButton;
PImage imgBackButton;
PImage imgMenuButton;
PImage imgNextButton;
PImage imgReplayButton;

// 带透明通道的场景图层，绘制在物理对象下方
PImage imgScienceBackground;
PImage imgScienceMidground;
PImage imgScienceMidgroundFar;
PImage imgScienceGround;
PImage imgScienceGrass;
PImage imgScienceGroundShadow;
    
boolean fullScreen = false;
ArrayList<BirdDeathEffect> birdDeathEffects = new ArrayList<BirdDeathEffect>();
ArrayList<LavaBlastEffect> lavaBlastEffects = new ArrayList<LavaBlastEffect>();

void setup()
{
  fullScreen(P2D);
  // 调试窗口可改用 size(1000, 800)
  smooth();

  minim = new Minim(this);
  backgroundMusic = minim.loadFile("angry_birds_theme.mp3");
  backgroundMusic.setGain(-8.0);
  backgroundMusic.loop();
  
  imgCatapultLeft = loadImage("catapult_left.png");
  imgCatapultRight = loadImage("catapult_right.png");
  
  PImage blockAtlas = loadImage("science_blocks.png");
  imgIceBlocks = cropBlockSprites(blockAtlas, new int[]{371, 393, 415, 437});
  imgWoodBlocks = cropBlockSprites(blockAtlas, new int[]{459, 480, 503, 525});
  imgStoneBlocks = cropBlockSprites(blockAtlas, new int[]{547, 569, 591, 613});
  imgWoodLogs = cropAtlasSprites(blockAtlas, 252, new int[]{332, 409, 486, 563}, 76, 75);
  imgStoneBalls = new PImage[]{
    blockAtlas.get(560, 166, 76, 76),
    blockAtlas.get(638, 166, 76, 75),
    blockAtlas.get(716, 166, 76, 75),
    blockAtlas.get(334, 242, 76, 75)
  };
  imgStoneRamp = blockAtlas.get(662, 84, 82, 82);
  imgRedBird = loadImage("redbird.png");
  PImage birdAtlas = loadImage("science_birds.png");
  imgRedBirdDeath = birdAtlas.get(627, 399, 45, 44);
  PImage effectAtlas = loadImage("science_effects.png");
  imgRedFeather = effectAtlas.get(138, 7, 19, 19);
  imgBirdSmoke = effectAtlas.get(0, 96, 20, 20);
  imgPig = loadImage("pig.png");
  imgPigDying = loadImage("pig_dying.png");

  PImage pigAtlas = loadImage("science_pigs.png");
  imgPigSmall = new PImage[]{
    pigAtlas.get(761, 626, 47, 45),
    pigAtlas.get(775, 266, 47, 45)
  };
  imgPigMedium = new PImage[]{
    pigAtlas.get(741, 543, 78, 76),
    pigAtlas.get(732, 154, 78, 76)
  };
  imgPigBig = new PImage[]{
    pigAtlas.get(672, 266, 99, 97),
    pigAtlas.get(260, 266, 99, 97)
  };

  PImage hudAtlas = loadImage("science_hud.png");
  imgSelectLevelTitle = hudAtlas.get(19, 0, 858, 164);
  imgLevelButton = hudAtlas.get(890, 0, 120, 123);
  imgBackButton = hudAtlas.get(0, 184, 50, 46);
  imgMenuButton = hudAtlas.get(667, 194, 114, 119);
  imgNextButton = hudAtlas.get(792, 191, 100, 110);
  imgReplayButton = hudAtlas.get(904, 190, 106, 110);

  imgScienceBackground = loadImage("science_background.png");
  imgScienceMidground = loadImage("science_midground.png");
  imgScienceMidgroundFar = loadImage("science_midground_far.png");
  imgScienceGround = loadImage("science_ground.png");
  imgScienceGrass = loadImage("science_grass.png");
  imgScienceGroundShadow = loadImage("science_ground_shadow.png");

  groundY = height * 0.82;
  loadProgress();
}

void stop()
{
  if(backgroundMusic != null){
    backgroundMusic.close();
  }
  if(minim != null){
    minim.stop();
  }
  super.stop();
}

PImage[] cropBlockSprites(PImage atlas, int[] topValues)
{
  return cropAtlasSprites(atlas, 453, topValues, 206, 22);
}

PImage[] cropAtlasSprites(PImage atlas, int left, int[] topValues, int spriteWidth, int spriteHeight)
{
  PImage[] sprites = new PImage[topValues.length];
  for(int i = 0; i < topValues.length; i++){
    sprites[i] = atlas.get(left, topValues[i], spriteWidth, spriteHeight);
  }
  return sprites;
}

void draw() {
  if(currentScreen == SCREEN_LEVEL_SELECT){
    drawLevelSelect();
    return;
  }

  scene.onDraw();
  drawBirdDeathEffects();
  drawLavaBlastEffects();
  drawGameHud();
  updateLevelState();
}

void drawEnvironment()
{
  background(190, 229, 248);
  imageMode(CORNER);
  image(imgScienceBackground, 0, 0, width, height);

  // 按远景到前景的顺序绘制环境
  float s = sceneScale();
  image(imgScienceMidgroundFar, 0, groundY - 256 * s, width, 256 * s);
  image(imgScienceMidground, 0, groundY - 489 * s, width, 489 * s);
  image(imgScienceGround, 0, groundY - 67 * s, width, 290 * s);
  image(imgScienceGrass, 0, groundY - 225 * s, width, 225 * s);
  image(imgScienceGroundShadow, 0, groundY - 2 * s, width, 62 * s);
}

void loadLevel(int level)
{
  currentLevel = constrain(level, 1, LEVEL_COUNT);
  levelFinishedAt = -1;
  levelWon = false;
  shotLaunched = false;
  currentScore = 0;
  shotsUsed = 0;
  resultStars = 0;
  birdDeathEffects.clear();
  lavaBlastEffects.clear();
  groundY = height * 0.82;

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.listenForCollisions();
  box2d.setGravity(0, WORLD_GRAVITY_Y);
  scene = new Scene();

  if(currentLevel == 1) buildLevelOne();
  else if(currentLevel == 2) buildLevelTwo();
  else if(currentLevel == 3) buildLevelThree();
  else if(currentLevel == 4) buildLevelFour();
  else if(currentLevel == 5) buildLevelFive();
  else buildLevelSix();
}

void startLevel(int level)
{
  currentScreen = SCREEN_GAME;
  loadLevel(level);
}

void showLevelSelect()
{
  currentScreen = SCREEN_LEVEL_SELECT;
}

void resumeCurrentLevel()
{
  if(scene != null) currentScreen = SCREEN_GAME;
}

float sceneScale()
{
  return min(width / 1280.0, height / 720.0) * GAMEPLAY_ZOOM;
}

void addBirds(int count)
{
  for(int i = 0; i < count; i++) scene.addBird(new RedBird());
}

void addLavaBirds(int count)
{
  for(int i = 0; i < count; i++) scene.addBird(new LavaBird());
}

void addLateGameBirds(int redBirdCount)
{
  if(lavaBirdUnlocked) addLavaBirds(1);
  addBirds(redBirdCount);
}

void addRotatedBox(Box box, float worldAngleDegrees)
{
  box.m_body.setTransform(box.m_body.getPosition(), radians(worldAngleDegrees));
  scene.addBox(box);
}

void addProtectedPig(NormalPig pig, int protectionFrames)
{
  pig.m_spawnProtectionFrames = protectionFrames;
  scene.addPig(pig);
}

void buildLevelOne()
{
  float s = sceneScale(), x = width * 0.79;
  scene.addBox(new Wood(x, groundY - 55 * s, 32 * s, 110 * s));
  scene.addBox(new Wood(x + 78 * s, groundY - 13 * s, 120 * s, 26 * s));
  scene.addPig(new NormalPig(x, groundY - 139 * s, 52 * s));
  addBirds(3);
}

void buildLevelTwo()
{
  float s = sceneScale();
  float rampX = width * 0.60;

  // 滚木受击后沿斜坡滚向猪群
  scene.addObstacle(new Ramp(rampX, groundY - 45 * s, 160 * s, 90 * s, 46 * s));
  scene.addBox(new RollingLog(rampX, groundY - 119 * s, 58 * s));

  scene.addPig(new NormalPig(rampX + 135 * s, groundY - 25 * s, 48 * s));
  scene.addPig(new NormalPig(rampX + 200 * s, groundY - 25 * s, 48 * s));

  // 滚木撞断冰支撑后触发连锁坍塌
  float gateX = rampX + 285 * s;
  scene.addBox(new Ice(gateX - 38 * s, groundY - 44 * s, 24 * s, 88 * s));
  scene.addBox(new Ice(gateX + 38 * s, groundY - 44 * s, 24 * s, 88 * s));
  scene.addBox(new Wood(gateX, groundY - 101 * s, 100 * s, 26 * s));
  scene.addPig(new NormalPig(gateX, groundY - 25 * s, 48 * s));
  addBirds(3);
}

void buildLevelThree()
{
  float s = sceneScale(), x = width * 0.75;

  // 下层空间与斜向石撑
  scene.addBox(new Wood(x - 46 * s, groundY - 60 * s, 24 * s, 120 * s));
  scene.addBox(new Wood(x + 46 * s, groundY - 60 * s, 24 * s, 120 * s));
  addRotatedBox(new Stone(x - 122 * s, groundY - 60 * s, 146 * s, 16 * s), 55);
  addRotatedBox(new Stone(x + 122 * s, groundY - 60 * s, 146 * s, 16 * s), -55);
  // 中层留有窄缝，结构移动后上层会坠落
  scene.addBox(new Wood(x - 68 * s, groundY - 132 * s, 120 * s, 24 * s));
  scene.addBox(new Wood(x + 68 * s, groundY - 132 * s, 120 * s, 24 * s));

  // 下层中央放置两只大型猪
  addProtectedPig(new NormalPig(x, groundY - 26 * s, 52 * s, PIG_BIG), 150);
  addProtectedPig(new NormalPig(x, groundY - 79 * s, 52 * s, PIG_BIG), 150);

  // 四根立柱保护小型猪
  scene.addBox(new Stone(x - 82 * s, groundY - 197 * s, 20 * s, 106 * s));
  scene.addBox(new Wood(x - 42 * s, groundY - 197 * s, 14 * s, 106 * s));
  scene.addBox(new Wood(x + 42 * s, groundY - 197 * s, 14 * s, 106 * s));
  scene.addBox(new Stone(x + 82 * s, groundY - 197 * s, 20 * s, 106 * s));
  addProtectedPig(new NormalPig(x, groundY - 160 * s, 32 * s, PIG_SMALL), 150);
  addProtectedPig(new NormalPig(x, groundY - 193 * s, 32 * s, PIG_SMALL), 150);
  addProtectedPig(new NormalPig(x, groundY - 226 * s, 32 * s, PIG_SMALL), 150);

  // 两侧平台支撑巨石，失衡后巨石会落下
  scene.addBox(new TriggerWood(x - 52 * s, groundY - 262 * s, 88 * s, 24 * s));
  scene.addBox(new TriggerWood(x + 52 * s, groundY - 262 * s, 88 * s, 24 * s));
  scene.addBox(new Ice(x - 62 * s, groundY - 309 * s, 18 * s, 70 * s));
  scene.addBox(new Ice(x + 62 * s, groundY - 309 * s, 18 * s, 70 * s));
  scene.addBox(new Ice(x, groundY - 354 * s, 146 * s, 20 * s));
  scene.addBox(new StoneBall(x, groundY - 302 * s, 56 * s));

  // 顶部使用短冰块组成护墙
  scene.addBox(new Ice(x - 66 * s, groundY - 378 * s, 14 * s, 28 * s));
  scene.addBox(new Ice(x - 22 * s, groundY - 378 * s, 14 * s, 28 * s));
  scene.addBox(new Ice(x + 22 * s, groundY - 378 * s, 14 * s, 28 * s));
  scene.addBox(new Ice(x + 66 * s, groundY - 378 * s, 14 * s, 28 * s));
  addBirds(3);
  scene.freezeLevelBodies();
}

  // 第四关：击倒支撑触发连锁反应，后方目标需要高抛
void buildLevelFour()
{
  float s = sceneScale(), x = width * 0.72;
  scene.addBox(new Wood(x - 105 * s, groundY - 48 * s, 28 * s, 96 * s));
  scene.addBox(new Ice(x, groundY - 48 * s, 28 * s, 96 * s));
  scene.addBox(new Wood(x - 53 * s, groundY - 102 * s, 135 * s, 24 * s));
  scene.addBox(new Stone(x + 122 * s, groundY - 70 * s, 28 * s, 140 * s));
  scene.addPig(new NormalPig(x - 53 * s, groundY - 148 * s, 48 * s));
  scene.addPig(new NormalPig(x + 122 * s, groundY - 164 * s, 52 * s));
  scene.addPig(new NormalPig(x + 215 * s, groundY - 25 * s, 48 * s));
  addLateGameBirds(4);
}

  // 第五关：中央堡垒与后方掩体需要分别处理
void buildLevelFive()
{
  float s = sceneScale(), x = width * 0.74;
  // 下层立柱与横梁保持贴合，避免初始重叠
  scene.addBox(new Stone(x - 92 * s, groundY - 55 * s, 28 * s, 110 * s));
  scene.addBox(new Stone(x + 92 * s, groundY - 55 * s, 28 * s, 110 * s));
  scene.addBox(new Wood(x, groundY - 123 * s, 220 * s, 26 * s));
  scene.addPig(new NormalPig(x, groundY - 25 * s, 48 * s));

  // 上层较窄，需要精确击打支撑
  scene.addBox(new Wood(x - 66 * s, groundY - 190 * s, 26 * s, 108 * s));
  scene.addBox(new Wood(x + 66 * s, groundY - 190 * s, 26 * s, 108 * s));
  scene.addBox(new Stone(x, groundY - 256 * s, 174 * s, 24 * s));
  scene.addPig(new NormalPig(x, groundY - 160 * s, 48 * s));
  scene.addPig(new NormalPig(x, groundY - 292 * s, 48 * s));

  // 后方目标需要单独补射
  scene.addBox(new Ice(x + 190 * s, groundY - 43 * s, 24 * s, 86 * s));
  scene.addBox(new Ice(x + 260 * s, groundY - 43 * s, 24 * s, 86 * s));
  scene.addBox(new Wood(x + 225 * s, groundY - 98 * s, 94 * s, 24 * s));
  scene.addPig(new NormalPig(x + 225 * s, groundY - 25 * s, 48 * s));
  addLateGameBirds(4);
}

  // 第六关：高塔距离较远，需要高抛与补射
void buildLevelSix()
{
  float s = sceneScale(), x = width * 0.75;
  // 石质底座与第一层
  scene.addBox(new Stone(x - 102 * s, groundY - 60 * s, 30 * s, 120 * s));
  scene.addBox(new Stone(x + 102 * s, groundY - 60 * s, 30 * s, 120 * s));
  scene.addBox(new Wood(x, groundY - 134 * s, 244 * s, 28 * s));
  scene.addPig(new NormalPig(x, groundY - 25 * s, 48 * s));

  // 木质中层
  scene.addBox(new Wood(x - 78 * s, groundY - 198 * s, 27 * s, 100 * s));
  scene.addBox(new Wood(x + 78 * s, groundY - 198 * s, 27 * s, 100 * s));
  scene.addBox(new Ice(x, groundY - 261 * s, 202 * s, 26 * s));
  scene.addPig(new NormalPig(x, groundY - 172 * s, 48 * s));

  // 冰质顶部由石块保护
  scene.addBox(new Ice(x - 58 * s, groundY - 318 * s, 25 * s, 88 * s));
  scene.addBox(new Ice(x + 58 * s, groundY - 318 * s, 25 * s, 88 * s));
  scene.addBox(new Stone(x, groundY - 375 * s, 154 * s, 26 * s));
  scene.addPig(new NormalPig(x, groundY - 298 * s, 48 * s));
  scene.addPig(new NormalPig(x, groundY - 412 * s, 48 * s));

  // 后方掩体需要最后单独击破
  scene.addBox(new Stone(x + 205 * s, groundY - 38 * s, 26 * s, 76 * s));
  scene.addBox(new Stone(x + 285 * s, groundY - 38 * s, 26 * s, 76 * s));
  scene.addBox(new Wood(x + 245 * s, groundY - 88 * s, 106 * s, 24 * s));
  scene.addPig(new NormalPig(x + 245 * s, groundY - 25 * s, 48 * s));
  addLateGameBirds(4);
}

void updateLevelState()
{
  if(levelFinishedAt < 0 && scene.isWon()){
    levelWon = true;
    levelFinishedAt = millis();
    finalizeLevelResult();
  }else if(levelFinishedAt < 0 && scene.isLost()){
    levelWon = false;
    levelFinishedAt = millis();
  }

}

void awardScore(int points)
{
  if(currentScreen == SCREEN_GAME && levelFinishedAt < 0) currentScore += points;
}

void spawnBirdDeathEffect(float x, float y)
{
  birdDeathEffects.add(new BirdDeathEffect(x, y));
}

void drawBirdDeathEffects()
{
  for(int i = birdDeathEffects.size() - 1; i >= 0; i--){
    BirdDeathEffect effect = birdDeathEffects.get(i);
    effect.updateAndDisplay();
    if(effect.done()) birdDeathEffects.remove(i);
  }
}

void spawnLavaBlastEffect(LavaBird source, float x, float y, float powerScale)
{
  lavaBlastEffects.add(new LavaBlastEffect(source, x, y, powerScale));
}

void drawLavaBlastEffects()
{
  for(int i = lavaBlastEffects.size() - 1; i >= 0; i--){
    LavaBlastEffect effect = lavaBlastEffects.get(i);
    effect.updateAndDisplay();
    if(effect.done()) lavaBlastEffects.remove(i);
  }
}

void finalizeLevelResult()
{
  currentScore += scene.unusedBirdCount() * 10000;
  int par = parShots[currentLevel - 1];
  resultStars = shotsUsed <= par ? 3 : shotsUsed == par + 1 ? 2 : 1;

  bestStars[currentLevel - 1] = max(bestStars[currentLevel - 1], resultStars);
  bestScores[currentLevel - 1] = max(bestScores[currentLevel - 1], currentScore);
  if(bestStars[0] == 3 && bestStars[1] == 3 && bestStars[2] == 3){
    lavaBirdUnlocked = true;
  }
  saveProgress();
}

void loadProgress()
{
  String path = sketchPath("angrybirds_progress.txt");
  File progressFile = new File(path);
  if(!progressFile.exists()) return;

  String[] lines = loadStrings(path);
  if(lines == null) return;
  for(String line : lines){
    String[] values = split(line, ',');
    if(values.length == 3 && values[0].equals("level")){
      int index = parseInt(values[1]) - 1;
      if(index >= 0 && index < LEVEL_COUNT){
        String[] levelRecord = split(values[2], ':');
        if(levelRecord.length == 2){
          bestStars[index] = constrain(parseInt(levelRecord[0]), 0, 3);
          bestScores[index] = max(0, parseInt(levelRecord[1]));
        }
      }
    }else if(values.length == 2 && values[0].equals("lava")){
      lavaBirdUnlocked = parseInt(values[1]) == 1;
    }
  }
  if(bestStars[0] == 3 && bestStars[1] == 3 && bestStars[2] == 3){
    lavaBirdUnlocked = true;
  }
}

void saveProgress()
{
  String[] lines = new String[LEVEL_COUNT + 1];
  for(int i = 0; i < LEVEL_COUNT; i++){
    lines[i] = "level," + (i + 1) + "," + bestStars[i] + ":" + bestScores[i];
  }
  lines[LEVEL_COUNT] = "lava," + (lavaBirdUnlocked ? 1 : 0);
  saveStrings(sketchPath("angrybirds_progress.txt"), lines);
}

void drawGameHud()
{
  float u = uiScale();
  pushStyle();
  fill(25, 35, 45, 210);
  noStroke();
  rect(20, 20, 390, 100, 6);
  fill(255);
  textAlign(LEFT, TOP);
  textSize(24);
  text("LEVEL " + currentLevel + " / " + LEVEL_COUNT, 38, 32);
  textSize(16);
  text("Birds: " + scene.birdCount() + "    Pigs: " + scene.pigCount() + "    Score: " + currentScore, 38, 68);
  textSize(13);
  text(levelHint(), 38, 88);

  drawImageButton(imgMenuButton, width - 116 * u, 54 * u, 52 * u, isOverButton(width - 116 * u, 54 * u, 52 * u));
  drawImageButton(imgReplayButton, width - 54 * u, 54 * u, 52 * u, isOverButton(width - 54 * u, 54 * u, 52 * u));

  if(levelFinishedAt >= 0){
    fill(15, 24, 30, 155);
    rect(0, 0, width, height);
    textAlign(CENTER, CENTER);
    textSize(46);
    fill(levelWon ? color(40, 175, 75) : color(210, 65, 55));
    String message = levelWon ? (currentLevel == LEVEL_COUNT ? "ALL LEVELS CLEARED!" : "LEVEL CLEARED!") : "TRY AGAIN";
    text(message, width / 2, height * 0.25);

    if(levelWon){
      float starsY = height * 0.25 + 52 * u;
      for(int i = 0; i < 3; i++) drawStar(width / 2 + (i - 1) * 46 * u, starsY, 18 * u, i < resultStars);
      fill(255);
      textSize(18 * u);
      text("Score: " + currentScore, width / 2, starsY + 38 * u);
    }

    float resultY = height * 0.25 + 145 * u;
    float resultSize = 76 * u;
    drawImageButton(imgMenuButton, width / 2 - 92 * u, resultY, resultSize,
      isOverButton(width / 2 - 92 * u, resultY, resultSize));
    drawImageButton(imgReplayButton, width / 2, resultY, resultSize,
      isOverButton(width / 2, resultY, resultSize));
    if(levelWon && currentLevel < LEVEL_COUNT){
      drawImageButton(imgNextButton, width / 2 + 92 * u, resultY, resultSize,
        isOverButton(width / 2 + 92 * u, resultY, resultSize));
    }
  }
  popStyle();
}

void drawLevelSelect()
{
  drawEnvironment();
  float u = uiScale();

  pushStyle();
  fill(15, 30, 40, 65);
  noStroke();
  rect(0, 0, width, height);

  imageMode(CENTER);
  if(scene != null){
    drawImageButton(imgBackButton, 56 * u, 54 * u, 52 * u,
      isOverButton(56 * u, 54 * u, 62 * u));
  }
  float titleWidth = min(width * 0.56, 500 * u);
  image(imgSelectLevelTitle, width / 2, 105 * u, titleWidth, titleWidth * 164.0 / 858.0);

  float buttonSize = 96 * u;
  float gapX = 150 * u;
  float gapY = 145 * u;
  float startY = max(235 * u, height * 0.38);
  textAlign(CENTER, CENTER);
  textSize(38 * u);

  for(int i = 0; i < LEVEL_COUNT; i++){
    int col = i % 3;
    int row = i / 3;
    float cx = width / 2 + (col - 1) * gapX;
    float cy = startY + row * gapY;
    boolean hover = isOverButton(cx, cy, buttonSize);
    drawImageButton(imgLevelButton, cx, cy, buttonSize, hover);
    fill(92, 58, 12);
    text(i + 1, cx, cy - 2 * u);
    for(int star = 0; star < 3; star++){
      drawStar(cx + (star - 1) * 24 * u, cy + 66 * u, 8 * u, star < bestStars[i]);
    }
  }

  if(lavaBirdUnlocked){
    fill(245, 92, 28);
    textSize(18 * u);
    text("SECRET: LAVA BIRD UNLOCKED", width / 2, startY + 2 * gapY - 18 * u);
  }
  popStyle();
}

float uiScale()
{
  return min(width / 1280.0, height / 720.0);
}

void drawImageButton(PImage icon, float cx, float cy, float size, boolean hover)
{
  imageMode(CENTER);
  float drawSize = hover ? size * 1.06 : size;
  image(icon, cx, cy, drawSize, drawSize);
}

boolean isOverButton(float cx, float cy, float size)
{
  return abs(mouseX - cx) <= size / 2 && abs(mouseY - cy) <= size / 2;
}

void drawStar(float cx, float cy, float radius, boolean filledStar)
{
  pushStyle();
  stroke(118, 78, 12);
  strokeWeight(max(1, radius * 0.12));
  fill(filledStar ? color(255, 198, 38) : color(72, 82, 88, 150));
  beginShape();
  for(int i = 0; i < 10; i++){
    float angle = -HALF_PI + i * PI / 5.0;
    float r = i % 2 == 0 ? radius : radius * 0.45;
    vertex(cx + cos(angle) * r, cy + sin(angle) * r);
  }
  endShape(CLOSE);
  popStyle();
}

String levelHint()
{
  String[] hints = {
    "Learn the slingshot",
    "Break the supports",
    "Aim for a chain reaction",
    "Two towers, one weak point",
    "A narrow-base fortress",
    "Final tower: use high arcs"
  };
  return hints[currentLevel - 1];
}

void keyPressed()
{
  if(key == ESC){
    key = 0;
    if(currentScreen == SCREEN_LEVEL_SELECT && scene != null) resumeCurrentLevel();
    else showLevelSelect();
    return;
  }
  if(currentScreen != SCREEN_GAME) return;
  if(key == 'r' || key == 'R') loadLevel(currentLevel);
  if(key == 'n' || key == 'N') loadLevel(currentLevel % LEVEL_COUNT + 1);
}

void mousePressed()
{
  float u = uiScale();

  if(currentScreen == SCREEN_LEVEL_SELECT){
    if(scene != null && isOverButton(56 * u, 54 * u, 62 * u)){
      resumeCurrentLevel();
      return;
    }
    float buttonSize = 96 * u;
    float gapX = 150 * u;
    float gapY = 145 * u;
    float startY = max(235 * u, height * 0.38);
    for(int i = 0; i < LEVEL_COUNT; i++){
      float cx = width / 2 + (i % 3 - 1) * gapX;
      float cy = startY + (i / 3) * gapY;
      if(isOverButton(cx, cy, buttonSize * 1.2)){
        startLevel(i + 1);
        return;
      }
    }
    return;
  }

  if(levelFinishedAt >= 0){
    float resultY = height * 0.25 + 145 * u;
    float resultSize = 76 * u;
    if(isOverButton(width / 2 - 92 * u, resultY, resultSize)){
      showLevelSelect();
    }else if(isOverButton(width / 2, resultY, resultSize)){
      loadLevel(currentLevel);
    }else if(levelWon && currentLevel < LEVEL_COUNT &&
             isOverButton(width / 2 + 92 * u, resultY, resultSize)){
      loadLevel(currentLevel + 1);
    }
    return;
  }

  if(isOverButton(width - 116 * u, 54 * u, 52 * u)){
    showLevelSelect();
  }else if(isOverButton(width - 54 * u, 54 * u, 52 * u)){
    loadLevel(currentLevel);
  }else if(scene != null && !scene.m_birds.isEmpty()){
    Bird activeBird = scene.m_birds.get(0);
    if(activeBird.gone()) activeBird.onEmit();
  }
}

void mouseDragged()
{
  if(currentScreen == SCREEN_GAME && levelFinishedAt < 0) scene.onCursorDragged(mouseX, mouseY);
}

void mouseReleased()
{
  if(currentScreen == SCREEN_GAME && levelFinishedAt < 0) scene.onCursorReleased(mouseX, mouseY);
}

void beginContact(Contact contact)
{
  Object dataA = contact.getFixtureA().getBody().getUserData();
  Object dataB = contact.getFixtureB().getBody().getUserData();
  HitBody bodyA = dataA instanceof HitBody ? (HitBody)dataA : null;
  HitBody bodyB = dataB instanceof HitBody ? (HitBody)dataB : null;
  if(bodyA == null && bodyB == null) return;

  WorldManifold worldManifold = new WorldManifold();
  contact.getWorldManifold(worldManifold);
  int pointCount = contact.getManifold().pointCount;
  Vec2 centerVelocityA = contact.getFixtureA().getBody().getLinearVelocity();
  Vec2 centerVelocityB = contact.getFixtureB().getBody().getLinearVelocity();
  float relativeSpeed = centerVelocityB.sub(centerVelocityA).length();

  for(int i = 0; i < pointCount; i++){
    Vec2 point = worldManifold.points[i];
    Vec2 velocityA = contact.getFixtureA().getBody().getLinearVelocityFromWorldPoint(point);
    Vec2 velocityB = contact.getFixtureB().getBody().getLinearVelocityFromWorldPoint(point);
    relativeSpeed = max(relativeSpeed, velocityB.sub(velocityA).length());
  }

  if(bodyA != null && bodyA.m_enableCollision) bodyA.onVelocityCollision(relativeSpeed, bodyB);
  if(bodyB != null && bodyB.m_enableCollision) bodyB.onVelocityCollision(relativeSpeed, bodyA);
}
void endContact(Contact contact) { /* 无需处理碰撞结束 */ }
void preSolve(Contact contact, Manifold oldManifold) { /* 无需预处理碰撞 */ }

void postSolve(Contact contact, ContactImpulse impulse)
{
  HitBody bodyA = (HitBody)contact.getFixtureA().getBody().getUserData();
  HitBody bodyB = (HitBody)contact.getFixtureB().getBody().getUserData();
  if(bodyA != null && bodyA.m_enableCollision) bodyA.onImpulseCollision(impulse);
  if(bodyB != null && bodyB.m_enableCollision) bodyB.onImpulseCollision(impulse);
}
  
