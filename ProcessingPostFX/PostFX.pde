import java.nio.file.Path; //<>//
import java.nio.file.Paths;

public class PostFX
{
  private final int PASS_NUMBER = 2;
  private final Path SHADER_PATH = Paths.get(sketchPath(), "shader");

  private int width;
  private int height;
  private int[] resolution;

  private int passIndex = -1;

  // shaders
  private PShader brightPassShader;
  private PShader blurShader;
  private PShader sobelShader;
  private PShader toonShader;

  // frameBuffer
  private PGraphics[] passBuffers;

  public PostFX(int width, int height)
  {
    this.width = width;
    this.height = height;

    resolution = new int[] {width, height};

    // init temp pass buffer
    passBuffers = new PGraphics[PASS_NUMBER];
    for (int i = 0; i < passBuffers.length; i++)
    {
      passBuffers[i] = createGraphics(width, height, P2D);
      passBuffers[i].noSmooth();
    }

    // load shaders
    loadShaders();
  }

  private void loadShaders()
  {
    brightPassShader = loadShader(Paths.get(SHADER_PATH.toString(), "brightPassFrag.glsl").toString());
    blurShader = loadShader(Paths.get(SHADER_PATH.toString(), "blurFrag.glsl").toString());
    sobelShader = loadShader(Paths.get(SHADER_PATH.toString(), "sobelFrag.glsl").toString());
    toonShader = loadShader(Paths.get(SHADER_PATH.toString(), "toonFrag.glsl").toString());
  }

  private void increasePass()
  {
    passIndex = (passIndex + 1) % passBuffers.length;
  }

  private PGraphics getNextPass()
  {
    int nextIndex = (passIndex + 1) % passBuffers.length;
    return passBuffers[nextIndex];
  }

  private PGraphics getCurrentPass()
  {
    return passBuffers[passIndex];
  }

  private void clearPass(PGraphics pass)
  {
    // clear pass buffer
    pass.beginDraw();
    pass.background(0, 0);
    pass.resetShader();
    pass.endDraw();
  }

  public PostFX filter(PGraphics pg)
  {
    PGraphics pass = getNextPass();
    clearPass(pass);

    pass.beginDraw();
    pass.image(pg, 0, 0);
    pass.endDraw();

    increasePass();
    return this;
  }

  public PGraphics close()
  {
    return getCurrentPass();
  }

  public PGraphics close(PGraphics result)
  {
    clearPass(result);

    result.beginDraw();
    result.image(getCurrentPass(), 0, 0);
    result.endDraw();

    return getCurrentPass();
  }

  public PostFX brightPass(float luminanceTreshold)
  {
    PGraphics pass = getNextPass();
    clearPass(pass);

    brightPassShader.set("brightPassThreshold", luminanceTreshold);

    pass.beginDraw();
    pass.shader(brightPassShader);
    pass.image(getCurrentPass(), 0, 0);
    pass.endDraw();

    increasePass();

    return this;
  }

  public PostFX blur(int blurSize, float sigma, boolean horizonatal)
  {
    PGraphics pass = getNextPass();
    clearPass(pass);

    blurShader.set("blurSize", blurSize);
    blurShader.set("sigma", sigma);
    blurShader.set("horizontalPass", horizonatal ? 1 : 0);

    pass.beginDraw();
    pass.shader(blurShader);
    pass.image(getCurrentPass(), 0, 0);
    pass.endDraw();

    increasePass();

    return this;
  }

  public PostFX sobel()
  {
    PGraphics pass = getNextPass();
    clearPass(pass);

    sobelShader.set("resolution", resolution);

    pass.beginDraw();
    pass.shader(sobelShader);
    pass.image(getCurrentPass(), 0, 0);
    pass.endDraw();

    increasePass();

    return this;
  }

  public PostFX toon()
  {
    PGraphics pass = getNextPass();
    clearPass(pass);

    toonShader.set("resolution", resolution);

    pass.beginDraw();
    pass.shader(toonShader);
    pass.image(getCurrentPass(), 0, 0);
    pass.endDraw();

    increasePass();

    return this;
  }
}