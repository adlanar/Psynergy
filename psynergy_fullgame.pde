// Muhammad Adlan Ramly

// Credits for whom I'm inspired: My friend Josh Li for the P1 controls, 
// Karl S. for mouse controls, & Andrew Smith for the object spawner

//CONTROLS:
//P1: WASD Keys to move
//P2: Mouse Control + left click to shoot

Player1 player1;

int P1_HP = 100;

int P2_HP = 100;
int P2_Bullets = 10;
boolean emptyBullets = false;

float xP1, yP1;
float P1_up, P1_down, P1_left, P1_right; 
float P1_vAcc, P1_hAcc;

ArrayList <Enemy> enemies = new ArrayList <Enemy>();
ArrayList<Bullets> bullets = new ArrayList <Bullets>();
ArrayList<HealthPacks> hpPacks = new ArrayList <HealthPacks>();

int enemySpawnFrames = 100;
int itemSpawnFrames = 200;

boolean timerIsOn = true;

int actualSecs; //actual seconds elapsed since start
int actualMins; //actual minutes elapsed since start
int startSec = 0; //used to reset seconds shown on screen to 0
int startMin = 0; //used to reset minutes shown on screen to 0
int scrnSecs; //seconds displayed on screen (will be 0-60)
int scrnMins=0; //minutes displayed on screen (will be infinite)
int restartSecs=0; 
int restartMins=0; 

String finalMin;
String finalSec;

boolean titleScreen = true;

PImage title;
PImage hpSprite;
PImage bulletSprite;

void setup() {
  size(500,500);
  title = loadImage("titleScreen.png");
  player1 = new Player1(width/2, height/2);
  titleScreen = true;
  cursor(CROSS); //make P2 look like a crosshair
}

void draw() {
  if (titleScreen) {
  drawTitleScreen();
  }
  else {
  background(219, 219, 255);
  drawUI();
  drawGame();
  }
}

void drawGame() {
if (timerIsOn) { 
    timerON();
  }
  player1.drawPlayer1();
  player1.moveP1();
  xP1 = player1.getXP1();
  yP1 = player1.getYP1();
   
  //Enemies will more likely to appear each 30 seconds with a limit of 30fps
  if (frameCount % 1500 == 0 && enemySpawnFrames >= 30) {
    enemySpawnFrames -= 10;
  }
  
  //Add an enemy every 100 frames
  if (frameCount % enemySpawnFrames == 0) {
    enemies.add(new Enemy(random(width),random(height)));
  }
  
  //Spawn Enemies, and chase
  for (int i = enemies.size()-1; i >=0; i--) {
    Enemy e = enemies.get(i);
    e.drawEnemy();
    e.enemyChase();
  }
  
  //Add an item every 150 frames
if (frameCount % 150 == 0) {
    bullets.add(new Bullets(random(width-20),random(height-20)));
    hpPacks.add(new HealthPacks(random(width-20),random(height-20)));
  }
  
  //Spawn Bullets
  for (int i = bullets.size()-1; i >=0; i--) {
    Bullets b = bullets.get(i);
    b.drawBullets();
  }
  
  //Spawn Health Packs
  for (int i = hpPacks.size()-1; i >=0; i--) {
    HealthPacks hps = hpPacks.get(i);
    hps.drawHPs();
  }
  
  //Collisions with Enemies
  for (int i = 0; i < enemies.size(); i++) {
      Enemy e = (Enemy) enemies.get(i);
      float distance = dist(xP1, yP1, e.xEnemy, e.yEnemy);
      
    if (distance < e.enemySize) {
        P1_HP -= 1;
      }
  }
  
  //Collisions with Bullets
  for (int i = 0; i < bullets.size(); i++) {
      Bullets b = (Bullets) bullets.get(i);
      float distance = dist(xP1, yP1, b.xBullets, b.yBullets);
       
    if (distance < b.bulletSize) {
        P2_Bullets += 5;
        bullets.remove(i);
        
      }
  }
  
  //Collisions with Health Packs
  for (int i = 0; i < hpPacks.size(); i++) {
      HealthPacks hps = (HealthPacks) hpPacks.get(i);
      float distance = dist(xP1, yP1, hps.xHPs, hps.yHPs);
       
    if (distance < hps.HPSize) {
        P1_HP += 4;
        P2_HP += 6;
        hpPacks.remove(i);
      }
  }
  
  //Game Over Mechanisms
    if (P2_HP > 0) {
  if (frameCount % 50 == 0) { 
    P2_HP -= 2;  
      }
    }
    else {
      
      timerIsOn = false;
      drawGameOverScreen();
  }
  
  if (P1_HP < 0) {
    timerIsOn = false;
    drawGameOverScreen();
  }
}

void drawTitleScreen() {
  image(title,0,0);
  textAlign(CENTER);
  fill(255, 213, 7);
  textSize(40);
  text("START",width/2,450);
  if (mousePressed) {
    if(mouseX > 150 && mouseX < 400 && mouseY > 400 && mouseY < 460) {
      titleScreen = false;
    }
  } 
}

void drawGameOverScreen() {
  timerIsOn = false;
  background(74, 64, 94);
  fill(232, 55, 55);
  textAlign(CENTER);
  textSize(50);
  text("GAME OVER",width/2,200);
  textSize(32);
  text("Time Survived:",width/2,250);
  text(nf(scrnMins, 2) + " : " + nf(scrnSecs, 2), width/2,300);
  fill(255, 213, 7);
  textSize(40);
  text("RESTART",width/2,450);
  if (mousePressed) {
    if(mouseX > 150 && mouseX < 400 && mouseY > 400 && mouseY < 460) {
      reset();
      drawGame();
    }
  } 
}

void timerON() {
  textSize(32);
  textAlign(CENTER, CENTER);
  fill(0);
  
  actualSecs = millis()/1000; //convert milliseconds to seconds, store values.
  actualMins = millis() /1000 / 60; //convert milliseconds to minutes, store values.
  scrnSecs = actualSecs - restartSecs; //seconds to be shown on screen
  scrnMins = actualMins - restartMins; //minutes to be shown on screen
  
  if (actualSecs % 60 == 0) { //after 60 secs, restart second timer  
      restartSecs = actualSecs;   //placeholder for this second in time
      scrnSecs = startSec; //reset to zero
    }
  
  text(nf(scrnMins, 2) + " : " + nf(scrnSecs, 2), width/2, 50);
}

void drawUI() {
//P1 Stats
fill(60, 130, 242);
textAlign(CENTER, BOTTOM);
text("P1",40, 40);
text(P1_HP,40, 70);

//P2 Stats
fill(255, 130, 28);
textAlign(CENTER, BOTTOM);
text("P2",460, 40);
text(P2_HP,460, 70);
textSize(18);
text("x"+P2_Bullets,460, 90);
}

void reset() {
restartSecs = actualSecs; //stores elapsed SECONDS
scrnSecs = startSec; //restart screen timer  
restartMins = actualMins; //stores elapsed MINUTES
scrnMins = startMin; //restart screen timer

timerIsOn = true;

player1.position.x = width/2;
player1.position.y= height/2;


P1_HP = 100;
P2_HP = 100;
P2_Bullets = 10;

for (int i = enemies.size()-1; i >=0; i--) {
    enemies.remove(i);
  }
  
for (int i = bullets.size()-1; i >=0; i--) {
    bullets.remove(i);
  }

for (int i = hpPacks.size()-1; i >=0; i--) {
    hpPacks.remove(i);
  }

}
void keyReleased() 
{
  if (key == CODED)
  {
    if (keyCode == UP)     P1_up = 0;
    if (keyCode == DOWN)   P1_down = 0;
    if (keyCode == LEFT)   P1_left = 0;
    if (keyCode == RIGHT)  P1_right = 0;
  }
  if (key == 'w')     P1_up = 0;
  if (key == 's')     P1_down = 0;
  if (key == 'a')     P1_left = 0;
  if (key == 'd')     P1_right = 0;
}
 
void keyPressed() 
{
  if (key == CODED)
  {
    if (keyCode == UP)     P1_up = 1;
    if (keyCode == DOWN)   P1_down = 1;
    if (keyCode == LEFT)   P1_left = 1;
    if (keyCode == RIGHT)  P1_right = 1;
  }
  if (key == 'w')     P1_up = 1;
  if (key == 's')     P1_down = 1;
  if (key == 'a')     P1_left = 1;
  if (key == 'd')     P1_right = 1;
  
}

void mousePressed() {
  if (P2_Bullets > 0) {
    emptyBullets = false;
  }
  if (P2_Bullets > 0 && emptyBullets == false) {
    P2_Bullets--;
    for (int i = 0; i < enemies.size(); i++) {
      Enemy e = (Enemy) enemies.get(i);
      float distance = dist(mouseX, mouseY, e.xEnemy, e.yEnemy);
       
      if (distance < e.enemySize * 0.5) {
        enemies.remove(i);
      }
    }
  }
  else if (P2_Bullets <= 0) {
    emptyBullets = true;
  }
}

class Entity
{
  PVector position;
  
  Entity(float xPos, float yPos)
  {
    position = new PVector(xPos, yPos);
  }
  
  void update(PVector v)
  {  
    position = v;
  }
}

class Player1 extends Entity
{
  float speed = 4;
  float p1Size = 30;
  

  Player1(float xPos, float yPos)
  {
     super(xPos, yPos);
  }
      
  void drawPlayer1()
  {
    noStroke();
    fill(60, 130, 242); 
    ellipseMode(CENTER);
    ellipse(position.x, position.y, p1Size, p1Size);
  }
  
  void moveP1()
{
  if(P1_up == 1) P1_vAcc = constrain(P1_vAcc - 0.2, -1, 1);
  if(P1_down == 1) P1_vAcc = constrain(P1_vAcc + 0.2, -1, 1);
  if(P1_left == 1) P1_hAcc = constrain(P1_hAcc - 0.2, -1, 1);
  if(P1_right == 1) P1_hAcc = constrain(P1_hAcc + 0.2, -1, 1);
  
  player1.update(new PVector(player1.position.x + player1.speed * P1_hAcc, player1.position.y + player1.speed * P1_vAcc));
  player1.position.x = constrain(player1.position.x, 0 + player1.p1Size/2, width - player1.p1Size/2);
  player1.position.y = constrain(player1.position.y, 0 + player1.p1Size/2, height - player1.p1Size/2);
  
  if(P1_vAcc > 0) P1_vAcc -= 0.03; 
  if(P1_vAcc < 0) P1_vAcc += 0.03;
  if(P1_hAcc > 0) P1_hAcc -= 0.03;
  if(P1_hAcc < 0) P1_hAcc += 0.03;
}

  float getXP1() {
   return player1.position.x;
  }
  
  float getYP1() {
  return player1.position.y;
  }
}

class Enemy extends Entity {
  float xEnemy;
  float yEnemy;
  float enemySpeed = 2;
  //Enemy size is randomized between 15-30 to keep variety
  float enemySize = random(15, 30);
  
  Enemy(float xPos, float yPos) {
  super(xPos, yPos);
  xEnemy = xPos;
  yEnemy = yPos;
  }
  
  void drawEnemy() {
  fill(0);
  ellipse(xEnemy, yEnemy, enemySize, enemySize);
  }
  
  void enemyChase() {
  float angle = atan2(yP1-yEnemy, xP1-xEnemy);
  float newX = cos(angle) * enemySpeed + xEnemy;
  float newY = sin(angle) * enemySpeed + yEnemy;
  xEnemy = newX;
  yEnemy = newY;
  }
  }
  
  class Bullets extends Entity{
  float xBullets;
  float yBullets;
  float bulletSize = 20;
  
  Bullets(float xPos, float yPos) {
  super(xPos, yPos);
  xBullets = xPos;
  yBullets = yPos;
  bulletSprite = loadImage("bullet_pack.png");
  }
  
  void drawBullets() {
  bulletSprite.resize(160,160);
  imageMode(CENTER);
  image(bulletSprite,xBullets,yBullets);
  }
  }
  
  class HealthPacks extends Entity{
  float xHPs;
  float yHPs;
  float HPSize = 20;
  
  HealthPacks(float xPos, float yPos) {
  super(xPos, yPos);
  xHPs = xPos;
  yHPs = yPos;
  hpSprite = loadImage("hp_pack.png");
  }
  
  void drawHPs() {
  hpSprite.resize(100,100);
  imageMode(CENTER);
  image(hpSprite,xHPs,yHPs);
  }
  }