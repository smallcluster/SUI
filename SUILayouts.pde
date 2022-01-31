class GridLayout extends Layout {

  private int rows = 1;
  private int columns = 1;
  
  GridLayout(int rows, int columns) {
    super();
    this.rows = rows;
    this.columns = columns;
  }
  
  public void setRows(int rows){
    this.rows = rows;
    rebuild();
  }
  public void setColumns(int columns){
    this.columns = columns;
    rebuild();
  }
  
  public int getRows() {return rows;}
  public int getColumns() {return columns;}

  public void rebuild() {
    if (getParentWidget() == null) return;
    
    // define the minimum width
    int minW = 0;
    int minH = 0;
    
    int w = getParentWidget().getW() / columns;
    int h = getParentWidget().getH() / rows;
    
    int n = getParentWidget().getChildren().size();
    
    for (int i=0; i < n; i++) {
      int x = i % columns;
      int y = (i-x)/columns;
      Widget child = getParentWidget().getChildren().get(i);
      child.setX(x*w);
      child.setY(y*h);
      child.resize(w,h);
    }
  }
}

public final class SplitLayout extends Layout {
  SplitLayout() {
    super();
  }
  public void rebuild() {
    if (getParentWidget() == null) return;
    SplitWidget parentWidget = (SplitWidget) getParentWidget();
    int n = parentWidget.getChildren().size();
    
    if(n >= 1){
      Widget child = parentWidget.getChildren().get(0);
      if(parentWidget.getAxis() == parentWidget.HORIZONTAL){
        child.setX(0);
        child.setY(0);
        child.resize(parentWidget.getW(), (int) (parentWidget.getH()*parentWidget.getOffset())-parentWidget.getSliderWidth()/2);
      }else{
        child.setY(0);
        child.setX(0);
        child.resize((int)(parentWidget.getW()*parentWidget.getOffset())-parentWidget.getSliderWidth()/2, parentWidget.getH());
      }
    }
    
    if(n == 2){
      Widget child = parentWidget.getChildren().get(1);
      if(parentWidget.getAxis() == parentWidget.HORIZONTAL){
        child.setX(0);
        child.setY((int) (parentWidget.getH()*parentWidget.getOffset())+parentWidget.getSliderWidth()/2);
        child.resize(parentWidget.getW(), (int)(parentWidget.getH()*(1-parentWidget.getOffset()))-parentWidget.getSliderWidth()/2);
      } else {
        child.setY(0);
        child.setX((int) (parentWidget.getW()*parentWidget.getOffset())+parentWidget.getSliderWidth()/2);
        child.resize((int)(parentWidget.getW()*(1-parentWidget.getOffset()))-parentWidget.getSliderWidth()/2, parentWidget.getH());
      }
    }
  }
}

class StackLayout extends Layout{
  public static final int VERTICAL = 0;
  public static final int HORIZONTAL = 1;
  
  private int axis = HORIZONTAL;
  private boolean expend = true;
  
  StackLayout(int axis, boolean expend) {
    super();
    this.axis = axis;
    this.expend = expend;
  }
  
  public void setExpend(boolean v){expend = v;}
  
  public void rebuild() {
    if (getParentWidget() == null) return;
    
    int dist = 0;
    
    for (Widget w : getParentWidget().getChildren()) {
      w.calculateMinimumSize();
      if(!expend) w.resize(w.getMinW(), w.getMinH());
      
      if(axis == HORIZONTAL){
        if(expend)
          w.resize(w.getMinW(), max(getParentWidget().getH(), w.getMinH()));
        w.setX(dist);
        dist += w.getW();
      } else {
        if(expend)
          w.resize(max(getParentWidget().getW(), w.getMinH()), w.getMinH());
        w.setY(dist);
        dist += w.getH();
      }
    }
  }
}
