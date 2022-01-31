void loadScene(File selection){
  if(selection == null) return;
  String[] lines = loadStrings(selection.getAbsolutePath());
  // number of points
  int n = Integer.parseInt(lines[0]);
  island.getPoints().clear();
  for(int i=0; i < n; i++){
    String[] coords = split(lines[i+1], ',');
    float x = Float.parseFloat(coords[0]);
    float y = Float.parseFloat(coords[1]);
    island.getPoints().add(new PVector(x, y));
  }
   view2d.setLastSelectedPoint(island.getPointAt(0));
  
  // checkboxes
  borderCheckBox.setChecked(Boolean.parseBoolean(lines[n+1]));
  fillCheckBox.setChecked(Boolean.parseBoolean(lines[n+2]));
  cornersCheckBox.setChecked(Boolean.parseBoolean(lines[n+3]));
  drawGridCheckBox.setChecked(Boolean.parseBoolean(lines[n+4]));
  
  island.setGenerateBorder(borderCheckBox.getChecked());
  island.setGenerateFill(fillCheckBox.getChecked());
  island.setUseCorners(cornersCheckBox.getChecked());
  island.setDrawGrid(drawGridCheckBox.getChecked());
  
  // Sliders
  cellSizeSlider.setVal(Float.parseFloat(lines[n+5]));
  offsetSlider.setVal(Float.parseFloat(lines[n+6]));
  numLayerTextBox.setInsideText(lines[n+7]);
  
  island.setCellSize(cellSizeSlider.getVal());
  island.setLayerOffset(offsetSlider.getVal());
  island.setNumLayers(Integer.parseInt(numLayerTextBox.getInsideText()));
  
  // transforms
  view2d.setViewZoom(Float.parseFloat(lines[n+8]));
  view3d.setViewZoom(Float.parseFloat(lines[n+9]));
  view2d.setWorldLocation(new PVector(Float.parseFloat(lines[n+10]), Float.parseFloat(lines[n+11])));
  view3d.setWorldLocation(new PVector(Float.parseFloat(lines[n+12]), Float.parseFloat(lines[n+13])));
  view3d.setWorldRotation(new PVector(Float.parseFloat(lines[n+14]), Float.parseFloat(lines[n+15])));
  
  island.rebuild();
  
}

void saveScene(File selection){
    if(selection == null) return;
    
    int n = island.getPointsSize();
    String[] lines = new String[15+n+1];
    // number of points
    lines[0] = str(n);
    
    // x,y per line
    for(int i=0; i < n; i++){
      PVector p = island.getPointAt(i);
      lines[i+1] = str(p.x)+","+str(p.y);  
    }
    
    // checkboxes
    lines[n+1] = str(borderCheckBox.getChecked());
    lines[n+2] = str(fillCheckBox.getChecked());
    lines[n+3] = str(cornersCheckBox.getChecked());
    lines[n+4] = str(drawGridCheckBox.getChecked());
    
    // Sliders
    lines[n+5] = str(island.getCellSize());
    lines[n+6] = str(island.getLayerOffset());
    lines[n+7] = str(island.getNumLayers());
    
    // transforms
    lines[n+8] = str(view2d.getViewZoom());
    lines[n+9] = str(view3d.getViewZoom());
    lines[n+10] = str(view2d.getWorldLocation().x);
    lines[n+11] = str(view2d.getWorldLocation().y);
    lines[n+12] = str(view3d.getWorldLocation().x);
    lines[n+13] = str(view3d.getWorldLocation().x);
    lines[n+14] = str(view3d.getWorldRotation().x);
    lines[n+15] = str(view3d.getWorldRotation().y);
    saveStrings(selection.getAbsolutePath(), lines);
}
