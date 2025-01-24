# File name: Cap_vid.py
# Date: 13-11-2018
# Version: v0.1
# Explanation: This program capture video from Raspberrypi CSI camera using picamera function.
# Missing: nothing
# usage: python Cap_vid.py 
# created by: Bhavisha Parmar



# import the necessary packages
from picamera.array import PiRGBArray
from picamera import PiCamera
import time
import cv2

# initialize the camera and grab a reference to the raw camera capture
camera = PiCamera()
camera.resolution = (640, 480)
camera.framerate = 32
camera.rotation = 180
rawCapture = PiRGBArray(camera, size=(640, 480))

# allow the camera to warmup
time.sleep(0.1)
count=0
# capture frames from the camera
for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
    # grab the raw NumPy array representing the image, then initialize the timestamp
    # and occupied/unoccupied text
    image = frame.array
    #print(image)

    # show the frame
    cv2.imshow("Frame", image)
    #cv2.imwrite("Frame.jpg", image)
    key = cv2.waitKey(1) & 0xFF
    if key==ord('s'):
        cv2.imwrite("sq__n_"+ str(count) + ".jpg", image)
        count=count+1       

    # clear the stream in preparation for the next frame
    rawCapture.truncate(0)

    # if the `q` key was pressed, break from the loop
    if key == ord("q"):
        break