final class Island {
  private final ArrayList<PVector> points = new ArrayList<PVector>();
  private float cellSize = 16;
  private float layerOffset = 1.0;
  private int numLayers = 0;
  private int[] cells;
  private int nx = 0;
  private int ny = 0;
  private Rectangle bound = new Rectangle();
  private final ArrayList<Integer> layerQueue = new ArrayList<Integer>();

  private boolean generateBorder = false;
  private boolean generateFill = false;
  private boolean useCorners = false;

  private boolean drawGrid = true;

  public Island() {
    points.add(new PVector(0, 128));
    points.add(new PVector(128, -128));
    points.add(new PVector(-128, -128));
    rebuild();
  }
  
  public ArrayList<Integer> getLayerQueue(){return layerQueue;}

  public final void addPoint(PVector point, int pos) {
    points.add(pos, point);
    rebuild();
  }

  public final void removePoint(PVector point) {
    if (points.size()>3){
      points.remove(point);
      rebuild();
    }
  }
  
  public final void movePoint(PVector point, PVector location){
    point.set(location.x, location.y);
    rebuild();
  }

  public final float getLayerOffset() {
    return layerOffset;
  }
  public final void setLayerOffset(float val) {
    layerOffset = clamp(val, -1.0, 1.0);
  }
  public final float getCellSize() {
    return cellSize;
  }
  public final void setCellSize(float val) {
    cellSize = val <= 0 ? 0.01 : val; 
    rebuild();
  }
  public final int getNumLayers() {
    return numLayers;
  }
  public final void setNumLayers(int num) {
    numLayers = num; 
    rebuild();
  }
  public final int[] getCells() {
    return cells;
  }
  public final int getCellAt(int index) {
    return cells[index];
  }
  public final int getNx() {
    return nx;
  }
  public final int getNy() {
    return ny;
  }
  public final int getCellsLength() {
    return cells.length;
  }
  public final ArrayList<PVector> getPoints() {
    return points;
  }
  public final PVector getPointAt(int index) {
    return points.get(index);
  }
  public final int getPointsSize() {
    return points.size();
  }
  public final Rectangle getBound() {
    return bound;
  }
  public final boolean doesGenerateBorder() {
    return generateBorder;
  }
  public final boolean doesGenerateFill() {
    return generateFill;
  }
  public final boolean doesUseCorners() {
    return useCorners;
  }
  public final void setGenerateBorder(boolean val) {
    generateBorder= val; 
    rebuild();
  }
  public final void setGenerateFill(boolean val) {
    generateFill=val; 
    rebuild();
  }
  public final void setUseCorners(boolean val) {
    useCorners=val; 
    rebuild();
  }
  public final boolean doesDrawGrid() {
    return drawGrid;
  }
  public final void setDrawGrid(boolean val) {
    drawGrid = val;
  }

  public final void reset() {
    points.clear();
    layerQueue.clear();
    points.add(new PVector(0, 128));
    points.add(new PVector(128, -128));
    points.add(new PVector(-128, -128));
    drawGrid = true;
    generateBorder = false;
    generateFill = false;
    useCorners = false;
    layerOffset = 1.0;
    numLayers = 0;
    cellSize = 16;
    rebuild();
  }

  public void draw2d(PGraphics g) {

    // draw cells
    g.noStroke();
    g.rectMode(CORNER);
    for (int y=0; y < ny; y++) {
    for (int x=0; x < nx; x++) {
      if (cells[y*nx+x] == 1) {
        g.fill(0, 100, 0);
      } else if (cells[y*nx+x] == 2) {
        g.fill(150, 0, 255);
      } else if (cells[y*nx+x] < 0) {
        g.fill(map(-cells[y*nx+x], 0, numLayers, 50, 255));
      } else {
        continue;
      }
      g.rect(bound.x+x*cellSize, bound.y+y*cellSize, cellSize, cellSize);
    }
  }

    // draw polygon
    g.noFill();
    g.stroke(0);
    g.beginShape();
    for (PVector p : points) {
      g.vertex(p.x, p.y);
    }
    g.endShape(CLOSE);

    // draw points
    g.noStroke();
    for (PVector p : points) {
      g.fill(0);
      g.ellipse(p.x, p.y, 16, 16);
    }


    // draw grid
    if (drawGrid) {
      g.stroke(200);
      for (int j = 0; j <= ny; j++) {
        g.line(bound.x, bound.y+j*cellSize, bound.x+nx*cellSize, bound.y+j*cellSize);
      }
      for (int i = 0; i <= nx; i++) {
        g.line(bound.x+i*cellSize, bound.y, bound.x+i*cellSize, bound.y+ny*cellSize);
      }
    }



    // draw bound
    g.stroke(255, 0, 0);
    g.noFill();
    g.rectMode(CORNER);
    g.rect(bound.x, bound.y, bound.w, bound.h);

    // draw location gizmo
    g.strokeWeight(4);
    g.stroke(255, 0, 0);
    g.line(0, 0, 16, 0);
    g.stroke(0, 255, 0);
    g.line(0, 0, 0, 16);
    g.strokeWeight(1);
  }

  public void draw3d(PGraphics g) {
    // draw cells
    g.noStroke();
    for (int y=0; y < ny; y++) {
      for (int x=0; x < nx; x++) {
        if (cells[y*nx+x] == 1) {
          g.fill(0, 100, 0);
        } else if (cells[y*nx+x] == 2) {
          g.fill(125, 0, 255);
        } else if (cells[y*nx+x] < 0) {
          g.fill(map(-cells[y*nx+x], 0, numLayers, 50, 255));
        } else {
          continue;
        }
        g.pushMatrix();
        if (cells[y*nx+x] == 2)
          g.translate(bound.x+x*cellSize+cellSize/2.0, bound.y+y*cellSize+cellSize/2.0, numLayers*layerOffset*cellSize);
        else if (cells[y*nx+x] < 0)
          g.translate(bound.x+x*cellSize+cellSize/2.0, bound.y+y*cellSize+cellSize/2.0, -cells[y*nx+x]*layerOffset*cellSize);
        else 
        g.translate(bound.x+x*cellSize+cellSize/2.0, bound.y+y*cellSize+cellSize/2.0, 0);
        g.box(cellSize);
        g.popMatrix();
      }
    }


    // draw polygon
    g.noFill();
    g.stroke(255);
    g.beginShape();
    for (PVector p : points) {
      g.vertex(p.x, p.y, 0);
    }
    g.endShape(CLOSE);

    // draw points
    g.noStroke();
    g.fill(255);
    for (PVector p : points) {
      g.pushMatrix();
      g.translate(p.x, p.y);
      g.sphere(4);
      g.popMatrix();
    }

    // Draw grid
    if (drawGrid) {
      g.stroke(50);

      for (int j = 0; j <= ny; j++) {
        g.line(bound.x, bound.y+j*cellSize, bound.x+nx*cellSize, bound.y+j*cellSize);
      }
      for (int i = 0; i <= nx; i++) {
        g.line(bound.x+i*cellSize, bound.y, bound.x+i*cellSize, bound.y+ny*cellSize);
      }
    }


    // draw bound
    g.stroke(255, 0, 0);
    g.noFill();
    g.beginShape();
    g.vertex(bound.x, bound.y, 0);
    g.vertex(bound.x+bound.w, bound.y, 0);
    g.vertex(bound.x+bound.w, bound.y+bound.h, 0);
    g.vertex(bound.x, bound.y+bound.h, 0);
    g.endShape(CLOSE);

    // draw location gizmo
    g.strokeWeight(4);
    g.stroke(255, 0, 0);
    g.line(0, 0, 0, 16, 0, 0);
    g.stroke(0, 255, 0);
    g.line(0, 0, 0, 0, 16, 0);
    g.stroke(0, 0, 255);
    g.line(0, 0, 0, 0, 0, 16);
    g.strokeWeight(1);
  }


  public final void rebuild() {
    // ------------------------- LOCAL GRID -------------------------------
    // define the cells array
    bound = generateBound();
    nx = round(bound.w / cellSize)+1;
    ny = round(bound.h / cellSize)+1;
    cells = new int[nx*ny];

    // ------------------------ BORDER's CELLS ----------------------------
    layerQueue.clear(); // reset the bevel's starting cells
    if (generateBorder) {
      // Define border cells
      int size = points.size();
      for (int i=0; i < size; i++) {
        PVector p0 = points.get(i);
        PVector p1 = points.get((i+1)%size);
        plotLine((int) ((p0.x-bound.x)/cellSize), (int) ((p0.y-bound.y)/cellSize), (int) ((p1.x-bound.x)/cellSize), (int) ((p1.y-bound.y)/cellSize));
      }
    }

    // ---------------------- FILL CELLS -----------------------------------
    if (generateFill) {
      //flood fill
      ArrayList<Integer> queue = new ArrayList<Integer>();
      int sx = (int) clamp((-bound.x/cellSize), 0, nx-1);
      int sy = (int) clamp((-bound.y/cellSize), 0, ny-1);
      int sindex = sy*nx+sx;
      cells[sindex] = 2;
      queue.add(sindex);
      while (queue.size() > 0) {
        // pop out first elem
        int index = queue.get(0);
        queue.remove(0);

        //get coordinates
        int x = index % nx;
        int y = (index - x) / nx;

        int up = (y-1)*nx+x;
        int down = (y+1)*nx+x;
        int left = y*nx+x-1;
        int right = y*nx+x+1;

        if (x+1 < nx && cells[right] == 0) {
          queue.add(right);
          cells[right] = 2;
        }
        if (x-1 >= 0 && cells[left] == 0) {
          queue.add(left);
          cells[left] = 2;
        }
        if (y-1 >= 0 && cells[up] == 0) {
          queue.add(up);
          cells[up] = 2;
        }
        if (y+1 < ny && cells[down] == 0) {
          queue.add(down);
          cells[down] = 2;
        }
      }
    }

    // --------------------------------------- BEVEL ALGORITHM ------------------------------
    if (numLayers > 1) {
      for (int i=1; i <= numLayers-1; i++) {
        int size = layerQueue.size();

        if (size == 0) {
          numLayers = i-1;
          break;
        }

        for (int j=0; j<size; j++) {
          // pop out first elem
          int index = layerQueue.get(0);
          layerQueue.remove(0);
          //get coordinates
          int x = index % nx;
          int y = (index - x) / nx;

          int up = (y-1)*nx+x;
          int down = (y+1)*nx+x;
          int left = y*nx+x-1;
          int right = y*nx+x+1;

          if (x+1 < nx && cells[right] == 2) {
            layerQueue.add(right);
            cells[right] = -1*i;
          }
          if (x-1 >= 0 && cells[left] == 2) {
            layerQueue.add(left);
            cells[left] = -1*i;
          }
          if (y-1 >= 0 && cells[up] == 2) {
            layerQueue.add(up);
            cells[up] = -1*i;
          }
          if (y+1 < ny && cells[down] == 2) {
            layerQueue.add(down);
            cells[down] = -1*i;
          }

          if (useCorners) {
            int upRight = (y-1)*nx+x+1;
            int upLeft = (y-1)*nx+x-1;
            int downRight = (y+1)*nx+x+1;
            int downLeft = (y+1)*nx+x-1;

            if (x+1 < nx && y+1 < ny && cells[downRight] == 2) {
              layerQueue.add(downRight);
              cells[downRight] = -1*i;
            }
            if (x-1 >= 0 && y+1 < ny && cells[downLeft] == 2) {
              layerQueue.add(downLeft);
              cells[downLeft] = -1*i;
            }
            if (x+1 < nx && y-1 >= 0 && cells[upRight] == 2) {
              layerQueue.add(upRight);
              cells[upRight] = -1*i;
            }
            if (x-1 >= 0 && y-1 >= 0 && cells[upLeft] == 2) {
              layerQueue.add(upLeft);
              cells[upLeft] = -1*i;
            }
          }
        }
      }
    }
  }

  // calculate the local AABB
  private final Rectangle generateBound() {
    Rectangle bound = new Rectangle();
    PVector upperLeft, lowerRight;
    upperLeft = new PVector(points.get(0).x, points.get(0).y);
    lowerRight = new PVector(points.get(0).x, points.get(0).y);
    for (PVector p : points) {
      if (p.x < upperLeft.x) upperLeft.x = p.x;
      if (p.y < upperLeft.y) upperLeft.y = p.y;
      if (p.x > lowerRight.x) lowerRight.x = p.x;
      if (p.y > lowerRight.y) lowerRight.y = p.y;
    }
    bound.x = upperLeft.x;
    bound.y = upperLeft.y;
    bound.w = lowerRight.x - upperLeft.x;
    bound.h = lowerRight.y - upperLeft.y;
    return bound;
  }

  // draw a line using bresenham's line algorithm
  private final void plotLine(int x0, int y0, int x1, int y1) {
    int dx = abs(x1-x0);
    int sx = x0 < x1 ? 1 : -1;
    int dy = -abs(y1-y0);
    int sy = y0 < y1 ? 1 : -1;
    int err = dx+dy;
    while (true) {
      cells[y0 * nx + x0] = 1;
      layerQueue.add(y0 * nx + x0); // define the bevel's starting cells
      if (x0 == x1 && y0 == y1) break;
      int e2 = 2*err;
      if (e2 >= dy) {
        err += dy;
        x0 += sx;
      }
      if (e2 <= dx) {
        err += dx;
        y0 += sy;
      }
    }
  }
  
}
