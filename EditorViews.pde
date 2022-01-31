class EditorView2d extends Widget {

  private PVector worldLocation = new PVector(0, 0);
  private float viewZoom = 1.0;
  private float wordUnitToPixels = 16;
  private boolean panning = false;

  private PVector panOffset = new PVector(0, 0);

  private PVector selectedPoint = null;
  private PVector lastSelectedPoint = null;
  private boolean removeMode = false;

  public EditorView2d(int minW, int minH) {
    super();
    setMinW(minW);
    setMinH(minH);
    setW(minW);
    setH(minH);
    lastSelectedPoint = island.getPointAt(0);
  }

  public void reset() {
    worldLocation = new PVector(0, 0);
    viewZoom = 1.0;
    wordUnitToPixels = 16;
    panning = false;
    //panOffset = new PVector(0, 0);
    selectedPoint = null;
    lastSelectedPoint = null;
    removeMode = false;
  }

  public void setLastSelectedPoint(PVector p) {
    lastSelectedPoint = p;
  }

  public void setViewZoom(float val) {
    viewZoom = val;
  }
  public float getViewZoom() {
    return viewZoom;
  }
  //public void setPanOffset(PVector p) {
  //  panOffset = p;
  //}
  //public PVector getPanOffset() {
  //  return panOffset;
  //}
  public void setWorldLocation(PVector p) {
    worldLocation=p;
  }
  public PVector getWorldLocation() {
    return worldLocation;
  }

  public void draw(PGraphics g) {
    super.draw(g);
    if (!drawClip(g)) return;
    g.background(255);
    g.pushMatrix();
    translate(getScreenX()+getW()/2.0+worldLocation.x, getScreenY()+getH()/2.0+worldLocation.y);
    scale(viewZoom);

    // draw location gizmo
    g.strokeWeight(4);
    g.stroke(255, 0, 0);
    g.line(0, 0, wordUnitToPixels*2, 0);
    g.stroke(0, 255, 0);
    g.line(0, 0, 0, wordUnitToPixels*2);
    g.strokeWeight(1);

    // draw Island object
    island.draw2d(g);

    //draw selected point
    if (lastSelectedPoint != null) {
      g.noStroke();
      g.fill(255, 255, 0);
      g.ellipse(lastSelectedPoint.x, lastSelectedPoint.y, 16, 16);
    }
    
    // Speed hack, it's not in onMouseMouve because event in processing are blocking by default
    // so the movement isn't fluid.
    // here it's done every frame so framerate will drop but we will se the regeneration of the island;
    if (selectedPoint != null) {
      PVector m = screenToWorld(mouseX, mouseY);
      island.movePoint(selectedPoint, m);
    }

    g.popMatrix();
    g.noClip();
  }

  // WORLD <- TRANSFORM -> Screen+local

  private final PVector screenToWorld(int x, int y) {
    PVector p = new PVector(x, y);
    p.sub(getScreenX()+getW()/2.0, getScreenY()+getH()/2.0);
    p.sub(worldLocation);
    p.div(viewZoom);
    return p;
  }

  private final PVector localToWorld(int x, int y) {
    return screenToWorld(getScreenX()+getX()+x, getScreenY()+getY()+y);
  }

  private final PVector worldToScreen(int x, int y) {
    PVector p = new PVector(x, y);
    p.mult(viewZoom);
    p.add(worldLocation);
    p.add(getScreenX()+getW()/2.0, getScreenY()+getH()/2.0);
    return p;
  }

  private final PVector worldToLocal(int x, int y) {
    return worldToScreen(x, y).sub(getScreenX(), getScreenY());
  }

  // EVENTS
  public void onMouseWheel(int x, int y, int direction) {
    viewZoom -= 0.1*direction;
    if (viewZoom < 0.01) viewZoom = 0.01;
  }

  public void onMouseMove(int oldx, int oldy, int newx, int newy) {
    super.onMouseMove(oldx, oldy, newx, newy);
    if (panning) {
      PVector p = new PVector(getScreenX()+getX()+newx, getScreenY()+getY()+newy);
      p.sub(getScreenX()+getW()/2.0, getScreenY()+getH()/2.0);
      worldLocation = p.add(panOffset);
    }
  }

  public void onMouseDown(int x, int y, int button) {
    super.onMouseDown(x, y, button);
    if (button == CENTER) {
      PVector p = new PVector(getScreenX()+getX()+x, getScreenY()+getY()+y);
      p.sub(getScreenX()+getW()/2.0, getScreenY()+getH()/2.0);
      panOffset = worldLocation.copy().sub(p);
      panning = true;
    } else if (button == LEFT) {
      if (removeMode) {
        for (PVector p : island.getPoints()) {
          PVector m = localToWorld(x, y);
          if ( sq(m.x-p.x)+sq(m.y-p.y) <= 64*viewZoom) {
            island.removePoint(p);
            if (selectedPoint == p)
              selectedPoint = null;
            if (lastSelectedPoint == p);
            lastSelectedPoint = island.getPointAt(0);
            break;
          }
        }
      } else {
        for (PVector p : island.getPoints()) {
          PVector m = localToWorld(x, y);
          if ( sq(m.x-p.x)+sq(m.y-p.y) <= 64*viewZoom) {
            selectedPoint = p;
            lastSelectedPoint = p;
            break;
          }
        }
      }
    } else if (button == RIGHT) {
      PVector m = localToWorld(x, y);
      island.addPoint(m, island.getPoints().indexOf(lastSelectedPoint));
      lastSelectedPoint = m;
    }
  }
  public void onMouseUp(int x, int y, int button) {
    super.onMouseUp(x, y, button);
    panning = false;
    selectedPoint = null;
  }
  public void onMouseExit() {
    super.onMouseExit();
    panning = false;
    removeMode = false;
    selectedPoint = null;
  }

  public void onKeyDown(char c, int code) {
    super.onKeyDown(c, code);
    if (code == SHIFT) {
      removeMode = true;
    }
  }

  public void onKeyUp(char c, int code) {
    super.onKeyUp(c, code);
    removeMode = false;
  }
}


class EditorView3d extends Widget {
  private PGraphics pg;
  private boolean panning = false;
  private boolean rotating = false;
  private PVector worldLocation = new PVector(0, 0);
  private PVector worldRotation = new PVector(PI/4.0, PI/4.0);
  private float viewZoom = 1.0;
  private PVector panOffset = new PVector(0, 0);
  private float wordUnitToPixels = 16;

  public EditorView3d(int minW, int minH) {
    super();
    pg = createGraphics(minW, minH, P3D);
    setMinW(minW);
    setMinH(minH);
    setW(minW);
    setH(minH);
  }

  public void reset() {
    worldLocation = new PVector(0, 0);
    viewZoom = 1.0;
    wordUnitToPixels = 16;
    panning = false;
    panOffset = new PVector(0, 0);
    worldRotation = new PVector(PI/4.0, PI/4.0);
    rotating = false;
  }

  public void setViewZoom(float val) {
    viewZoom = val;
  }
  public float getViewZoom() {
    return viewZoom;
  }
  public void setPanOffset(PVector p) {
    panOffset = p;
  }
  public PVector getPanOffset() {
    return panOffset;
  }
  public void setWorldLocation(PVector p) {
    worldLocation=p;
  }
  public PVector getWorldLocation() {
    return worldLocation;
  }
  public void setWorldRotation(PVector p) {
    worldRotation = p;
  }
  public PVector getWorldRotation() {
    return worldRotation;
  }

  public void draw(PGraphics g) {
    super.draw(g);
    if (!drawClip(g)) return;
    pg.beginDraw();
    pg.background(0);
    pg.camera(getW()/2.0, getH()/2.0, ((getH()/2.0) / tan(PI*30.0 / 180.0))*viewZoom, getW()/2.0, getH()/2.0, 0, 0, 1, 0);
    pg.translate(getW()/2.0+worldLocation.x, getH()/2.0+worldLocation.y, 0);
    // Setup ligthinpg.
    pg.directionalLight(255, 255, 255, 1, 1, 0);
    pg.ambientLight(100, 100, 100);
    // Rotate scene
    pg.rotateX(worldRotation.x);
    pg.rotateZ(worldRotation.y);

    // draw location gizmo
    pg.strokeWeight(4);
    pg.stroke(255, 0, 0);
    pg.line(0, 0, 0, wordUnitToPixels*2, 0, 0);
    pg.stroke(0, 255, 0);
    pg.line(0, 0, 0, 0, wordUnitToPixels*2, 0);
    pg.stroke(0, 0, 255);
    pg.line(0, 0, 0, 0, 0, wordUnitToPixels*2);
    pg.strokeWeight(1);

    // draw Island object
    island.draw3d(pg);

    pg.endDraw();
    g.image(pg, getScreenX(), getScreenY());
    g.noClip();
  }

  public void resize(int nw, int nh) {
    super.resize(nw, nh);
    pg.setSize(nw, nh);
  }

  // WORLD <- TRANSFORM -> Screen+local
  private final PVector screenToWorld(int x, int y) {
    PVector p = new PVector(x, y);
    p.sub(getScreenX()+getW()/2.0, getScreenY()+getH()/2.0);
    return p;
  }

  private final PVector localToWorld(int x, int y) {
    return screenToWorld(getScreenX()+getX()+x, getScreenY()+getY()+y);
  }

  private final PVector worldToScreen(int x, int y) {
    PVector p = new PVector(x, y);
    p.add(getScreenX()+getW()/2.0, getScreenY()+getH()/2.0);
    return p;
  }

  private final PVector worldToLocal(int x, int y) {
    return worldToScreen(x, y).sub(getScreenX()+getX(), getScreenY()+getY());
  }

  // EVENTS
  public void onMouseWheel(int x, int y, int direction) {
    viewZoom -= 0.1*direction;
    if (viewZoom < 0.01) viewZoom = 0.01;
  }
  public void onMouseMove(int oldx, int oldy, int newx, int newy) {
    if (panning) {
      worldLocation = localToWorld(newx, newy).sub(panOffset);
    } else if (rotating) {
      worldRotation.x += (newy-oldy)*0.001;
      worldRotation.y += (newx-oldx)*0.001;
    }
  }
  public void onMouseDown(int x, int y, int button) {
    if (button == CENTER) {
      panOffset = localToWorld(x, y).sub(worldLocation.x, worldLocation.y);
      panning = true;
    } else if (button == RIGHT) {
      rotating = true;
    }
  }
  public void onMouseUp(int x, int y, int button) {
    panning = false;
    rotating = false;
  }
  public void onMouseExit() {
    panning = false;
    rotating = false;
  }
}
