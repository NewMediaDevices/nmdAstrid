import oscP5.*;
import netP5.*;
 
OscP5 osc;
NetAddress network;
float x, y, z;
float s;
color newColour;
float ax, ay, az;


void setup() {
      size(1366,768,P3D);
      osc = new OscP5(this, 10000);
      network = new NetAddress("192.168.0.255",7000); 
}

void draw() {
        
        background(0);
        lights();
        translate(width/2, height/2);
        makeCube();
        rotateY(0.5);
        fill(newColour);
        rotateY(s);
        box(x,y,z);
       //print pos
      // println("X: " + ax + "\nY: " + ay + "\nZ: " + az, 0, 0, width, height);
    
}


    
    void makeCube(){
      //make sphere  
    noStroke();
    x = map(ax,-1,1,50,300);
    y = map(ay,-1,1,50,300);
    z = map(az,-1,1,50,300);
    s = az;
    newColour = color(map(ax,-1,1,0,255),map(ay,-1,1,0,255),map(az,-1,1,0,255));
    
    }
   
    void oscEvent(OscMessage theOscMessage) {
      if (theOscMessage.addrPattern().equals("/position")) {
      ax = theOscMessage.get(0).floatValue();
      ay = theOscMessage.get(1).floatValue();
      az = theOscMessage.get(2).floatValue();
      println(ax + "/x "+ ay + "/y " + az + "/z" + "message success");
  }
    
  }