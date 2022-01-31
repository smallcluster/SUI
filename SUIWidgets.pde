public class SplitWidget extends CompositeWidget {
  // Axis options
  public static final int VERTICAL = 0;
  public static final int HORIZONTAL = 1;
  // For when we move the slider
  private boolean dragging = false;
  // To calculate the slider postion
  private float offset = 0.5;
  private int sliderWidth = 8;
  // to know wich axis to split
  private int axis = 0;
  SplitWidget(int axis){
    super();
    this.axis = axis;
    setLayout(new SplitLayout());
  }
  public void setAxis(int axis){
    this.axis = axis;
    rebuild();
  }
  
  public int getAxis(){return axis;}
  
  public void addChild(Widget widget) {
    if(getChildren().size() >= 2) return;
    widget.setParent(this);
    getChildren().add(widget);
    getLayout().rebuild();
  }
  
  public float getOffset(){return offset;}
  public void setOffset(float offset){this.offset = offset;}
  public int getSliderWidth(){return sliderWidth;}
  
  public void draw(PGraphics g){
    super.draw(g);
    // clip rendering
    if(!drawClip(g)) return;
    g.fill(SUIHandleColor);
    g.stroke(getStrokeColor());
    g.rectMode(CENTER);
    if(axis == HORIZONTAL)
      g.rect(getScreenX()+getW()/2, getScreenY()+(int)(getH()*offset), getW(), sliderWidth);
    else
      g.rect(getScreenX()+(int)(getW()*offset), getScreenY()+getH()/2, sliderWidth, getH());
      
    // Unclip rendering
    g.noClip();
  }
  public void onMouseDown(int x, int y, int button){
    super.onMouseDown(x, y, button);
    // hit the slider top bar ?
    if(axis == HORIZONTAL){
      if(y >= getY()+(int)(getH()*offset)-sliderWidth/2 && y <= getY()+(int)(getH()*offset)+sliderWidth/2 && button == LEFT){
        dragging = true;
        return;
      }
    }
   else{
     if(x >= getX()+(int)(getW()*offset)-sliderWidth/2 && x <= getX()+(int)(getW()*offset)+sliderWidth/2 && button == LEFT){
        dragging = true;
        return;
      }
   }
    
  }
  public void onMouseUp(int x, int y, int button){
    super.onMouseUp(x, y, button);
    dragging = false;
  }
  public void onMouseMove(int oldx, int oldy, int newx, int newy){
    super.onMouseMove(oldx, oldy, newx, newy);
    if(dragging){
      if(axis == HORIZONTAL)
        offset = (float) clamp(newy-getY(), sliderWidth/2.0, getH()-sliderWidth/2.0) / (float) getH();
      else
        offset = (float) clamp(newx-getX(), sliderWidth/2.0, getW()-sliderWidth/2.0) / (float) getW();
      rebuild();
    }
  }
  public void onMouseExit(){
    dragging = false;
  }
}

class Button extends Widget {
  private String text;
  
  Button(String text) {
    super();
    this.text = text;
    calculateMinimumSize();
    setW(getMinW());
    setH(getMinH());
    setFillColor(SUIButtonColor);
  }
  
  public void calculateMinimumSize(){
    textFont(getTextFont());
    int w = (int) textWidth(text);
    int h = (int) (textAscent()+textDescent());
    setMinW(w+8);
    setMinH(h+8);
  }

  public void draw(PGraphics g) {
    super.draw(g);
    if(!drawClip(g)) return;
    g.fill(getTextColor());
    g.textFont(getTextFont());
    g.textAlign(CENTER, CENTER);
    g.text(text,getScreenX()+getW()/2, getScreenY()+getH()/2);
    g.noClip();
  }  


  public void onMouseDown(int x, int y, int button) {
    super.onMouseDown(x, y, button);
    setFillColor(SUIButtonPressColor);
  }
  public void onMouseUp(int x, int y, int button) {
    super.onMouseUp(x, y, button);
    setFillColor(SUIButtonHoverColor);
  }

  public void onMouseEnter() {
    super.onMouseEnter();
    setFillColor(SUIButtonHoverColor);
  }

  public void onMouseExit() {
    super.onMouseExit();
    setFillColor(SUIButtonColor);
  }
}

class Label extends Widget {
  
  private int hAlign = CENTER;
  
  private String text;
  
  Label(String text) {
    super();
    this.text = text;
    calculateMinimumSize();
    setW(getMinW());
    setH(getMinH());
    setDrawFill(false);
    setDrawStroke(false);
  }
  
  public void calculateMinimumSize(){
    int lines = text.split("\r\n|\r|\n").length+1;
    textFont(getTextFont());
    int w = (int) textWidth(text);
    int h = (int) (textAscent()+textDescent());
    setMinW(w+8);
    setMinH(h*lines+8);
  }
  
  public void setHAlign(int a){hAlign = a;}

  public void draw(PGraphics g) {
    super.draw(g);
    if(!drawClip(g)) return;
    g.fill(getTextColor());
    g.textFont(getTextFont());
    g.textAlign(hAlign, CENTER);
    int x = hAlign == LEFT ? getScreenX()+4 : hAlign == RIGHT ? getScreenX()+getW()-4: getScreenX()+getW()/2;
    g.text(text, x, getScreenY()+getH()/2);
    g.noClip();
  } 
}

class Slider extends Widget {
  // Axis options
  public static final int VERTICAL = 0;
  public static final int HORIZONTAL = 1;
  private int minLength = 100;
  private String text = "";
  private float minVal = 0;
  private float maxVal = minLength;
  private int sliderWidth = 16;
  private float val = minVal;
  private float axis = HORIZONTAL;
  private boolean dragging = false;
  public boolean useInt = false;

  Slider(int minLength, float minVal, float maxVal, int axis) {
    super();
    this.minLength= minLength;
    this.minVal = minVal;
    this.maxVal = maxVal;
    this.axis = axis;
    this.val = minVal;
    setDrawFill(false);
    setDrawStroke(false);
    calculateMinimumSize();
  }
  
  public void setVal(float v){val=v;}
  public float getVal(){return val;} 
  
  public void setUseInt(boolean u){
    useInt = u;
  }
  
  public void setText(String text){
    this.text = text; 
  }
  
  public void calculateMinimumSize(){
    textFont(getTextFont());
    if(axis == HORIZONTAL){
      int w = (int) textWidth(text)+minLength;
      int h = (int) max((textAscent()+textDescent()), sliderWidth);
      setMinW(w+8);
      setMinH(h+8);
    } else {
      int w = (int) max(textWidth(text), sliderWidth);
      int h = (int) (textAscent()+textDescent())+minLength;
      setMinW(w+8);
      setMinH(h+8);
    }
  }
  public void draw(PGraphics g) {
    super.draw(g);
    if (!drawClip(g)) return;
     g.noStroke();
     g.fill(SUISliderBgColor);
     g.rectMode(CORNER);
    if (axis == HORIZONTAL) {
      // draw the slider background
      g.rect(getScreenX(), getScreenY()+getH()/2-sliderWidth/2, minLength, sliderWidth);
      // draw the slider bar
      g.fill(SUISliderColor);
      g.rect(getScreenX(), getScreenY()+getH()/2-sliderWidth/2, map(val, minVal, maxVal, 0, minLength), sliderWidth);
      // draw the val 
      g.fill(getTextColor());
      g.textFont(getTextFont());
      g.textAlign(CENTER, CENTER);
      g.text(nf(val, 0, 2), getScreenX()+minLength/2, getScreenY()+getH()/2);
      // draw the slider label
      g.textAlign(CENTER, CENTER);
      int tw = (int) g.textWidth(text);
      g.text(text, getScreenX()+minLength+tw/2+4, getScreenY()+getH()/2);
    } else {
      // draw the slider background
      g.rect(getScreenX()+getW()/2-sliderWidth/2, getScreenY(), sliderWidth, minLength);
      // draw the slider bar
      g.fill(SUISliderColor);
      g.rect(getScreenX()+getW()/2-sliderWidth/2, getScreenY(), sliderWidth, map(val, minVal, maxVal, 0, minLength));
      // draw the val 
      g.fill(getTextColor());
      g.textFont(getTextFont());
      g.textAlign(CENTER, CENTER);
      g.text(nf(val, 0, 2), getScreenX()+getW()/2, getScreenY()+minLength/2);
      // draw the slider label
      g.textAlign(CENTER, CENTER);
      int th = (int) (textAscent()+textDescent());
      g.text(text, getScreenX()+getW()/2, getScreenY()+minLength+th/2.0);
    }
    g.noClip();
  }

  public void onMouseDown(int x, int y, int button) {
    // hit the slider top bar ?
    if (axis == HORIZONTAL) {
      if (x <= getX()+minLength && y >= getY()+getH()/2-sliderWidth/2 && y <= getY()+getH()/2+sliderWidth/2   && button == LEFT) {
        val = map(clamp(x-getX(), 0, minLength), 0, minLength, minVal, maxVal);
        if(useInt) val = (int) val;
        dragging = true;
        super.onMouseDown(x, y, button);
        return;
      }
    } else {
      if (y <= getY()+minLength && x >= getX()+getW()/2-sliderWidth/2 && x <= getX()+getW()/2+sliderWidth/2   && button == LEFT) {
        val = map(clamp(y-getY(), 0, minLength), 0, minLength, minVal, maxVal);
        if(useInt) val = (int) val;
        dragging = true;
        super.onMouseDown(x, y, button);
        return;
      }
    }
  }

  public void onMouseUp(int x, int y, int button) {
    super.onMouseUp(x, y, button);
    dragging = false;
  }

  public void onMouseMove(int oldx, int oldy, int newx, int newy) {
    if (dragging) {
      super.onMouseMove(oldx, oldy, newx, newy);
      if (axis == HORIZONTAL){
        val = map(clamp(newx-getX(), 0, minLength), 0, minLength, minVal, maxVal);
        if(useInt) val = (int) val;
      }else{
        val = map(clamp(newy-getY(), 0, minLength), 0, minLength, minVal, maxVal);
        if(useInt) val = (int) val;
      }
    }
  }

  public void onMouseExit() {
    dragging = false;
  }
}

class Window extends CompositeWidget {
  
  // Content panel
  private CompositeWidget contentPanel = new CompositeWidget();
  
  // can it be resized ?
  private boolean resizable = true;
  
  private boolean dragging = false;
  private boolean resizing = false;
  private boolean canClose = true; 
  
  // Distance where the mouse hit, relative to the window
  private int dx, dy;
  
  // Decoration size
  private int topHeight = 16;
  private int scaleHandleSize = 16;
  private String title = "";
  
  // Constructor
  public Window(int x, int y, int w, int h) {
    super();
    setX(x);
    setY(y);
    setW(w);
    setH(h);
    
    setStrokeColor(SUIWindowStrokeColor);
    setDrawFill(false);
    // define it's content panel
    super.addChild(contentPanel);
    contentPanel.setFillColor(SUIWindowFillColor);
    contentPanel.setX(1);
    contentPanel.setY(topHeight+1);
    contentPanel.setW(getW()-2);
    contentPanel.setH(getH()-topHeight-2);
  }
  
  public void getFocus(Widget widget) {
    if (hasParent()) getParent().getFocus(contentPanel);
  }
  
  public void setTitle(String txt){title = txt;}
  
  // Children are added to the content panel and not the window itself.
  public void addChild(Widget widget) {
    widget.setParent(contentPanel);
    contentPanel.addChild(widget);
    rebuild();
  }
  
  
  public void draw(PGraphics g){
    super.draw(g);
    if(!drawClip(g)) return;
    g.fill(SUIHandleColor);
    g.stroke(SUIHandleColor);
    g.rectMode(CORNER);
    g.rect(getScreenX(), getScreenY(), getW(), topHeight);
    if(canClose){
      g.fill(SUIButtonColor);
      g.rect(getScreenX()+getW()-topHeight, getScreenY(), topHeight, topHeight);
      g.stroke(SUIWidgetStrokeColor);
      g.line(getScreenX()+getW()-topHeight, getScreenY(), getScreenX()+getW(), getScreenY()+topHeight);
      g.line(getScreenX()+getW(), getScreenY(), getScreenX()+getW()-topHeight, getScreenY()+topHeight);
    }
    g.stroke(SUIHandleColor);
    g.fill(getTextColor());
    g.textFont(getTextFont());
    g.textAlign(LEFT, CENTER);
    g.text(title, getScreenX()+2, getScreenY()+topHeight/2);
    if(resizable){
      g.fill(SUIHandleColor);
      g.rect(getScreenX()+getW()-scaleHandleSize, getScreenY()+getH()-scaleHandleSize, scaleHandleSize, scaleHandleSize);  
    }
    g.noClip();
    
  }
  
  public void setResizable(boolean b){resizable = b;}
  
  public void onMouseDown(int x, int y, int button){
    // get mouse relative dist
    dx = getX()-x;
    dy = getY()-y;
    // hit the top bar ?
    if( x < getX()+getW()-topHeight && y <= getY() + topHeight && button == LEFT){
      dragging = true;
      return;
    }
    // hit the resize button
    if(x >= getX()+getW()-scaleHandleSize && y >= getY()+getH()-scaleHandleSize  && button == LEFT && resizable){
      resizing = true;
      return;
    }
    super.onMouseDown(x, y, button);
    
  }
  
  public void onMouseUp(int x, int y, int button){
    if(!resizing && !dragging){
      if(x >= getX()+getW()-topHeight && y <= getY() + topHeight && button == LEFT){
        super.setVisible(false);
      }
      super.onMouseUp(x, y, button);
    }
    dragging = false;
    resizing = false;
  }
  
  public void onMouseMove(int oldx, int oldy, int newx, int newy){
    if(dragging){
      setX(newx+dx);
      setY(newy+dy);
    } else if(resizing){
      int w = newx-getX()+scaleHandleSize/2;
      int nw = w < scaleHandleSize ? scaleHandleSize : w;
      int h = newy-getY()+scaleHandleSize/2;
      int nh = h < topHeight+scaleHandleSize ? topHeight+scaleHandleSize : h;
      resize(nw, nh);
    }
    super.onMouseMove(oldx, oldy, newx, newy);
  }
  
  public void onMouseExit(){
    dragging = false;
    resizing = false;
  }
  
  public void resize(int nw, int nh){
    if(!isVisible()) return;
    super.resize(nw, nh);
    contentPanel.resize(nw-2,nh-topHeight-2);
  }
  
  public void rebuild(){
    super.rebuild();
    contentPanel.rebuild();
  }
  
  public void calculateMinimumSize(){
    contentPanel.calculateMinimumSize();
    setMinW(contentPanel.getMinW());
    setMinH(contentPanel.getMinH()+topHeight);
  }
  
  public final Layout getLayout(){return contentPanel.getLayout();}
  
  public final void setLayout(Layout layout){
    contentPanel.setLayout(layout);
  }
}

class CheckBox extends Widget {

  private boolean checked = false;
  private String text;
  private int boxSize = 16;

  CheckBox(String text) {
    super();
    this.text = text;
    calculateMinimumSize();
    setW(getMinW());
    setH(getMinH());
    setFillColor(SUIButtonColor);
    setDrawFill(false);
    setDrawStroke(false);
  }

  public void calculateMinimumSize() {
    textFont(getTextFont());
    int textW = (int) textWidth(text);
    int textH = (int) (textAscent()+textDescent());
    setMinW(boxSize+textW+8);
    setMinH(max(boxSize, textH)+8);
  }

  public void setChecked(boolean b) {
    checked = b;
  }
  public boolean getChecked() { 
    return checked;
  }

  public void draw(PGraphics g) {
    super.draw(g);
    if (!drawClip(g)) return;

    g.fill(getFillColor());
    g.stroke(SUIWidgetStrokeColor);
    g.rectMode(CORNER);
    g.rect(getScreenX(), getScreenY()+getH()/2-boxSize/2, boxSize, boxSize);
    if (checked) {
      g.line(getScreenX(), getScreenY()+getH()/2-boxSize/2, getScreenX()+boxSize, getScreenY()+getH()/2+boxSize/2);
      g.line(getScreenX()+boxSize, getScreenY()+getH()/2-boxSize/2, getScreenX(), getScreenY()+getH()/2+boxSize/2);
    }

    g.fill(getTextColor());
    g.textFont(getTextFont());
    g.textAlign(LEFT, CENTER);
    g.text(text, getScreenX()+boxSize+4, getScreenY()+getH()/2);

    g.noClip();
  }  

  public void onMouseDown(int x, int y, int button) {
    if (x >= getX() && x <= getX()+boxSize && y >= getY()+getH()/2-boxSize/2 && y <= getY()+getH()/2+boxSize/2 && button == LEFT) {
      setFillColor(SUIButtonPressColor);
      super.onMouseDown(x, y, button);
    }
  }

  public void onMouseUp(int x, int y, int button) {
    if (x >= getX() && x <= getX()+boxSize && y >= getY()+getH()/2-boxSize/2 && y <= getY()+getH()/2+boxSize/2 && button == LEFT) {
      checked = !checked;
      super.onMouseUp(x, y, button);
      setFillColor(SUIButtonHoverColor);
    }
  }
}


class TextBox extends Widget {
  
  private int boxLength = 100;
  private String text = "";
  private int boxHeight;
  private String insideText = "0";
  private boolean hitEnter = false;
  
  
  TextBox(int boxLength, String text){
   super(); 
   this.boxLength = boxLength;
   this.text = text;
   textFont(getTextFont());
   int textH = (int) (textAscent()+textDescent());
   boxHeight = textH+4;
   setDrawFill(false);
   setDrawStroke(false);
  }
  
  public void calculateMinimumSize() {
    textFont(getTextFont());
    int textW = (int) textWidth(text);
    int textH = (int) (textAscent()+textDescent());
    boxHeight = textH+4;
    setMinW(boxLength+textW+8);
    setMinH(textH+8);
  }
  
  public String getInsideText(){return insideText;}
  public void setInsideText(String txt){insideText = txt;}
  
  public void draw(PGraphics g){
    super.draw(g);
    if(!drawClip(g)) return;
    g.rectMode(CORNER);
    g.textFont(getTextFont());
    g.stroke(SUIWidgetStrokeColor);
    g.fill(SUITextBoxBgColor);
    g.rect(getScreenX(), getScreenY()+getH()/2.0-boxHeight/2.0, boxLength, boxHeight);
    g.fill(SUITextColor);
    
    g.textAlign(LEFT, CENTER);
    g.text(text, getScreenX()+boxLength+4, getScreenY()+getH()/2.0);
    g.text(insideText, getScreenX()+4, getScreenY()+getH()/2.0);
    
    if(((CompositeWidget) getParent()).getFocusedChild() == this){
      g.stroke(SUIFocusStrokeColor);
      g.noFill();
      g.rect(getScreenX(), getScreenY()+getH()/2.0-boxHeight/2.0, boxLength, boxHeight);
      g.stroke(SUITextColor);
      int w = (int) textWidth(insideText);
      if(!hitEnter)
        g.line(getScreenX()+w+4, getScreenY()+getH()/2.0-boxHeight/2.0, getScreenX()+w+4, getScreenY()+getH()/2.0+boxHeight/2.0);
    }
    g.noClip();
  }
  
  public void onMouseDown(int x, int y, int button) {
    if (x >= getX() && x <= getX()+boxLength && y >= getY()+getH()/2-boxHeight/2 && y <= getY()+getH()/2+boxHeight/2 && button == LEFT) {
      super.onMouseDown(x, y, button);
      hitEnter = false;
    }
  }
  
  public void onMouseUp(int x, int y, int button) {
    if (x >= getX() && x <= getX()+boxLength && y >= getY()+getH()/2-boxHeight/2 && y <= getY()+getH()/2+boxHeight/2 && button == LEFT) {
      super.onMouseUp(x, y, button);
    }
  }
  
  public void onKeyDown(char c, int code) {
    hitEnter = false;
    super.onKeyDown(c, code);
    if(code == BACKSPACE ){
      if(insideText.length() <= 1) insideText = "";
      else {
      StringBuilder sb = new StringBuilder(insideText);
      sb.deleteCharAt(insideText.length()-1);
      insideText = sb.toString();
      }
    } else if(code == ENTER)
      hitEnter = true;
      else
        insideText+=c;
  }
  
  
}
