import SimpleOpenNI.*;
import fullscreen.*; 
import japplemenubar.*;

//FullScreen fs; 

SimpleOpenNI context;
//SimpleOpenNI context2;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);
//boolean      autoCalib=true;



PVector      bodyCenter = new PVector();
PVector      bodyDir = new PVector();
PVector      com = new PVector();                                   
PVector      com2d = new PVector();                                   
color[]       userClr = new color[] { 
  color(1), 
  color(1), 
  color(1), 
  color(1), 
  color(1), 
  color(1)
};

PVector[] dep1 = new PVector[307200];
PVector[] dep2 = new PVector[307200];
PVector[] dep3 = new PVector[307200];

float xx;
float yy;
float zz;

float xx2;
float yy2;
float zz2;


float xoff1 = 0.0;
float xoff2 = 0.0;
float xoff3 = 0.0;

float irX;
float irY;
float irZ;

float[] depX;
float[] depY;
float[] depZ;


float[] d2;
float[] d3;

float dd;
float m;


float ring1;
float ring2;
float[] ddd;
float[] ddd2;


boolean user = false;

/* Particle count. */
int particleCount = 30000;
int ha = 30000;
int start;
int i2;
//int ii = 0;
int i=0;
int[]   depthMap2;
int turn=0;
int jung = 1;

int stop=0;
int pointer=1;
int time = 5000;
int rd=250;
int onTime;

//int rd=250;


//FullScreen fs; 

/* Here we create a global Particle array using our particleCount  */
Particle[] particles = new Particle[particleCount+1];
//Particle[] particles = new Particle[0];


void setup()
{
  //  fs = new FullScreen(this); 
  size(1024, 768, P3D);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  //size(displayWidth, displayHeight);
  frameRate(30);
  noCursor();
  for (int x = particleCount; x >= 0; x--) { 
    /* We call the particle function inside its class to set up a new particle. Each is positioned randomly. */
    particles[x] = new Particle();
  }


  depX = new float[particleCount+1];
  depY = new float[particleCount+1];
  depZ = new float[particleCount+1];

  d2   = new float[307200];
  d3   = new float[307200];

  ddd = new float[307200];
  ddd2 = new float[307200];




  context = new SimpleOpenNI(this);
  // context2 = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // disable mirror
  context.setMirror(true);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  //stroke(255, 255, 255);
  smooth();  
  start=millis();
  perspective(radians(45), 
  float(width)/float(height), 
  10, 150000);


  depthMap2 = new int[307200];
  // fs.enter();
}

void draw()
{


  // update the cam
  context.update();

  background(0, 0, 0);

  // set the scene pos
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  //rotY += 0.05f;
  //rotX += 0.05f;
  int[]   depthMap = context.depthMap();

 // int[]   userMap = context.userMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  //float d;
  PVector realWorldPoint;
  float d;

  //float dd;

  //int ii = 0;

  m= millis()-start;

  translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera

  // draw the pointcloud



  if (user == false && m < time || user == true && m < time || user == false && m > time) {
    //println("m= "+ m);
    //jung=1;

    //int i=0;
    beginShape(POINTS);
    for (int y=0; y < context.depthHeight (); y+=steps)
    {
      for (int x=0; x < context.depthWidth (); x+=steps)
      {
        index = x + y * context.depthWidth();


        if (depthMap[index] > 0)
        {
          realWorldPoint = context.depthMapRealWorld()[index];

          irX = realWorldPoint.x;
          irY = realWorldPoint.y;
          irZ = realWorldPoint.z;


          if (i <= 30001) {
            dep1[i] = realWorldPoint;
            d = depthMap[x+y * context.depthWidth()];




            ddd[i] = map(d, 1500, 2500, 0, 255);

            stroke(255-ddd[i]);
            i++;
          } else {        
            i=0;
          }

          Particle particle = (Particle) particles[y];
          particle.update();

          ha--;
        }








        particleCount=30000;
      }
      ha=30000;
      arrayCopy(ddd, ddd2);
    }

    endShape();

    //if (user==true && m > time) {
    // }


    particleCount=30000;
  } else if (user==true && m > time)
  {

    stop=1;
    beginShape(POINTS);



    for (int i2=particleCount; i2 >= 0; i2--)
    {


      stroke(255-ddd[i2]);

      strokeWeight(1);

      irX = dep1[i2].x;

      irY = dep1[i2].y;
      irZ = dep1[i2].z;


      Particle particle = (Particle) particles[i2];
      particle.update();
    }



    endShape();

    turn=1;
  }







  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
      drawSkeleton(userList[i]);

    // draw the center of mass
    /*
    if (context.getCoM(userList[i], com))
     {
     stroke(100, 255, 0);
     strokeWeight(1);
     beginShape(LINES);
     vertex(com.x - 15, com.y, com.z);
     vertex(com.x + 15, com.y, com.z);
     
     vertex(com.x, com.y - 15, com.z);
     vertex(com.x, com.y + 15, com.z);
     
     vertex(com.x, com.y, com.z - 15);
     vertex(com.x, com.y, com.z + 15);
     endShape();
     
     fill(0, 255, 100);
     text(Integer.toString(userList[i]), com.x, com.y, com.z);
     }
     */
  }    

  // draw the kinect cam
  //context.drawCamFrustum();


  //pushMatrix();
  //translate(180, -84); 
  //rotate(PI/1.0);

  //context.setMirror(false);
  //image(context.depthImage(), 0, 0, 50, 50);
  //popMatrix();
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{


  // to get the 3d joint data
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  PVector leftHand = new PVector(); 
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, leftHand);
  // PVector convertedLeftHand = new PVector();
  // context.convertRealWorldToProjective(leftHand, convertedLeftHand);

  //stroke(0, 255, 0);
  //strokeWeight(30);
  //point(leftHand.x, leftHand.y, leftHand.z);


  //xx=leftHand.x;
  //yy=leftHand.y;
  //zz=leftHand.z;



  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  PVector rightHand = new PVector(); 
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, rightHand);



  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  PVector torso = new PVector(); 
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, torso);







  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  


  if ( pointer == 1) {
    xx=torso.x;
    yy=torso.y;
    zz=torso.z;
  } else if (pointer == 2) {

    xx=rightHand.x;
    yy=rightHand.y;
    zz=rightHand.z;

    xx2=leftHand.x;
    yy2=leftHand.y;
    zz2=leftHand.z;
    //println("pointer2 in= "+pointer);
  }




  // draw body direction
  // getBodyDirection(userId, bodyCenter, bodyDir);

  //bodyDir.mult(200);  // 200mm length
  // bodyDir.add(bodyCenter);

  //stroke(1);
  //line(bodyCenter.x, bodyCenter.y, bodyCenter.z, 
  //bodyDir.x, bodyDir.y, bodyDir.z);

  //strokeWeight(1);
}

void drawLimb(int userId, int jointType1, int jointType2)
{
  //PVector jointPos1 = new PVector();
  //PVector jointPos2 = new PVector();
  //float  confidence;

  // draw the joint position
  //confidence = context.getJointPositionSkeleton(userId, jointType1, jointPos1);
  //confidence = context.getJointPositionSkeleton(userId, jointType2, jointPos2);

  //stroke(255,0,0);
  //line(jointPos1.x, jointPos1.y, jointPos1.z, 
  //jointPos2.x, jointPos2.y, jointPos2.z);

  //drawJointOrientation(userId, jointType1, jointPos1, 50);
}

/*
void drawJointOrientation(int userId, int jointType, PVector pos, float length)
 {
 // draw the joint orientation  
 PMatrix3D  orientation = new PMatrix3D();
 float confidence = context.getJointOrientationSkeleton(userId, jointType, orientation);
 if (confidence < 0.001f) 
 // nothing to draw, orientation data is useless
 return;
 
 pushMatrix();
 translate(pos.x, pos.y, pos.z);
 
 // set the local coordsys
 applyMatrix(orientation);
 
 // coordsys lines are 100mm long
 // x - r
 stroke(255, 0, 0, confidence * 200 + 55);
 line(0, 0, 0, 
 length, 0, 0);
 // y - g
 stroke(0, 255, 0, confidence * 200 + 55);
 line(0, 0, 0, 
 0, length, 0);
 // z - b    
 stroke(0, 0, 255, confidence * 200 + 55);
 line(0, 0, 0, 
 0, 0, length);
 popMatrix();
 }
 */
// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  context.startTrackingSkeleton(userId);
  user = true;
  onTime = millis()+onTime;

  if (userId == 1) {
    start=millis();
  }
}


void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{

  setup();
  start=millis();
  turn=0;
  stop = 0;
  rd=250;
  user = false;

  println("onLostUser - userId: " + userId);
}

// -----------------------------------------------------------------
// Keyboard events
/*
void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }

  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if (keyEvent.isShiftDown())
      zoomF += 0.01f;
    else
      rotX += 0.1f;
    break;
  case DOWN:
    if (keyEvent.isShiftDown())
    {
      zoomF -= 0.01f;
      if (zoomF < 0.01)
        zoomF = 0.01;
    } else
      rotX -= 0.1f;
    break;
  }
}
*/

/*
void getBodyDirection(int userId, PVector centerPoint, PVector dir)
 {
 PVector jointL = new PVector();
 PVector jointH = new PVector();
 PVector jointR = new PVector();
 float  confidence;
 
 // draw the joint position
 confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, jointL);
 confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointH);
 confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, jointR);
 
 // take the neck as the center point
 confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, centerPoint);
 
/*  // manually calc the centerPoint
 PVector shoulderDist = PVector.sub(jointL,jointR);
 centerPoint.set(PVector.mult(shoulderDist,.5));
 centerPoint.add(jointR);
 */

// PVector up = PVector.sub(jointH, centerPoint);
//PVector left = PVector.sub(jointR, centerPoint);

//dir.set(up.cross(left));
//dir.normalize();



class Particle {
  /* Our global class variables. These variables will be kept track of for each frame and throughout each function. */
  /* x and y represents the coordinates. vx and vy represents the velocities or speed and direction of the particles. */
  float x;
  float x2;

  float y;
  float y2;

  float z;
  float z2;

  float vx;
  float vy;
  float vz;

  float vx2;
  float vy2;
  float vz2;
  int rd2=250;

  color c = get((int)x, (int)y);
  float xdis;


  /* We call this to set up a new particle. */
  Particle() {
  }

  /* Here we update the coordinates and redraw the particle. */
  void update() {


    if (turn==0) {

      // println("turn");
      x = irX;
      y = irY;
      z = irZ;
    }


    if (stop == 1) {

      float rx = xx;
      float ry = yy;
     // float rz = zz;


      float rx2 = xx2;
      float ry2 = yy2; 
      //float rz2 = zz2; 


      float radius = dist(x, y, rx, ry);
      float radius2 = dist(x, y, rx2, ry2);


      if (rd < 1500 &&  pointer == 1) {

        // println("rd1" + rd);
        rd = rd+50;
      } else {
        rd=150;
        pointer = 2;
      }
      
 xdis = rx-rx2;
 
 
      if (xdis < 1 && rd2 < 1500) {

        rd2 = rd2+50;
      } else {

      }


      if (radius < rd2) {

        /* atan2 is used to find the angle between the cursor and the particle. */
        float angle = atan2(y-ry, x-rx);

   
        if (rd2 < 1500) {
          vx -= (150 - radius) * 0.01 * cos(angle + (0.7 + 0.0005 * (150 - radius)));
          vy -= (150 - radius) * 0.01 * sin(angle + (0.7 + 0.0005 * (150 - radius)));
        } else 
        {  
        //vx -= (550 - radius) * 0.005 * cos(angle + (0.001 * (ring1 - radius)));
        //vy -= (550 - radius) * 0.005 * sin(angle + (0.001 * (ring2 - radius)));
        }


        //vz -= (150 - radius) * 0.005 * sin(angle + (0.001 * (ring2 - radius)));
        // println("radius= " + vx);
      }

      if (radius2 < 500 && pointer == 2) {
        /* atan2 is used to find the angle between the cursor and the particle. */
        float angle2 = atan2(y-ry2, x-rx2);


        vx2 -= (550 - radius2) * 0.005 * cos(angle2 + (0.001 * (ring1 - radius2)));
        vy2 -= (550 - radius2) * 0.005 * sin(angle2 + (0.001 * (ring2 - radius2)));
        // vz2 -= (150 - radius2) * 0.005 * sin(angle2 + (0.001 * (ring2 - radius2)));

        /* clock revers */
        //vx2 -= (150 - radius2) * 0.005 * cos(angle2 - (0.008 * (ring1 - radius2)));
        //vy2 -= (150 - radius2) * 0.005 * sin(angle2 - (0.001 * (ring2 - radius2)));

        //vx2 -= (150 - radius2) * 0.01 * cos(angle2 + (0.7 + 0.0005 * (150 - radius2)));
        //vy2 -= (150 - radius2) * 0.01 * sin(angle2 + (0.7 + 0.0005 * (150 - radius2)));
      }

      x += vx;
      y += vy;
      //z += vz;

      vx *= 0.97;
      vy *= 0.97;
      //vz *= 0.97;


      if (x > width+255) {
        vx *= -1;
        x = width+255;
      }
      if (x < width-2310) {
        vx *= -1;
        x = width-2310;
      }
      if (y > height+190) {
        vy *= -1;
        y = height+190;
      }
      if (y < -955) {
        vy *= -1;
        y = -955;
      }



      x += vx2;
      y += vy2;
      //z += vz;

      vx2 *= 0.97;
      vy2 *= 0.97;
      //vz *= 0.97;


      if (x > width+255) {
        vx2 *= -1;
        x = width+255;
      }
      if (x < width-2310) {
        vx2 *= -1;
        x = width-2310;
      }
      if (y > height+190) {
        vy2 *= -1;
        y = height+190;
      }
      if (y < -955) {
        vy2 *= -1;
        y = -955;
      }
    }


    /*
    //stroke(random(150, 255));
     pushMatrix();
     translate(0, 0, 2000); 
     
     point(x, y);
     
     popMatrix();
     
     */





    /*
    pushMatrix();
     translate(0, 0, 2000); 
     
     c = get((int)x, (int)y);
     
     if (1 == c ) {
     stroke(255);
     strokeWeight(10);
     point(x, y);
     println("in");
     } else {
     
     point(x, y);
     }
     
     popMatrix();
     
     */

    pushMatrix();
    translate(0, 0, 2000); 

    point(x, y);


    popMatrix();

    //point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
  }
} 


//boolean sketchFullScreen() {
//  return true;
//}
