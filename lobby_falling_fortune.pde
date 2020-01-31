import oscP5.*;
import processing.sound.*;

SoundFile idleMusic;
SoundFile bgMusic;
SoundFile zoomMusic;
SoundFile fishMusic;
SoundFile firelilyMusic;
SoundFile mirrorMusic;

OscP5 oscP5;

PFont font;

/// LUKES CEILING FLIPPER ///
PGraphics pg;

int ceilingRGB_x = 79;
int ceilingRGB_y = 0;
int ceilingRGB_w = 293;
int ceilingRGB_h = 128;
 
/////////////////////////////

boolean debug = false;
boolean first = false;
boolean fading = false;

int loadedFrame = 0;
float fadeFrames = 0;
float fadeRate = 1;
int currIdleFrame = 0;

int idleAnimationFrameRate = 5;

Stick stick;
int maxSticks = 500;
Stick[] sticks = new Stick[maxSticks];


int idleAnimationX = 146;
int idleAnimationY = 81;

int animationX = 1000;
int animationY = 600;

int[] placeWindow = new int[2];
int[] placeWindowY = new int[0];

// for making random sticks at the lift
float sticksCD = 40;
float sticksFire = 0;

int idleFrames = 180; // 180
PImage[] idle = new PImage[idleFrames];

int fishFrames = 153; // 153
PImage[] fish = new PImage[fishFrames];

int firelilyFrames = 179; // 179
PImage[] firelily = new PImage[firelilyFrames];

int mirrorFrames = 164; // 164
PImage[] mirror = new PImage[mirrorFrames];

void setup() {
    // fullScreen(P3D);
    placeWindow[0] = -3;
    placeWindow[1] = -26;

    size(607, 256, P3D);


    surface.placeWindow(placeWindow, placeWindowY);
    background(125);

    pg = createGraphics(width, height, P3D);

    //println(PFont.list());

    font = createFont("Impact", 32);
    textFont(font);
    textAlign(CENTER, CENTER);

    oscP5 = new OscP5(this, 10001);

    //loading idle frames
    println("loading idle animation");
    for(int i=0; i<idle.length; i++) {
        if(i < 10) {
            idle[i] = loadImage("idling_AME/idling00" + str(i) + ".png");
        } 

        if(i >= 10 && i < 100) {
            idle[i] = loadImage("idling_AME/idling0" + str(i) + ".png");
        } 

        if(i >= 100) {
            idle[i] = loadImage("idling_AME/idling" + str(i) + ".png");
        }     

        idle[i].resize(idleAnimationX, idleAnimationY);

        loadedFrame++;
        println(loadedFrame);

    }
    println("idle loaded");


    //loading broken mirror frames
    println("loading mirror animation");
    for(int i=0; i<mirror.length; i++) {
        if(i < 10) {
            mirror[i] = loadImage("mirror_png/broken_mirrors00" + str(i) + ".png");
        } 

        if(i >= 10 && i < 100) {
            mirror[i] = loadImage("mirror_png/broken_mirrors0" + str(i) + ".png");
        } 

        if(i >= 100) {
            mirror[i] = loadImage("mirror_png/broken_mirrors" + str(i) + ".png");
        }     

        mirror[i].resize(animationX, animationY);

        loadedFrame++;
        println(loadedFrame);

    }
    println("mirror loaded");

    // loading fish frames 
    println("loading fish animation");
    for(int i=0; i<fish.length; i++) {
        if(i < 10) {
            fish[i] = loadImage("fish_growth_AME/fish00" + str(i) + ".png");
        } 
        
        if(i >= 10 && i < 100) {
            fish[i] = loadImage("fish_growth_AME/fish0" + str(i) + ".png");
        }

        if(i >= 100) {
            fish[i] = loadImage("fish_growth_AME/fish" + str(i) + ".png");
        }
        fish[i].resize(animationX, animationY);

        loadedFrame++;
        println(loadedFrame);
        
    }
    println("fish loaded");
    
    // loading firelily frames 
    println("loading firelily animation");
    for(int i=0; i<firelily.length; i++) {
        if(i < 10) {
            firelily[i] = loadImage("lilipadfire_AME/firepads00" + str(i) + ".png");
        } 
        
        if(i >= 10 && i < 100) {
            firelily[i] = loadImage("lilipadfire_AME/firepads0" + str(i) + ".png");
        }

        if(i >= 100) {
            firelily[i] = loadImage("lilipadfire_AME/firepads" + str(i) + ".png");
        }
        firelily[i].resize(animationX, animationY);
        

        loadedFrame++;
        println(loadedFrame);

    }
    println("firelily loaded");

    println("loading music");

    idleMusic = new SoundFile(this, "sounds/idleMusic.mp3");
    bgMusic = new SoundFile(this, "sounds/bgMusic.mp3");
    zoomMusic = new SoundFile(this, "sounds/zoomMusic.mp3");
    fishMusic = new SoundFile(this, "sounds/fishMusic.mp3");
    firelilyMusic = new SoundFile(this, "sounds/firelilyMusic.mp3");
    mirrorMusic = new SoundFile(this, "sounds/mirrorMusic.mp3");

    println("load complete");

    idleMusic.play();
    idleMusic.jump(3);

}

class Stick {
    // constructor variables
    int originX, originY, arrayPos;
    float originRot, scale;
    boolean forLifts;

    boolean isRotating = true;
    boolean zoomed = false;
    boolean playAnimation = false;
    boolean zooming = false;

    float imageScaling = 0;
    float imagePosLerp = 0;
    
    int randomR = int(random(255));
    int randomG = int(random(255));
    int randomB = int(random(255));

    int animationFrame = 0;

    int initFrameCount = frameCount;
    int lastFrameCount;

    float finalXrotation, finalYrotation, finalZrotation;

    float lerpRotationRate;
    float lerpZoomRate;
    float lerpTextRate;

    String fortuneNum; //2-fish story,  82-water lily, 4-mirror

    float initTextSize = 6.0;
    float maxTextSize = 20.0;

    float yPos = 0;
    int zPos = 0;
    float fallSpeed;

    float xRotation, yRotation, zRotation;
    int xRotationRate = int(random(16, 64));
    int yRotationRate = int(random(16, 64));
    int zRotationRate = int(random(16, 64));

    int boxX = 3; //44.5
    int boxY = 3;
    int boxZ = 10;
    int bodyZ = 50;
    int[] headSize = { boxX, boxY, boxZ};
    int[] bodySize = { boxX, boxY, bodyZ-boxZ};

    Stick (
        int x, int y, float rot, 
        float s, boolean lifts, float fs,
        int arrayPos, String fn
    ) {
        originX = x;
        originY = y;
        originRot = rot;
        scale = s;
        forLifts = lifts;
        fallSpeed = fs;
        fortuneNum = fn;
    }

    void display() {
        yPos += fallSpeed;

        push();

        //translate to set rotation origin
         
        if (!forLifts) {
            translate(originX-yPos, originY);
        } else {
            translate(originX, originY+yPos);
        }
        
        rotate(originRot);
        
        if (isRotating) {

            rotateX((PI+frameCount)/xRotationRate);
            rotateY((PI+frameCount)/yRotationRate);
            rotateZ((PI+frameCount)/zRotationRate);

            lastFrameCount = frameCount - initFrameCount;

        } else {

            finalXrotation = (PI+lastFrameCount)/xRotationRate;
            finalYrotation = (PI+lastFrameCount)/yRotationRate;
            finalZrotation = (PI+lastFrameCount)/zRotationRate;

            stickRepos();
            
        }

        scale(scale);
        //draw body here
        noStroke();
        fill(248, 160, 60);
        box(bodySize[0], bodySize[1], bodySize[2]);

        //translate forward to draw head
        translate(0, 0, bodyZ/2);
        fill(169, 52, 42);
        box(headSize[0], headSize[1], headSize[2]);

        fill(255);

        if(zooming) {
            if(initTextSize < maxTextSize) {
                initTextSize += 0.2;
            } else {
                initTextSize = maxTextSize;
            }
        }

        textMode(SHAPE);
        textSize(initTextSize);


        // draw text on the head
        rotateX(-PI/2);
        
        if(zooming) {
            // lerpTextRate += 0.2;

            float textXfinalZoom = -20;
            float textYfinalZoom = -1;

            float textPosXLerp = lerp(-boxX/2+2, textXfinalZoom, lerpZoomRate);
            float textPosYLerp = lerp(0, textYfinalZoom, lerpZoomRate);

            // float textSizeLerp = lerp(initTextSize, maxTextSize, lerpTextRate);
            
            text(fortuneNum, textPosXLerp, textYfinalZoom, boxX/2);

            // textSize(textSizeLerp);

        } else {
            text(fortuneNum, -boxX/2+2, 0, boxX/2);

            // textSize(initTextSize);
        }
        
        pop();
        

        if (64-yPos <= 0 && !forLifts) {
            fallSpeed = 0;
            isRotating = false;
        }

        // if (originY+yPos > height) {
        //     sticks[arrayPos] = null;
        //     println("stick at " + arrayPos + " deleted.");
        // }
        
        if(zoomed) {
            playAnimation();
        }

    }

    void stickRepos() {

        float xlerpRadians = lerp((PI+frameCount)/xRotationRate, PI/2, lerpRotationRate);
        float ylerpRadians = lerp((PI+frameCount)/yRotationRate, 0, lerpRotationRate);
        float zlerpRadians = lerp((PI+frameCount)/zRotationRate, 0, lerpRotationRate);

        rotateX(xlerpRadians);
        rotateY(ylerpRadians);
        rotateZ(zlerpRadians);

        if (lerpRotationRate < 1.0) {
            lerpRotationRate += 0.005;
        } else {
            lerpRotationRate = 1;

            zoomStick();
            
        }
    }

    void zoomStick() {
        zooming = true;

        if (!zoomMusic.isPlaying() && !zoomed) {
            
            zoomMusic.play();
            zoomMusic.jump(1.0);
        }
            
        float yfinalZoom = 7;
        float zfinalZoom = 0;

        float yLerpZoom = lerp(0, yfinalZoom, lerpZoomRate);
        float zLerpZoom = lerp(0, zfinalZoom, lerpZoomRate);

        translate(0, yLerpZoom, zLerpZoom);

        if (lerpZoomRate < 1.0) {
            lerpZoomRate += 0.01;
        } else {
            lerpZoomRate = 1;
            zoomed = true;
        }
    }

    void playAnimation() {
        // used in frameCount % animationFrameRate to determine play speed
        // higher the animationFrameRate, the slower the play speed
        int animationFrameRate = 4;
        float maxImageScale = 0.2;
        int rectPadding = 50;
        float secondImageScale = 0.68;
        
        push();

        // translate(width/2, height/2);
        translate(boxZ, 105); 

        if(imageScaling < maxImageScale) {
            imageScaling += 0.001;
        }  else {
            imageScaling = maxImageScale;
            playAnimation = true;
        }

        float imageXoffset = 0;

        float imageXPos = lerp(0, 1100, imagePosLerp);
        float imageYPos = lerp(0, -200, imagePosLerp);

        float imageXPos2 = lerp(0, -260, imagePosLerp);
        float imageYPos2 = lerp(0, -200, imagePosLerp);

        if (imagePosLerp < 1) {
            imagePosLerp += 0.01;
        } else {
            imagePosLerp = 1;
        }

        scale(imageScaling);

        rectMode(CENTER);
        noStroke();
        fill(0);
        
        

        
        if(playAnimation && frameCount % animationFrameRate == 0) {
            animationFrame += 1;
        }

        imageMode(CENTER);



        //2-fish story,  82-water lily, 4-mirror
        if (fortuneNum == "2") {

            if (!fishMusic.isPlaying() && imagePosLerp == 1) {
                bgMusic.stop();
                fishMusic.play();
                fishMusic.jump(2);
            }

            // fishMusic.play();
            image(fish[(animationFrame)%fishFrames], imageXPos, imageYPos);

            rotate(PI/2);
            scale(secondImageScale);

            image(fish[(animationFrame)%fishFrames], imageXPos2, imageYPos2);

            if(animationFrame > fishFrames) {
                animationFrame = fishFrames;
            }

        }

        if (fortuneNum == "82") {
            // firelilyMusic.play();

            if (!firelilyMusic.isPlaying()  && imagePosLerp == 1) {
                bgMusic.stop();
                firelilyMusic.play();
            }

            image(firelily[(animationFrame)%firelilyFrames], imageXPos, imageYPos);

            rotate(PI/2);
            scale(secondImageScale);

            image(firelily[(animationFrame)%firelilyFrames], imageXPos2, imageYPos2);
            
            if(animationFrame > firelilyFrames) {
                animationFrame = firelilyFrames;
            }
        }


        if (fortuneNum == "4") {
            // mirrorMusic.play();
            if (!mirrorMusic.isPlaying() && imagePosLerp == 1) {
                bgMusic.stop();
                mirrorMusic.play();
            }
            image(mirror[(animationFrame)%mirrorFrames], imageXPos, imageYPos);

            rotate(PI/2);
            scale(secondImageScale);
            
            image(mirror[(animationFrame)%mirrorFrames], imageXPos2, imageYPos2);
        
            if(animationFrame > mirrorFrames) {
                animationFrame = mirrorFrames;
            }
        }

        pop();
    }

}

void draw() {
    background(30);

    if (frameCount - sticksFire >= sticksCD) {
        createStickAtLift();
        sticksFire = frameCount;
    }

    for(int k=0; k<sticks.length; k++) {
        if(sticks[k] != null) {
            sticks[k].display();
        }
    }

    if (debug) {
        noFill();
        stroke(255, 0, 0);
        rect(1, 0, 78, 128); //museum door wall, rgb
        rect(79, 0, 293, 128); //ceiling, rgb
        rect(1, 128, 78, 128); //museum door wall, grayscale
        rect(79, 128, 293, 128); //ceiling, grayscale
        rect(373, 0, 78, 249); //left lift, rgb
        rect(451, 0, 78, 249); //centre lift, rgb
        rect(527, 0, 80, 249); //right lift, rgb
    }

    if (!first) {

        if(frameCount % idleAnimationFrameRate == 0) {
            currIdleFrame += 1;
        }

        push();

        translate(39, 90);
        rotate(PI/2);

        imageMode(CENTER);

        image(idle[currIdleFrame%idleFrames], 0, 0);

        pop();
    }


    if (first) {

        stick.display();
        noStroke();

        push();

        translate(0, 0, 5);
        rect(330, 0, 43, 128);

        pop();
    }

    fill(0);
    rect(1, 128, 78, 128); //museum door wall, grayscale
    rect(79, 128, 293, 128); //ceiling, grayscale

    //// Luke's ceiling flipper ////
    loadPixels();
    pg.beginDraw();
    pg.loadPixels();

    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            if ((x >= ceilingRGB_x) && (x < ceilingRGB_x+ceilingRGB_w) && (y < ceilingRGB_y+ceilingRGB_h)) {
                int newy = (ceilingRGB_y+ceilingRGB_h)-y;
                pg.pixels[x+y*width] = pixels[x + newy*width];
            } else {
                pg.pixels[x+y*width] = pixels[x+y*width];
            }
        }
    }    
    // ceilingRGB_x
    pg.updatePixels();
    pg.endDraw();
    updatePixels();
    image(pg, 0, 0, width, height);

}

void keyReleased() {

    //2-fish story,  82-water lily, 4-mirror
    if (keyCode == 49 && !first) {
        stick = new Stick(64, 105, PI/2, 1, false, 0.5, 51, "2");
        idleMusic.stop();
        bgMusic.play();
        bgMusic.jump(2);

        first = true;
    } 

    if (keyCode == 50 && !first) {
        stick = new Stick(64, 105, PI/2, 1, false, 0.5, 51, "82");
        idleMusic.stop();
        bgMusic.play();
        bgMusic.jump(2);
        first = true;
    } 

    if (keyCode == 51 && !first) {
        stick = new Stick(64, 105, PI/2, 1, false, 0.5, 51, "4");
        idleMusic.stop();
        bgMusic.play();
        bgMusic.jump(2);
        first = true;
    } 

    if (keyCode == 57 && first) {
        currIdleFrame = 0; 

        idleMusic.play();
        idleMusic.jump(3.1);
        fishMusic.stop();
        //firelilyMusic.stop();
        //mirrorMusic.stop();

        first = false;
    }

    println(keyCode);

}


// void oscEvent(OscMessage message) {
//     //2-fish story,  82-water lily, 4-mirror

//     println("Address pattern: " + message.addrPattern(), 
//             ". TypeTag: " + message.typetag(),
//             "Type of address pattern: " + message.addrPattern().getClass()
//     );

//     if(message.addrPattern() == "/1/push1" && !first) {
//         print("hello 1 push");
//         stick = new Stick(64, 105, PI/2, 1, false, 0.5, 51, "2");
//         first = true;
//     }

//     if(message.addrPattern() == "/1/push6" && !first) {
//         print("hello 6 push");
//         stick = new Stick(64, 105, PI/2, 1, false, 0.5, 51, "84");
//         first = true;
//     }

//     if(message.addrPattern() == "/1/push12" && !first) {
//         print("hello 12 push");
//         stick = new Stick(64, 105, PI/2, 1, false, 0.5, 51, "4");
//         first = true;
//     }

//     if (message.addrPattern() == "/1/push9" && first) {
//         print("hello 9 push");
//         first = false;
//     }
// }

void createStickAtLift() {
    
    int liftsWidth = 380;
    int xOrigin = int(random(liftsWidth, width));
    float scale = random(2);
    float fallSpeed = random(0.1, 2);

    for(int k=0; k<sticks.length; k++) {
        if(sticks[k] == null) {
            sticks[k] = new Stick(xOrigin, 0, 0, scale, true, fallSpeed, k, "");
            return;
        }
    }
    
}
