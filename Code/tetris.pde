PTetrisGrid t;
PVector startPos;
int gridWidth, gridHeight, gridSquareSize, initFallSpeed, quickFallSpeed, leanSpeed;
color gridEmptyColor;
int counter;

void setup(){
  counter = 1;
  size(445, 420);
  colorMode(HSB);
  background(255);
  startPos = new PVector(10, 10);
  gridWidth = 10;
  gridHeight = 16;
  gridSquareSize = 25;
  gridEmptyColor = color(0, 0, 255);
  initFallSpeed = 30;
  quickFallSpeed = 5;
  leanSpeed = 10;
  
  t = new PTetrisGrid(startPos, gridWidth, gridHeight, gridSquareSize, initFallSpeed, quickFallSpeed, leanSpeed, gridEmptyColor);
  t.render(true);
}

void draw(){
  //background(255);
  t.runGame(counter);
  //t.render();
  counter++;
  counter %= 518400;
}

void keyPressed(){
  t.setControlFlag(key, keyCode, true, counter);
}

void keyReleased(){
  t.setControlFlag(key, keyCode, false, counter);
}

class PTetrisBlock{
  
  private boolean locked;
  private color innerBlockColor;
  private color outerBlockColor;
  private color strokeColor;
  // Extends squares over sides
  // Values range from 0-15, use binary representation
  // Up, Down, Left, Right
  // Ex: Up-left == 0b1010
  private int connections;
  
  public PTetrisBlock(color outerBlockColor, color innerBlockColor, color strokeColor, int connections){
    this.locked = false;
    this.outerBlockColor = outerBlockColor;
    this.innerBlockColor = innerBlockColor;
    this.strokeColor = strokeColor;
    this.connections = connections;
  }
  
  public boolean isLocked(){
    return locked;
  }
  
  public void setLocked(boolean locked){
    this.locked = locked;
  }
  
  public color getOuterBlockColor(){
    return outerBlockColor;
  }
  
  public void setOuterBlockColor(color newColor){
    outerBlockColor = newColor;
  }

  public color getInnerBlockColor(){
    return innerBlockColor;
  }
  
  public void setInnerBlockColor(color newColor){
    innerBlockColor = newColor;
  }

  public color getStrokeColor(){
    return strokeColor;
  }
  
  public void setStrokeColor(color newColor){
    strokeColor = newColor;
  }

  public int getConnections(){
    return connections;
  }

  public void setConnections(int connections){
    this.connections = connections;
  }

  public void render(int size){
    noStroke();
    int s = int(size*0.25);
    int sizeMinus = size-s;
    int size2Minus = size-2*s;
    // 4 corners
    fill(outerBlockColor);
    rect(0, 0, s, s);
    rect(sizeMinus, 0, s, s);
    rect(0, sizeMinus, s, s);
    rect(sizeMinus, sizeMinus, s, s);
    
    // Middle square
    fill(innerBlockColor);
    rect(s, s, size2Minus, size2Minus);
    
    boolean up = boolean(connections & 8); 
    boolean down = boolean(connections & 4);
    boolean left = boolean(connections & 2);
    boolean right = boolean(connections & 1);
    // 4 sides
    fill(up ? innerBlockColor : outerBlockColor); // Up
    rect(s, 0, size2Minus, s);
    fill(down ? innerBlockColor : outerBlockColor); // Down
    rect(s, sizeMinus, size2Minus, s);
    fill(left ? innerBlockColor : outerBlockColor); // Left
    rect(0, s, s, size2Minus);
    fill(right ? innerBlockColor : outerBlockColor); // Right
    rect(sizeMinus, s, s, size2Minus);
    
    // 4 lines
    stroke(strokeColor);
    strokeWeight(2);
    noFill();
    float p = 0;
    ////rect(0, 0, size, size);
    if(!up) line(p, p, size-p, p);
    if(!down) line(p, size-p, size-p, size-p);
    if(!left) line(p, p, p, size-p);
    if(!right) line(size-p, p, size-p, size-p);
  }
}

public class PTetromino{
  
  PVector pos;
  final int shapeType; //0 to 6 : Square, T, L, Flipped-L, S, Z, Line
  int orientation; // 0-3
  PVector blockOffsets[];
  PTetrisBlock blocks[];
  
  public PTetromino(PVector pos, int shapeType, int orientation){
    this.pos = new PVector(pos.x, pos.y);
    this.shapeType = shapeType;
    this.orientation = orientation;
    blockOffsets = new PVector[4];
    color outerBlockColor, innerBlockColor;
    int os = 255;
    int ob = 200;
    int is = 200;
    int ib = 255;
    switch(shapeType){
      case 0: outerBlockColor = color(30, os, ob); innerBlockColor = color(40, is, ib); break;
      case 1: outerBlockColor = color(210, os, ob); innerBlockColor = color(210, is, ib); break;
      case 2: outerBlockColor = color(20, os, ob); innerBlockColor = color(25, is, ib); break;
      case 3: outerBlockColor = color(170, os, ob); innerBlockColor = color(170, is, ib); break;
      case 4: outerBlockColor = color(80, os, ob); innerBlockColor = color(80, is, ib); break;
      case 5: outerBlockColor = color(0, os, ob); innerBlockColor = color(0, is, ib); break;
      case 6: outerBlockColor = color(140, os, ob); innerBlockColor = color(140, is, ib); break;
      default: outerBlockColor = color(0, 0, 0); innerBlockColor = color(0, 0, 0); break;
    }
    blocks = new PTetrisBlock[4];
    //color strokeColor = color(hue(blockColor), 150, 120);
    color strokeColor = color(0);
    for(int i = 0; i < blocks.length; i++){
      blocks[i] = new PTetrisBlock(outerBlockColor, innerBlockColor, strokeColor, 0);
    }
    updateBlockOffsets();
  }
  
  public int getShapeType(){
    return shapeType;
  }
  
  public PVector getPos(){
    return pos;
  }
  
  public void setPos(PVector newPos){
    pos = new PVector(newPos.x, newPos.y);
  }
  
  public void fall(){
    pos.set(pos.x, pos.y+1);
  }
  
  public PTetrisBlock[] getBlocks(){
    return blocks;
  }
  
  public PVector[] getBlockOffsets(){
    return blockOffsets;
  }

  public void render(int size){
    pushMatrix();
    translate(pos.x*size, pos.y*size);
    for(int i = 0; i < blockOffsets.length; i++){
      pushMatrix();
      translate(blockOffsets[i].x*size, blockOffsets[i].y*size);
      blocks[i].render(size);
      popMatrix();
    }
    popMatrix();
  }
  
  private void updateBlockOffsets(){
    switch(shapeType){
      case 0:
        switch(orientation){
          case 0:
          case 1:
          case 2:
          case 3:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(1, -1);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(1, 0);
            blocks[0].setConnections(5); // 0101
            blocks[1].setConnections(6); // 0110
            blocks[2].setConnections(9); // 1001
            blocks[3].setConnections(10); // 1010
        } break;
      case 1:
          switch(orientation){
          case 0:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(-1, 0);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(1, 0);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(1); // 0001
            blocks[2].setConnections(11); // 1011
            blocks[3].setConnections(2); // 0010
            break;
          case 1:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(1, 0);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(13); // 1101
            blocks[2].setConnections(2); // 0010
            blocks[3].setConnections(8); // 1000
            break;
          case 2:
            blockOffsets[0] = new PVector(-1, 0);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(1, 0);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(1); // 0001
            blocks[1].setConnections(7); // 0111
            blocks[2].setConnections(2); // 0010
            blocks[3].setConnections(8); // 1000
            break;
          case 3:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(-1, 0);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(1); // 0001
            blocks[2].setConnections(14); // 1110
            blocks[3].setConnections(8); // 1000
            break;
        } break;
        case 2:
          switch(orientation){
          case 0:
            blockOffsets[0] = new PVector(1, -1);
            blockOffsets[1] = new PVector(-1, 0);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(1, 0);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(1); // 0001
            blocks[2].setConnections(3); // 0011
            blocks[3].setConnections(10); // 1010
            break;
          case 1:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(0, 1);
            blockOffsets[3] = new PVector(1, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(12); // 1100
            blocks[2].setConnections(9); // 1001
            blocks[3].setConnections(2); // 0010
            break;
          case 2:
            blockOffsets[0] = new PVector(-1, 0);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(1, 0);
            blockOffsets[3] = new PVector(-1, 1);
            blocks[0].setConnections(5); // 0101
            blocks[1].setConnections(3); // 0011
            blocks[2].setConnections(2); // 0010
            blocks[3].setConnections(8); // 1000
            break;
          case 3:
            blockOffsets[0] = new PVector(-1, -1);
            blockOffsets[1] = new PVector(0, -1);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(1); // 0001
            blocks[1].setConnections(6); // 0110
            blocks[2].setConnections(12); // 1100
            blocks[3].setConnections(8); // 1000
            break;
        } break;
        case 3:
          switch(orientation){
          case 0:
            blockOffsets[0] = new PVector(-1, -1);
            blockOffsets[1] = new PVector(-1, 0);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(1, 0);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(9); // 1001
            blocks[2].setConnections(3); // 0011
            blocks[3].setConnections(2); // 0010
            break;
          case 1:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(1, -1);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(5); // 0101
            blocks[1].setConnections(2); // 0010
            blocks[2].setConnections(12); // 1100
            blocks[3].setConnections(8); // 1000
            break;
          case 2:
            blockOffsets[0] = new PVector(-1, 0);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(1, 0);
            blockOffsets[3] = new PVector(1, 1);
            blocks[0].setConnections(1); // 0001
            blocks[1].setConnections(3); // 0011
            blocks[2].setConnections(6); // 0110
            blocks[3].setConnections(8); // 1000
            break;
          case 3:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(-1, 1);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(12); // 1100
            blocks[2].setConnections(1); // 0001
            blocks[3].setConnections(10); // 1010
            break;
        } break;
        case 4:
          switch(orientation){
          case 0:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(1, -1);
            blockOffsets[2] = new PVector(-1, 0);
            blockOffsets[3] = new PVector(0, 0);
            blocks[0].setConnections(5); // 0101
            blocks[1].setConnections(2); // 0010
            blocks[2].setConnections(1); // 0001
            blocks[3].setConnections(10); // 1010
            break;
          case 1:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(1, 0);
            blockOffsets[3] = new PVector(1, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(9); // 1001
            blocks[2].setConnections(6); // 0110
            blocks[3].setConnections(8); // 1000
            break;
          case 2:
            blockOffsets[0] = new PVector(0, 0);
            blockOffsets[1] = new PVector(1, 0);
            blockOffsets[2] = new PVector(-1, 1);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(5); // 0101
            blocks[1].setConnections(2); // 0010
            blocks[2].setConnections(1); // 0001
            blocks[3].setConnections(10); // 1010
            break;
          case 3:
            blockOffsets[0] = new PVector(-1, -1);
            blockOffsets[1] = new PVector(-1, 0);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(9); // 1001
            blocks[2].setConnections(6); // 0110
            blocks[3].setConnections(8); // 1000
            break;
        } break;
        case 5:
          switch(orientation){
          case 0:
            blockOffsets[0] = new PVector(-1, -1);
            blockOffsets[1] = new PVector(0, -1);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(1, 0);
            blocks[0].setConnections(1); // 0001
            blocks[1].setConnections(6); // 0110
            blocks[2].setConnections(9); // 1001
            blocks[3].setConnections(2); // 0010
            break;
          case 1:
            blockOffsets[0] = new PVector(1, -1);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(1, 0);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(5); // 0101
            blocks[2].setConnections(10); // 1010
            blocks[3].setConnections(8); // 1000
            break;
          case 2:
            blockOffsets[0] = new PVector(-1, 0);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(0, 1);
            blockOffsets[3] = new PVector(1, 1);
            blocks[0].setConnections(1); // 0001
            blocks[1].setConnections(6); // 0110
            blocks[2].setConnections(9); // 1001
            blocks[3].setConnections(2); // 0010
            break;
          case 3:
            blockOffsets[0] = new PVector(0, -1);
            blockOffsets[1] = new PVector(-1, 0);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(-1, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(5); // 0101
            blocks[2].setConnections(10); // 1010
            blocks[3].setConnections(8); // 1000
            break;
        } break;
        case 6:
          switch(orientation){
          case 0:
            blockOffsets[0] = new PVector(-1, -1);
            blockOffsets[1] = new PVector(0, -1);
            blockOffsets[2] = new PVector(1, -1);
            blockOffsets[3] = new PVector(2, -1);
            blocks[0].setConnections(1); // 0001
            blocks[1].setConnections(3); // 0011
            blocks[2].setConnections(3); // 0011
            blocks[3].setConnections(2); // 0010
            break;
          case 1:
            blockOffsets[0] = new PVector(1, -2);
            blockOffsets[1] = new PVector(1, -1);
            blockOffsets[2] = new PVector(1, 0);
            blockOffsets[3] = new PVector(1, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(12); // 1100
            blocks[2].setConnections(12); // 1100
            blocks[3].setConnections(8); // 1000
            break;
          case 2:
            blockOffsets[0] = new PVector(-1, 0);
            blockOffsets[1] = new PVector(0, 0);
            blockOffsets[2] = new PVector(1, 0);
            blockOffsets[3] = new PVector(2, 0);
            blocks[0].setConnections(1); // 0001
            blocks[1].setConnections(3); // 0011
            blocks[2].setConnections(3); // 0011
            blocks[3].setConnections(2); // 0010
            break;
          case 3:
            blockOffsets[0] = new PVector(0, -2);
            blockOffsets[1] = new PVector(0, -1);
            blockOffsets[2] = new PVector(0, 0);
            blockOffsets[3] = new PVector(0, 1);
            blocks[0].setConnections(4); // 0100
            blocks[1].setConnections(12); // 1100
            blocks[2].setConnections(12); // 1100
            blocks[3].setConnections(8); // 1000
            break;
        } break;
      }
  }
  
  public int getOrientation(){
    return orientation;
  }
  
  public void rotateOrientation(boolean clockwise){
    orientation = (orientation + (clockwise ? 5 : 3)) % 4;
    updateBlockOffsets();
  }
  
}

class PTetrisGrid{
  
  private PVector pos, actStartPos, showNextPos;
  private final int gridWidth, gridHeight;
  private int gridSquareSize, fallSpeed, quickFallSpeed, leanSpeed;
  private color emptySquareColor;
  private PTetrisBlock gridSquares[][];
  private PTetromino activeTetro;
  private boolean controlFlags[];
  private int controlTime[];
  private PTetromino tetroBag[];
  private int nextTBagInd;
  private boolean lockDelay;
  
  public PTetrisGrid(PVector pos, int gridWidth, int gridHeight, int gridSquareSize, int fallSpeed, int quickFallSpeed, int leanSpeed, color defaultSquareColor){
    this.pos = pos;
    this.gridWidth = gridWidth;
    this.gridHeight = gridHeight;
    this.gridSquareSize = gridSquareSize;
    this.fallSpeed = fallSpeed;
    this.quickFallSpeed = quickFallSpeed;
    this.leanSpeed = leanSpeed;
    this.emptySquareColor = defaultSquareColor;
    this.lockDelay = false;
    //Control flags are Lean Left, Lean Right, Rotate counter-clockwise, Rotate clockwise, Quick-drop, Insta-drop, Hold-piece
    this.controlFlags = new boolean[7];
    this.controlTime = new int[7];
    for(int i = 0; i < controlFlags.length; i++){
      controlFlags[i] = false;
      controlTime[i] = 0;
    }
    this.actStartPos = new PVector(4, -1);
    this.showNextPos = new PVector(2, 2);
    tetroBag = generateTetroBag(7);
    nextTBagInd = 0;
    gridSquares = new PTetrisBlock[gridWidth][gridHeight];
    for(int i = 0; i < gridWidth; i++){
      for(int j = 0; j < gridHeight; j++){
        gridSquares[i][j] = new PTetrisBlock(emptySquareColor, emptySquareColor, color(0), 0);
      }
    }
    activeTetro = grabNextActiveTetro();
  }
  
  public void runGame(int counter){
    runControls(counter);
    boolean instaDrop = controlFlags[5] && controlTime[5] == counter;
    boolean fall = (counter - max(controlTime[4], controlTime[5])) % (controlFlags[4] ? quickFallSpeed : fallSpeed) == 0;
    if(fall || instaDrop){
      drawMovementOnly(activeTetro, true);
    }
    if(instaDrop){
      lockDelay = false;
      // fall method will handle redrawing the tetromino once set.
      while(!fallActiveTetro());
    } else if(fall){
      fallActiveTetro();
    }
    if(fall || instaDrop) drawMovementOnly(activeTetro, false);
  }
  
  private boolean fallActiveTetro(){
    if(checkFallCollision(activeTetro)){
      if(lockDelay){
        lockDelay = false;
        return false;
      }
      drawMovementOnly(activeTetro, false);
      saveActiveTetroToGrid();
      lineClear();
      return true;
    } else {
      lockDelay = false;
      activeTetro.fall();
      return false;
    }
  }
  
  public void render(boolean updateGrid){
    //background(255);
    pushMatrix();
    translate(pos.x, pos.y);
    if(updateGrid) drawGrid();
    //drawTetro(generateGhostTetro(activeTetro));
    //drawTetro(activeTetro);
    drawContainer();
    drawNextTetroBox();
    popMatrix();
  }
  
  private void drawContainer(){
    stroke(0);
    strokeWeight(5);
    noFill();
    PVector p0, p1, p2, p3;
    p0 = new PVector(0, 0);
    p1 = new PVector(0, gridSquareSize*gridHeight);
    p2 = new PVector(gridSquareSize*gridWidth, p1.y);
    p3 = new PVector(p2.x, 0);
    beginShape();
    vertex(p0.x, p0.y);
    vertex(p1.x, p1.y);
    vertex(p2.x, p2.y);
    vertex(p3.x, p3.y);
    endShape();
  }

  private void drawGrid(){
    pushMatrix();
    for(int i = 0; i < gridWidth; i++){
      pushMatrix();
      for(int j = 0; j < gridHeight; j++){
        gridSquares[i][j].render(gridSquareSize);
        translate(0, gridSquareSize);
      }
      popMatrix();
      translate(gridSquareSize, 0);
    }
    popMatrix();
  }

  private void drawMovementOnly(PTetromino t, boolean clear){
    PTetromino g = generateGhostTetro(t);
    pushMatrix();
    translate(pos.x, pos.y);
    if(clear){
      drawGridOverTetro(g);
      drawGridOverTetro(t);
    } else {
      drawTetro(g);
      drawTetro(t);
    }
    drawContainer();
    popMatrix();
  }

  private void drawGridOverTetro(PTetromino t){
    PVector offsets[] = t.getBlockOffsets();
    int x, y;
    for(int i = 0; i < offsets.length; i++){
      x = int(t.getPos().x + offsets[i].x);
      y = int(t.getPos().y + offsets[i].y);
      if(x >= 0 && x < gridWidth && y >= 0 && y < gridHeight){
        pushMatrix();
        translate(x*gridSquareSize, y*gridSquareSize);
        gridSquares[x][y].render(gridSquareSize);
        popMatrix();
      } else {
        fill(255);
        noStroke();
        rect(x*gridSquareSize-2, y*gridSquareSize-1, gridSquareSize+4, gridSquareSize);
      }
    }
  }
  
  private void drawTetro(PTetromino t){
    t.render(gridSquareSize);
  }

  private void drawNextTetroBox(){
    pushMatrix();
    translate((gridWidth+1)*gridSquareSize, 0);
    stroke(0);
    fill(emptySquareColor);
    rect(0, 0, 6*gridSquareSize, 4*gridSquareSize);
    drawTetro(tetroBag[nextTBagInd]);
    popMatrix();
  }
  
  public int getGridWidth(){
    return gridWidth;
  }
  
  public int getGridHeight(){
    return gridHeight;
  }
  
  private void runControls(int counter){
    boolean leanLeft = controlFlags[0] && (counter - controlTime[0]) % leanSpeed == 0;
    boolean leanRight = controlFlags[1] && (counter - controlTime[1]) % leanSpeed == 0;
    boolean rotateCCWise = controlFlags[2] && counter == controlTime[2];
    boolean rotateCWise = controlFlags[3] && counter == controlTime[3];
    if(leanLeft || leanRight || rotateCCWise || rotateCWise) drawMovementOnly(activeTetro, true);
    if(leanLeft) leanActiveTetro(true);
    if(leanRight) leanActiveTetro(false);
    if(rotateCCWise) rotateActiveTetro(false);
    if(rotateCWise) rotateActiveTetro(true);
    if(leanLeft || leanRight || rotateCCWise || rotateCWise) drawMovementOnly(activeTetro, false);
  }
  
  private void leanActiveTetro(boolean left){
    PVector actPos = activeTetro.getPos();
    if(!checkLeanCollision(activeTetro, left)){
      activeTetro.setPos(new PVector(actPos.x + (left ? -1 : 1), actPos.y));
      lockDelay = true;
    }
  }
  
  //TODO: Revise SRS logic
  private void rotateActiveTetro(boolean clockwise){
    boolean canRotate = false;
    PTetromino t = new PTetromino(activeTetro.getPos(), activeTetro.getShapeType(), activeTetro.getOrientation());
    t.rotateOrientation(clockwise);
    canRotate = !checkBlockOverlap(t.getPos(), t.getBlockOffsets());
    if(!canRotate){
      PVector up = new PVector(t.getPos().x, t.getPos().y - 1);
      if(!checkBlockOverlap(up, t.getBlockOffsets())){
        t.setPos(up);
        canRotate = true;
      }
      else if(!checkLeanCollision(t, true)){
        t.setPos(new PVector(t.getPos().x - 1, t.getPos().y));
        canRotate = true;
      } else if(!checkLeanCollision(t, false)){
        t.setPos(new PVector(t.getPos().x + 1, t.getPos().y));
        canRotate = true;
      }
      if(!canRotate){
        t.setPos(up);
        if(!checkLeanCollision(t, true)){
          t.setPos(new PVector(t.getPos().x - 1, t.getPos().y));
          canRotate = true;
        } else if(!checkLeanCollision(t, false)){
          t.setPos(new PVector(t.getPos().x + 1, t.getPos().y));
          canRotate = true;
        }
      }
    }
    if(canRotate){
      activeTetro = t;
      lockDelay = true;
    }
  }
  
  private boolean checkFallCollision(PTetromino t){
    return checkBlockOverlap(new PVector(t.getPos().x, t.getPos().y+1), t.getBlockOffsets());
  }
  
  private boolean checkLeanCollision(PTetromino t, boolean left){
    return checkBlockOverlap(new PVector(t.getPos().x + (left ? -1 : 1), t.getPos().y), t.getBlockOffsets());
  }
  
  private boolean checkBlockOverlap(PVector actPos, PVector blockOffsets[]){
    for(int i = 0; i < blockOffsets.length; i++){
      int x = int(actPos.x + blockOffsets[i].x);
      int y = int(actPos.y + blockOffsets[i].y);
      if(x >= gridWidth || x < 0 || y >= gridHeight) return true;
      if(y >= 0 && gridSquares[x][y].isLocked()) return true;
    }
    return false;
  }
  
  private void saveActiveTetroToGrid(){
    PVector actPos = activeTetro.getPos();
    PVector blockOffsets[] = activeTetro.getBlockOffsets();
    PTetrisBlock blocks[] = activeTetro.getBlocks();
    boolean gameOver = false;
    for(int i = 0; i < blockOffsets.length; i++){
      int x = int(actPos.x + blockOffsets[i].x);
      int y = int(actPos.y + blockOffsets[i].y);
      if(y < 0){
        gameOver = true;
      } else {
        gridSquares[x][y] = blocks[i];
        gridSquares[x][y].setLocked(true);
      }
    }
    activeTetro = grabNextActiveTetro();
    this.render(false);
    //TODO: handle game over
  }
  
  private void lineClear(){
    boolean clearLine;
    boolean lineCleared = false;
    for(int line = 0; line < gridHeight; line++){
      clearLine = true;
      for(int square = 0; square < gridWidth; square++){
        if(!gridSquares[square][line].isLocked()){
          clearLine = false;
          break;
        }
      }
      if(clearLine){
        collapseSquares(line);
        lineCleared = true;
      }
    }
    if(lineCleared) this.render(true);
  }
  
  private void collapseSquares(int lineToClear){
    for(int line = lineToClear; line >= 0; line--){
      for(int square = 0; square < gridWidth; square++){
        if(line > 0) gridSquares[square][line] = gridSquares[square][line-1];
        else gridSquares[square][0] = new PTetrisBlock(emptySquareColor, emptySquareColor, color(0), 0);
      }
    }
  }
  
  private PTetromino[] generateTetroBag(int size){
    PTetromino tBag[] = new PTetromino[size];
    for(int i = 0; i < size; i++){
      tBag[i] = new PTetromino(new PVector(showNextPos.x, showNextPos.y), i, 0);
    }
    for(int i = 0; i < size-2; i++){
      int j = int(random(0,size-i));
      PTetromino t = tBag[i];
      tBag[i] = tBag[i+j];
      tBag[i+j] = t;
    }
    return tBag;
  }

  private PTetromino generateGhostTetro(PTetromino t){
    PTetromino g = new PTetromino(t.getPos(), t.getShapeType(), t.getOrientation());
    PTetrisBlock blocks[] = g.getBlocks();
    for(int i = 0; i < blocks.length; i++){
      color c1 = blocks[i].getOuterBlockColor();
      color c2 = blocks[i].getInnerBlockColor();
      blocks[i].setOuterBlockColor(color(c1, 125));
      blocks[i].setInnerBlockColor(color(c2, 125));
    }
    while(!checkFallCollision(g)){
      g.fall();
    }
    return g;
  }
  
  private PTetromino grabNextActiveTetro(){
    PTetromino t = tetroBag[nextTBagInd];
    t.setPos(new PVector(actStartPos.x, actStartPos.y));
    nextTBagInd = (nextTBagInd+1)%7;
    if(nextTBagInd == 0) tetroBag = generateTetroBag(7);
    return t;
  }
  
  public void setControlFlag(char c, int keyCode, boolean pressed, int pressTime){
    int keyInd = -1;
    if(c == CODED){
      
    } else {
      switch(c){
        case 'q':
        case 'Q':
          keyInd = 0;
          break;
        case 'd':
        case 'D':
          keyInd = 1;
          break;
        case 'z':
        case 'Z':
          keyInd = 2;
          break;
        case 'w':
        case 'W':
          keyInd = 3;
          break;
        case 's':
        case 'S':
          keyInd = 4;
          break;
        case ' ':
          keyInd = 5;
          break;
      }
    }
    if(keyInd != -1){
      if(pressed && !controlFlags[keyInd]) controlTime[keyInd] = pressTime;
      controlFlags[keyInd] = pressed;
    }
  }
}

class PTetrisGame{

  public PTetrisGame(){}


}