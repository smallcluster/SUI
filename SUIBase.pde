// Base Widget
color SUIWidgetFillColor = color(30);
color SUIWidgetStrokeColor = SUIWidgetFillColor;
color SUITextColor = color(255);
color SUIHandleColor = color(70);
color SUIFocusStrokeColor = color(255, 255, 0);

// Buttons
color SUIButtonColor = color(85);
color SUIButtonHoverColor = color(95);
color SUIButtonPressColor = color(105);

// Slider
color SUISliderBgColor = color(0);
color SUISliderColor = color(85);

// Window
color SUIWindowFillColor = color(45);
color SUIWindowStrokeColor = SUIHandleColor;

//TextBox
color SUITextBoxBgColor = color(0);

class ActionListener {
  public void onMouseDown(int x, int y, int button){}
  public void onMouseUp(int x, int y, int button){}
  public void onMouseMove(int oldx, int oldy, int newx, int newy){}
  public void onMouseEnter(){}
  public void onMouseExit(){}
  public void onKeyDown(char c, int code){}
  public void onKeyUp(char c, int code){}
  public void resize(int nw, int nh){}
  public void onMouseWheel(int x, int y, int direction){}
}

class Layout {
  // Un layout n'est utile que sur un widget qui peut contenir plusieurs widgets
  private CompositeWidget parentWidget = null;
  Layout() {}
  public final void setParentWidget(CompositeWidget parentWidget) {
    this.parentWidget = parentWidget;
  }

  public void rebuild() {
    if (parentWidget == null) return;
    for (Widget w : parentWidget.getChildren()) {
      w.rebuild();
    }
  }

  public final CompositeWidget getParentWidget() {
    return parentWidget;
  }
}

class Widget {
  // A composite widget should have a layout object to define it's structure
  private Layout layout = new Layout();

  // parent widget
  private Widget parent = null;
  // position relative to the parent
  private int x = 0;
  private int y = 0;
  // width and height
  private int w = 100;
  private int h = 100;
  private int minW = 0;
  private int minH = 0;
  // List of action listener
  private ArrayList<ActionListener> actions = new ArrayList<ActionListener>();
  // If this widget can be in focus
  private boolean canFocus = true;
  // Do not draw and ingore input
  private boolean visible = true;

  // Widget color style
  private boolean drawFill = true;
  private boolean drawStroke = true;
  private int strokeWeight = 1;
  private color fillColor = SUIWidgetFillColor;
  private color strokeColor = SUIWidgetStrokeColor;
  private color textColor = SUITextColor;
  private PFont textFont = createFont("Arial", 12);

  // Constructor
  public Widget() {
  }

  // --------------------------------------------- getters and setters -----------------------------------------------------
  public  Layout getLayout() {
    return layout;
  }
  
  public void setCanFocus(boolean b) {
    canFocus = b;
  }
  public  void setLayout(Layout layout) {
    this.layout =layout;
  }
  // coords
  public final int getScreenX() {
    return parent == null ? x : x+parent.getScreenX();
  }
  public final int getScreenY() {
    return parent == null ? y : y+parent.getScreenY();
  }
  public final int getX() {
    return x;
  }
  public final int getY() {
    return y;
  }
  public final void setX(int x) {
    this.x = x;
  }
  public final void setY(int y) {
    this.y = y;
  }
  // dims
  public final int getW() {
    return w;
  }
  public final int getH() {
    return h;
  }
  public final void setW(int w) {
    this.w = w;
  }
  public final void setH(int h) {
    this.h = h;
  }
  public final int getMinW() {
    return minW;
  }
  public final int getMinH() {
    return minH;
  }
  public final void setMinW(int w) {
    minW = w;
  }
  public final void setMinH(int h) {
    minH = h;
  }

  // Style
  public final color getFillColor() {
    return fillColor;
  }
  public final color getStrokeColor() {
    return strokeColor;
  }
  public final color getTextColor() {
    return textColor;
  }
  public final PFont getTextFont() {
    return textFont;
  }
  public final int getStrokeWeight() {
    return strokeWeight;
  }
  public final boolean doesDrawFill() {
    return drawFill;
  }
  public final boolean doesDrawStroke() {
    return drawStroke;
  }
  public final void setFillColor(color fillColor) {
    this.fillColor = fillColor;
  }
  public final void setStrokeColor(color strokeColor) {
    this.strokeColor = strokeColor;
  }
  public final void setTextColor(color textColor) {
    this.textColor = textColor;
  }
  public final void setTextFont(PFont font) { 
    textFont = font;
  }
  public final void setStrokeWeight(int weight) { 
    strokeWeight = weight;
  }
  public final void setDrawFill(boolean v) {
    drawFill = v;
  }
  public final void setDrawStroke(boolean v) {
    drawStroke = v;
  }

  // visibility
  public final boolean isVisible() {
    return visible;
  }
  public final void setVisible(boolean visible) {
    this.visible = visible;
  }

  // parent
  public final boolean hasParent() {
    return parent != null;
  }
  public final Widget getParent() {
    return parent;
  }
  public final void setParent(Widget parent) {
    this.parent = parent;
  }

  // Action listeners
  public final void addActionListener(ActionListener action) {
    actions.add(action);
  }

  // coords are in relative
  public final boolean coordsInside(int x, int y) {
    return (x >= this.x && x <= this.x+w && y >= this.y && y <= this.y+h);
  }

  public void rebuild() {
    layout.rebuild();
  }

  // ***********************************  OVERRIDES ***************************************
  public void getFocus(Widget widget) {
    if (parent != null) parent.getFocus(widget);
  }

  public void draw(PGraphics g) {
    if (!visible) return;
    // clip rendering
    if (!drawClip(g)) return;
    if (drawFill) g.fill(fillColor);
    else g.noFill();
    g.strokeWeight(strokeWeight);
    if (drawStroke) g.stroke(strokeColor);
    else g.noStroke();
    g.rectMode(CORNER);
    g.rect(getScreenX(), getScreenY(), w, h);

    // unclip rendering
    g.noClip();
  }

  // Needed for layout placing
  public void calculateMinimumSize() {
  }

  // ----------------------- EVENTS ----------------------------
  public void onMouseDown(int x, int y, int button) {
    if (!visible) return;
    if (canFocus) getFocus(this);
    for (ActionListener a : actions) a.onMouseDown(x, y, button);
  }

  public void onMouseUp(int x, int y, int button) {
    if (!visible) return;
    for (ActionListener a : actions) a.onMouseUp(x, y, button);
  }
  public void onMouseMove(int oldx, int oldy, int newx, int newy) {
    if (!visible) return;
    for (ActionListener a : actions) a.onMouseMove(oldx, oldy, newx, newy);
  }
  public void onMouseWheel(int x, int y, int direction){
    if (!visible) return;
    for (ActionListener a : actions) a.onMouseWheel(x, y, direction);
  }
  public void onMouseEnter() {
    if (!visible) return;
    for (ActionListener a : actions) a.onMouseEnter();
  }
  public void onMouseExit() {
    if (!visible) return;
    for (ActionListener a : actions) a.onMouseExit();
  }
  public void onKeyDown(char c, int code) {
    if (!visible) return;
    for (ActionListener a : actions) a.onKeyDown(c, code);
  }
  public void onKeyUp(char c, int code) {
    if (!visible) return;
    for (ActionListener a : actions) a.onKeyUp(c, code);
  }
  public void resize(int nw, int nh) {
    if (!visible) return;
    w = nw;
    h = nh;
    for (ActionListener a : actions) a.resize(nw, nh);
    layout.rebuild();
  }

  private final int[] getClipRect(int x1, int y1, int x2, int y2) {
    // if no parent, return the current clip rect
    if (parent == null) {
      int[] rect = new int[4];
      rect[0] = x1;
      rect[1] = y1;
      rect[2] = x2;
      rect[3] = y2;
      return rect;
    }
    int px1 = parent.getScreenX();
    int py1 = parent.getScreenY();
    int px2 = parent.getScreenX()+parent.getW();
    int py2 = parent.getScreenY()+parent.getH();
    // clip the child rect to it's parent rect
    int nx1 = clamp(x1, px1, px2);
    int ny1 = clamp(y1, py1, py2);
    int nx2 = clamp(x2, px1, px2);
    int ny2 = clamp(y2, py1, py2);
    // nothing to display at this point, just stop
    if (nx2-nx1 == 0 || ny2-ny1 == 0) return null;
    // Now the parent have to clip it with it's parent
    return parent.getClipRect(nx1, ny1, nx2, ny2);
  }

  public final boolean drawClip(PGraphics g) {
    if(!visible) return false;
    g.imageMode(CORNERS);
    int[] clipRect = getClipRect(getScreenX(), getScreenY(), getScreenX()+getW(), getScreenY()+getH());
    if (clipRect != null)
      g.clip(clipRect[0], clipRect[1], clipRect[2]+1, clipRect[3]+1);
    return clipRect != null;
  }
}

class CompositeWidget extends Widget {
  
  // list of widget
  private ArrayList<Widget> children = new ArrayList<Widget>();
  // focused widget
  private Widget focusedChild = null;

  // Constructor
  public CompositeWidget() {
    super();
  }
  
  public final Widget getFocusedChild() {return focusedChild;}
  public final boolean hasFocusedChild() {return focusedChild != null;}
 
  public final ArrayList<Widget> getChildren(){return children;}
  
  
  public  void setLayout(Layout layout){
    super.setLayout(layout);
    getLayout().setParentWidget(this);
    getLayout().rebuild();
  }
  
  // ************************ OVERRIDE ************************
  public void addChild(Widget widget) {
    widget.setParent(this);
    children.add(widget);
    getLayout().rebuild();
  }
  
  
  public void getFocus(Widget widget) {
    if( widget != this)
      focusedChild = widget;
    else
      focusedChild = null;
    if (hasParent()) getParent().getFocus(this);
  }

  public void draw(PGraphics g) {
    if (!isVisible()) return;
    super.draw(g);
    if(!drawClip(g)) return;
    
    // draw it's children
    for (int i=children.size()-1; i >= 0; --i) {
      if (children.get(i).isVisible())
        children.get(i).draw(g);
    }
    g.noClip();
  }

  public void onKeyDown(char c, int code) {
    if (!isVisible()) return;
    super.onKeyDown(c, code);
    if (focusedChild != null) focusedChild.onKeyDown(c, code);
  }

  public void onKeyUp(char c, int code) {
    if (!isVisible()) return;
    super.onKeyUp(c, code);
    if (focusedChild != null) focusedChild.onKeyUp(c, code);
  }
  public void onMouseDown(int x, int y, int button) {
    if (!isVisible()) return;
    super.onMouseDown(x, y, button);
    for (int i=0; i < children.size(); ++i) {
      if (children.get(i).coordsInside(x - getX(), y - getY()) && children.get(i).isVisible()) {
        children.get(i).onMouseDown(x- getX(), y- getY(), button);
        break;
      }
    }
  }
  
  public void onMouseWheel(int x, int y, int direction){
    if (!isVisible()) return;
    super.onMouseWheel(x, y, direction);
    for (int i=0; i < children.size(); ++i) {
      if (children.get(i).coordsInside(x - getX(), y - getY()) && children.get(i).isVisible()) {
        children.get(i).onMouseWheel(x- getX(), y- getY(), direction);
        break;
      }
    }
  }
  
  public void onMouseUp(int x, int y, int button) {
    if (!isVisible()) return;
    super.onMouseUp(x, y, button);
    for (int i=0; i < children.size(); ++i) {
      if (children.get(i).coordsInside(x - getX(), y - getY()) && children.get(i).isVisible()) {
        children.get(i).onMouseUp(x - getX(), y - getY(), button);
        break;
      }
    }
  }
  public void onMouseMove(int oldx, int oldy, int newx, int newy) {
    if (!isVisible()) return;
    super.onMouseMove(oldx, oldy, newx, newy);

    Widget prevWidget = null;
    Widget nextWidget  = null;

    for (int i=0; i < children.size(); ++i) {
      if (children.get(i).coordsInside(oldx - getX(), oldy - getY()) && children.get(i).isVisible()) {
        prevWidget = children.get(i);
        prevWidget.onMouseMove(oldx - getX(), oldy - getY(), newx - getX(), newy - getY());  
        break;
      }
    }

    for (int i=0; i < children.size(); ++i) {
      if (children.get(i).coordsInside(newx - getX(), newy - getY()) && children.get(i).isVisible()) {
        nextWidget = children.get(i);
        nextWidget.onMouseMove(oldx - getX(), oldy - getY(), newx - getX(), newy - getY());
        if (prevWidget != nextWidget) {
          if (prevWidget != null)
            prevWidget.onMouseExit();
          nextWidget.onMouseEnter();
        }
        break;
      }
    }

    if (nextWidget == null && prevWidget != null)
      prevWidget.onMouseExit();
  }
  public void calculateMinimumSize(){
    int w = 0;
    int h = 0;
    for(Widget child : children){
      child.calculateMinimumSize();
      if(child.getX()+child.getMinW() > w) w = child.getX()+child.getMinW();
      if(child.getY()+child.getMinH() > h) h = child.getY()+child.getMinH();
    }
    setMinW(w);
    setMinH(h);
  }
  
}
