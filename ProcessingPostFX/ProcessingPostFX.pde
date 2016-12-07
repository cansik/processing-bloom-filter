PostFX fx;
PGraphics canvas;

void setup()
{
  size(500, 500, P3D);
  fx = new PostFX(width, height);
  canvas = createGraphics(width, height, P3D);
}

void draw()
{
  canvas.beginDraw();
  canvas.background(55);

  // render simple cube
  canvas.pushMatrix();

  canvas.translate(width/2, height/2);
  canvas.rotateX(radians(frameCount % 360));
  canvas.rotateZ(radians(frameCount % 360));

  canvas.noStroke();
  //fill(124, 238, 206);
  canvas.fill(20, 20, 20);
  canvas.box(100);

  canvas.fill(150, 255, 255);
  //canvas.fill(255);
  canvas.sphere(60);

  canvas.popMatrix();
  canvas.endDraw();

  // filter current scene with bloom effect
  PGraphics result = fx.filter(canvas)
    .brightPass(0.3)
    .blur(40, 12, false)
    .blur(40, 12, true)
    .close();

  blendMode(BLEND);
  image(canvas, 0, 0);
  blendMode(SCREEN);
  image(result, 0, 0);

  fill(0, 255, 0);
  text("FPS: " + frameRate, 20, 20);
}