import controlP5.*;

ControlP5 cp5;

PGraphics canvas;
PGraphics brightPass;

PShader bloomFilter;
PShader blurFilter;

int angle = 0;

final int surfaceWidth = 250;
final int surfaceHeight = 250;

float luminenceFilter = 0.8;
float blurRadius = 3;

void setup()
{
  size(750, 250, P3D);

  addUI();

  canvas = createGraphics(surfaceWidth, surfaceHeight, P3D);
  brightPass = createGraphics(surfaceWidth, surfaceHeight, P2D);

  bloomFilter = loadShader("bloomFrag.glsl", "bloomVert.glsl");
  blurFilter = loadShader("blur.glsl");

  brightPass.shader(bloomFilter);
}

void draw()
{
  background(0);

  bloomFilter.set("brightPassThreshold", luminenceFilter);

  canvas.beginDraw();
  render(canvas);
  canvas.endDraw();

  brightPass.beginDraw();
  brightPass.background(0, 0);
  brightPass.image(canvas, 0, 0);
  brightPass.filter(BLUR, blurRadius);
  brightPass.endDraw();

  // draw original
  image(canvas.copy(), 0, 0);
  text("Original", 20, height - 20); 

  // draw bright pass
  image(brightPass, surfaceWidth, 0);
  text("Bright Pass & Blur", surfaceWidth + 20, height - 20); 

  // draw 
  image(canvas, (surfaceWidth * 2), 0);
  blendMode(SCREEN);
  image(brightPass, (surfaceWidth * 2), 0);
  blendMode(BLEND);
  text("Combined", (surfaceWidth * 2) + 20, height - 20); 

  // fps
  fill(0, 255, 0);
  text("FPS: " + frameRate, 20, 20);
}

void render(PGraphics pg)
{
  pg.background(0, 0);
  pg.stroke(255, 0, 0);

  for (int i = -1; i < 2; i++)
  {
    if (i == -1)
      pg.fill(0, 255, 0);
    else if (i == 0)
      pg.fill(255);
    else
      pg.fill(0, 200, 200);

    pg.pushMatrix();
    // left-right, up-down, near-far
    pg.translate(surfaceWidth / 2 + (i * 50), surfaceHeight / 2, 0);
    pg.rotateX(radians(angle));
    pg.rotateZ(radians(angle));
    pg.box(30);
    pg.popMatrix();
  }

  angle = ++angle % 360;
}

void addUI()
{
  cp5 = new ControlP5(this);

  cp5.addSlider("luminenceFilter")
    .setPosition(200, 5)
    .setRange(0, 1)
    ;

  cp5.addSlider("blurRadius")
    .setPosition(400, 5)
    .setRange(0, 10)
    ;
}