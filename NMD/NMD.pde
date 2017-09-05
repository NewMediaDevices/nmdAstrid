import oscP5.*;
import netP5.*;
import processing.vr.*;
import android.app.Activity;
import android.os.Bundle;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.content.Context;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
 
OscP5 oscP5;
NetAddress network;
 
PShape grid;
float r;
color newColour;

Context context;
SensorManager manager;
Sensor gyroscope;
GyroscopeListener listener;
float ax, ay, az;

short[] buffer = null;
AudioRecord audioRecord = null;
int bufferSize= 1024;
float volume = 0;
int buflen;


void setup() {
  colorMode(HSB, 255);
  fullScreen(STEREO);
  //osc connect to computer
  oscP5 = new OscP5(this, 7000);
   network = new NetAddress("192.168.43.199", 10000);
  
  //gyroscope
  context = getActivity();
  manager = (SensorManager)context.getSystemService(Context.SENSOR_SERVICE);
  gyroscope = manager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
  listener = new GyroscopeListener();
  manager.registerListener(listener, gyroscope, SensorManager.SENSOR_DELAY_NORMAL);
  
  //sound
     
  int freq =44100;
  int chan = AudioFormat.CHANNEL_IN_MONO;
  int enc  = AudioFormat.ENCODING_PCM_16BIT;
  int src  = MediaRecorder.AudioSource.MIC;
  buflen = AudioRecord.getMinBufferSize(freq, chan, enc);
  audioRecord = new AudioRecord(src,freq,chan,enc,buflen);
 
  audioRecord.startRecording();
  buffer = new short[bufferSize];
  
  //grid
    grid = createShape();
    grid.beginShape(LINES);
    grid.stroke(255);
    for (int x = -10000; x < +10000; x += 250) {
      grid.vertex(x, +1000, +10000);
      grid.vertex(x, +1000, -10000);
    }
    for (int z = -10000; z < +10000; z += 250) {
      grid.vertex(+10000, +1000, z);
      grid.vertex(-10000, +1000, z);      
    }  
    grid.endShape();  
 
}

void draw() {

   background(0);
   lights();
   translate(width/2, height/2);
   shape(grid);
   
   //get volume
      int bufferReadResult = audioRecord.read(buffer, 0, bufferSize);
       volume = 100;
       for (int i = 0; i < bufferReadResult; i++) {
          volume = Math.max(Math.abs(buffer[i]), volume);
       }
       text("" + volume, 100, 100);
       //draw a sphere if you blow the mic/ talk to the mic
       if(volume>300){
        makeSphere(volume);   
  
       }  
        fill(newColour);
        sphere(r);
       //print pos
      // println("X: " + ax + "\nY: " + ay + "\nZ: " + az, 0, 0, width, height);
      
         sendMessage();
    
}

    void stop() {
      audioRecord.stop();
      audioRecord.release();
      audioRecord = null;
    }
    
    void makeSphere(float volume){
      //make sphere  
    noStroke();
    r = map(volume,300,10000,50,300);
    newColour = color(map(volume,300,10000,0,255),255,255);
 
  
    }
    
    class GyroscopeListener implements SensorEventListener {
      //get gyroscope values
    public void onSensorChanged(SensorEvent event) {
    ax = event.values[0];
    ay = event.values[1];
    az = event.values[2];   
    
  }
   public void onAccuracyChanged(Sensor gyropscope, int pos) {
  }
 
}
void sendMessage(){
  //send positions to computer
      OscMessage myMessage = new OscMessage("/position");
      myMessage.add(ax);
      myMessage.add(ay); 
      myMessage.add(az);
      /* send the message */
      oscP5.send(myMessage, network);
  
}