Island island;

// UI elements
CompositeWidget UIRoot;

SplitWidget topContent;

EditorView2d view2d;
EditorView3d view3d;

CheckBox drawGridCheckBox;
CheckBox borderCheckBox;
CheckBox fillCheckBox;
CheckBox cornersCheckBox;

Slider cellSizeSlider;
Slider offsetSlider;

TextBox numLayerTextBox;


int prevWidth;
int prevHeight;

void setup() {
  // ------------------------------------- BASE -----------------------------------
  size(1280, 720, P2D);
  surface.setResizable(true);
  smooth(0);

  // ------------------------------------ Island init ------------------------------
  island = new Island();

  //------------------------------------------ UI ----------------------------------
  prevWidth = width;
  prevHeight = height;

  UIRoot = new CompositeWidget();
  UIRoot.setW(width);
  UIRoot.setH(height);

  topContent = new SplitWidget(SplitWidget.HORIZONTAL);
  topContent.setW(width);
  topContent.setH(height);
  topContent.setOffset(0.05);

  CompositeWidget topBar = new CompositeWidget();
  topBar.setLayout(new StackLayout(StackLayout.HORIZONTAL, true));
  final Button newButton = new Button("New");
  topBar.addChild(newButton);
  final Button loadButton = new Button("Load");
  topBar.addChild(loadButton);
  final Button saveButton = new Button("Save");
  topBar.addChild(saveButton);
  final Button showWindowButton = new Button("Show help");
  topContent.addChild(topBar);

  SplitWidget content = new SplitWidget(SplitWidget.VERTICAL);
  content.setOffset(0.75);
  topContent.addChild(content);

  // VIEWS
  SplitWidget views = new SplitWidget(SplitWidget.HORIZONTAL);
  content.addChild(views);

  //2d view
  CompositeWidget view2dHolder = new CompositeWidget();
  view2dHolder.setLayout(new GridLayout(1, 1));
  views.addChild(view2dHolder);

  view2d = new EditorView2d(100, 100);
  view2dHolder.addChild(view2d);

  // 3d view
  CompositeWidget view3dHolder = new CompositeWidget();
  view3dHolder.setLayout(new GridLayout(1, 1));
  views.addChild(view3dHolder);

  view3d = new EditorView3d(100, 100);
  view3dHolder.addChild(view3d);

  // PARAMS
  CompositeWidget params = new CompositeWidget();
  params.setLayout(new StackLayout(StackLayout.VERTICAL, true));
  content.addChild(params);

  Label paramLabel = new Label("ISLAND OPTIONS");
  params.addChild(paramLabel);

  final Button clearButton = new Button("RESET");
  params.addChild(clearButton);
  offsetSlider = new Slider(100, -1, 1, Slider.HORIZONTAL);
  offsetSlider.setText("Offset");
  offsetSlider.setVal(1.0);
  params.addChild(offsetSlider);

  numLayerTextBox = new TextBox(150, "num layer");
  params.addChild(numLayerTextBox);

  cellSizeSlider = new Slider(200, 2, 32, Slider.HORIZONTAL);
  cellSizeSlider.setText("cell size");
  cellSizeSlider.setVal(16.0);
  params.addChild(cellSizeSlider);
  drawGridCheckBox = new CheckBox("Draw grid");
  drawGridCheckBox.setChecked(true);
  params.addChild(drawGridCheckBox);
  borderCheckBox = new CheckBox("Generate borders");
  params.addChild(borderCheckBox);
  fillCheckBox = new CheckBox("Generate fill");
  params.addChild(fillCheckBox);
  cornersCheckBox = new CheckBox("Use Corners");
  params.addChild(cornersCheckBox);

  // help window
  final Window w = new Window(100, 100, 200, 400);
  w.setTitle("Help");
  w.setLayout(new StackLayout(StackLayout.VERTICAL, true));

  // ------------------  help text  ---------------------------
  // Controls 2d view
  Label control2dTitle = new Label("Controls: 2d view");
  control2dTitle.setTextColor(color(0, 255, 0));
  w.addChild(control2dTitle);

  Label control2d = new Label(
    "* left click to select and move a point\n"+
    "* SHIFT+left click to remove a point\n"+
    "* right click to add a point after the selected point (the one in yellow)\n"+
    "* middle mouse button to pan the view\n"+
    "* mouse wheel to zoom in / zoom out");
  w.addChild(control2d);

  // Controls 3d view
  Label control3dTitle = new Label("Controls: 3d view");
  control3dTitle.setTextColor(color(0, 255, 0));
  w.addChild(control3dTitle);

  Label control3d = new Label(
    "* mouse wheel or left click and drag to zoom in / zoom out\n"+
    "* right mouse button to rotate the view\n"+
    "* middle mouse button to pan the view");
  w.addChild(control3d);

  // About
  Label aboutLabel = new Label("About");
  aboutLabel.setTextColor(color(255, 0, 0));
  w.addChild(aboutLabel);

  Label author = new Label("Made by JAFFUER Pierre using Processing3.");
  w.addChild(author);
  w.calculateMinimumSize();
  w.resize(w.getMinW(), w.getMinH());

  //-------------------------------------- UI Action events ------------------------------------
  
  loadButton.addActionListener(new ActionListener(){
    public void onMouseUp(int x, int y, int button) {
      selectInput("Select a scene to load.", "loadScene");
    }
  });
  
  saveButton.addActionListener(new ActionListener(){
    public void onMouseUp(int x, int y, int button) {
      selectOutput("Select a file to save.", "saveScene");
    }
  });
  
  newButton.addActionListener(new ActionListener(){
    public void onMouseUp(int x, int y, int button) {
      drawGridCheckBox.setChecked(true);
      borderCheckBox.setChecked(false);
      fillCheckBox.setChecked(false);
      cornersCheckBox.setChecked(false);
      offsetSlider.setVal(1.0);
      numLayerTextBox.setInsideText("0");
      cellSizeSlider.setVal(16.0);
      view2d.reset();
      view3d.reset();
      island.reset();
      view2d.setLastSelectedPoint(island.getPointAt(0));
    }
  });
  

  clearButton.addActionListener(new ActionListener() {
    public void onMouseUp(int x, int y, int button) {
      // reset ui
      drawGridCheckBox.setChecked(true);
      borderCheckBox.setChecked(false);
      fillCheckBox.setChecked(false);
      cornersCheckBox.setChecked(false);
      offsetSlider.setVal(1.0);
      numLayerTextBox.setInsideText("0");
      cellSizeSlider.setVal(16.0);

      // reset island
      island.setDrawGrid(true);
      island.setGenerateFill(false);
      island.setGenerateBorder(false);
      island.setLayerOffset(1.0);
      island.setNumLayers(0);
      island.setUseCorners(false);
      island.setCellSize(16.0);
    }
  }
  );

  showWindowButton.addActionListener(new ActionListener() {
    public void onMouseUp(int x, int y, int button) {
      w.setVisible(true);
      w.calculateMinimumSize();
      w.resize(w.getMinW(), w.getMinH());
      w.setX(x);
      w.setY(y);
    }
  }
  );

  drawGridCheckBox.addActionListener(new ActionListener() {
    public void onMouseUp(int x, int y, int button) {
      island.setDrawGrid(drawGridCheckBox.getChecked());
    }
  }
  );

  borderCheckBox.addActionListener(new ActionListener() {
    public void onMouseUp(int x, int y, int button) {
      island.setGenerateBorder(borderCheckBox.getChecked());
    }
  }
  );

  fillCheckBox.addActionListener(new ActionListener() {
    public void onMouseUp(int x, int y, int button) {
      island.setGenerateFill(fillCheckBox.getChecked());
    }
  }
  );

  cornersCheckBox.addActionListener(new ActionListener() {
    public void onMouseUp(int x, int y, int button) {
      island.setUseCorners(cornersCheckBox.getChecked());
      numLayerTextBox.setInsideText(str(island.getNumLayers()));
    }
  }
  );

  numLayerTextBox.addActionListener(new ActionListener() {
    public void onKeyDown(char c, int code) {
      if (code == ENTER) {
        try {
          island.setNumLayers(Integer.parseInt(numLayerTextBox.getInsideText()));
          numLayerTextBox.setInsideText(str(island.getNumLayers()));
        } 
        catch (Exception e) {
        }
      }
    }
  }
  );

  offsetSlider.addActionListener(new ActionListener() {
    public void onMouseMove(int oldx, int oldy, int newx, int newy) {
      island.setLayerOffset(offsetSlider.getVal());
    }
    public void onMouseDown(int x, int y, int button) {
      island.setLayerOffset(offsetSlider.getVal());
    }
  }
  );

  cellSizeSlider.addActionListener(new ActionListener() {
    public void onMouseMove(int oldx, int oldy, int newx, int newy) {
      island.setCellSize(cellSizeSlider.getVal());
    }
    public void onMouseDown(int x, int y, int button) {
      island.setCellSize(cellSizeSlider.getVal());
    }
  }
  );

  topBar.addChild(showWindowButton);
  UIRoot.addChild(w);
  UIRoot.addChild(topContent);
}

void draw() {
  if (prevWidth != width || prevHeight != height) {
    prevWidth = width;
    prevHeight = height;
    UIRoot.resize(width, height);
    topContent.resize(width, height);
  }
  background(255);
  UIRoot.draw(this.g);
}

void mousePressed() {
  UIRoot.onMouseDown( mouseX, mouseY, mouseButton);
}

void mouseReleased() {
  UIRoot.onMouseUp(mouseX, mouseY, mouseButton);
}

void mouseMoved() {
  UIRoot.onMouseMove(pmouseX, pmouseY, mouseX, mouseY);
}

void mouseDragged() {
  UIRoot.onMouseMove(pmouseX, pmouseY, mouseX, mouseY);
}

void keyPressed() {
  UIRoot.onKeyDown(key, keyCode);
}

void keyReleased() {
  UIRoot.onKeyUp(key, keyCode);
}

void mouseWheel(MouseEvent event) {
  UIRoot.onMouseWheel(mouseX, mouseY, event.getCount());
}

public void rebuild(){
  island.rebuild();  
}
