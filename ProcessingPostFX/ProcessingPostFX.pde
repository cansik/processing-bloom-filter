PostFX fx;
PGraphics canvas;

// pass results
PGraphics bloomImage;
PGraphics sobelImage;

void setup()
{
  size(600, 600, P3D);
  fx = new PostFX(width, height);

  canvas = createGraphics(width, height, P3D);

  // initialise pass results
  bloomImage = createGraphics(width, height, P2D);
  sobelImage = createGraphics(width, height, P2D);
}

void draw()
{
  // clear screen
  background(0);

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
  fx.filter(canvas)
    .brightPass(0.3)
    .blur(40, 12, false)
    .blur(40, 12, true)
    .close(bloomImage);

  // filter image with sobel
  fx.filter(canvas)
    .toon()
    .close(sobelImage);

  blendMode(BLEND);

  // draw normal image
  image(canvas, 0, 0, width / 2, height / 2);

  // draw sobel
  image(sobelImage, width / 2, 0, width / 2, height / 2);

  // draw bloom pass
  image(bloomImage, 0, height / 2, width / 2, height / 2);

  // draw all combined
  blendMode(BLEND);
  image(canvas, width / 2, height / 2, width / 2, height / 2);
  blendMode(SCREEN);
  image(sobelImage, width / 2, height / 2, width / 2, height / 2);
  blendMode(ADD);
  image(bloomImage, width / 2, height / 2, width / 2, height / 2);

  fill(0, 255, 0);
  text("FPS: " + frameRate, 20, 20);
}