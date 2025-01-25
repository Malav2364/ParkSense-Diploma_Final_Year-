# import the necessary packages
from picamera.array import PiRGBArray
from picamera import PiCamera
import RPi.GPIO as GPIO
import time
import cv2
from firebase import firebase
import requests
import json

############for notification#################
serverToken = 'Insert your Server Token'
serverid='Your Server ID'
global headers
headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=' + serverToken,
        'sender':'id='+serverid,
      }
#Set Firebase link
firebase = firebase.FirebaseApplication('https://smart-parking-72b0a.firebaseio.com/',None)

      
############pin number##########
p_led=19
w_led1=3
g_led1=5

w_led2=8
g_led2=10

w_led3=11
g_led3=13

w_led4=16
g_led4=18

############pi pin setup##########################
GPIO.setmode(GPIO.BOARD)
GPIO.setup(w_led1,GPIO.OUT)     #Define pin 3 as an output pin
GPIO.setup(w_led2,GPIO.OUT)
GPIO.setup(w_led3,GPIO.OUT)
GPIO.setup(w_led4,GPIO.OUT)
GPIO.setup(g_led1,GPIO.OUT)
GPIO.setup(g_led2,GPIO.OUT)
GPIO.setup(g_led3,GPIO.OUT)
GPIO.setup(g_led4,GPIO.OUT)
GPIO.setup(p_led,GPIO.OUT)
GPIO.output(w_led1,0)
GPIO.output(g_led1,1)
GPIO.output(w_led2,0)
GPIO.output(g_led2,1)
GPIO.output(w_led3,0)
GPIO.output(g_led3,1)
GPIO.output(w_led4,0)
GPIO.output(g_led4,1)
GPIO.output(p_led,1)
 
# initialize the camera and grab a reference to the raw camera capture
camera = PiCamera()
camera.resolution = (640, 480)
camera.framerate = 32
camera.rotation = 180
rawCapture = PiRGBArray(camera, size=(640, 480))
 
# allow the camera to warmup
time.sleep(0.1)

def detect_car(image,slot):
    contours,hier = cv2.findContours(image, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)# find contours from mask
    length=0
    for cnt in contours:
        area=cv2.contourArea(cnt)        
        if area>=4500 and (slot=="3" or slot=="4"):
            length+=1
            #print("slot:"+slot)
            #print(area)
        elif area>=1000 and (slot=="1" or slot=="2"):
            length+=1
            #print("slot:"+slot)
            #print(area)
    if length==1:
        return True
    elif length==0:    
        return False

counter=0
f1=0
f2=0
f3=0
f4=0

result = firebase.put('parking','ccar1', 'off')
result = firebase.put('parking','ccar2', 'off')
result = firebase.put('parking','ccar3', 'off')
result = firebase.put('parking','ccar4', 'off')
 
# capture frames from the camera
for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
    # grab the raw NumPy array representing the image, then initialize the timestamp
    # and occupied/unoccupied text
    image = frame.array
    if counter<5:
        counter=counter+1
    elif counter==5:
        back=image
        counter=counter+1
    else:
        sub=cv2.subtract(image, back)
        gray = cv2.cvtColor(sub, cv2.COLOR_BGR2GRAY)
        th = cv2.threshold(gray, 30, 255, cv2.THRESH_BINARY)[1]
        th = cv2.erode(th, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3,3)), iterations = 2)
        th = cv2.dilate(th, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3,3)), iterations = 2)
        slot1_v=detect_car(th[150:280,80:250],'1')
        slot2_v=detect_car(th[150:250,320:490],'2')
        slot4_v=detect_car(th[350:480,40:320],'4')
        slot3_v=detect_car(th[300:480,420:640],'3')
        if slot1_v==True and f1==0:
            GPIO.output(w_led1, True)
            GPIO.output(g_led1, False)
            print("spot 1 is occupied")
            start=time.strftime("%H_%M_%S")
            result = firebase.put('parking','ccar1', 'on')
            body = {
            'notification': {'title': 'Slot 1',
                                'body': 'Slot 1 is occupied'
                                },
            'to':'/topics/ccar1',
            }
            response = requests.post("https://fcm.googleapis.com/fcm/send",headers = headers, data=json.dumps(body))
            #print(response.status_code)
            #print(response.json())
            f1=1
        elif slot1_v==False and f1==1:
            GPIO.output(w_led1, False)
            GPIO.output(g_led1, True)
            print("spot 1 is not occupied")
            start=time.strftime("%H_%M_%S")
            result = firebase.put('parking','ccar1', 'off')
            body = {
            'notification': {'title': 'Slot 1',
                                'body': 'Slot 1 is not occupied'
                                },
            'to':'/topics/ccar1',
            }
            response = requests.post("https://fcm.googleapis.com/fcm/send",headers = headers, data=json.dumps(body))
            #print(response.status_code)
            #print(response.json())
            f1=0
        if slot2_v==True and f2==0:
            GPIO.output(w_led2, True)
            GPIO.output(g_led2, False)
            print("spot 2 is occupied")
            start=time.strftime("%H_%M_%S")
            result = firebase.put('parking','ccar2', 'on')
            body = {
            'notification': {'title': 'Slot 2',
                                'body': 'Slot 2 is occupied'
                                },
            'to':'/topics/ccar2',
            }
            response = requests.post("https://fcm.googleapis.com/fcm/send",headers = headers, data=json.dumps(body))
            print(response.status_code)
            print(body)
            f2=1
        elif slot2_v==False and f2==1:
            GPIO.output(w_led2, False)
            GPIO.output(g_led2, True)
            print("spot 2 is not occupied")
            start=time.strftime("%H_%M_%S")
            result = firebase.put('parking','ccar2', 'off')
            body = {
            'notification': {'title': 'Slot 2',
                                'body': 'Slot 2 is not occupied'
                                },
            'to':'/topics/ccar2',
            }
            response = requests.post("https://fcm.googleapis.com/fcm/send",headers = headers, data=json.dumps(body))
            print(response.status_code)
            print(body)
            f2=0
        if slot3_v==True and f3==0:
            GPIO.output(w_led3, True)
            GPIO.output(g_led3, False)
            print("spot 3 is occupied")
            start=time.strftime("%H_%M_%S")
            result = firebase.put('parking','ccar3', 'on')
            body = {
            'notification': {'title': 'Slot 3',
                                'body': 'Slot 3 is occupied'
                                },
            'to':'/topics/ccar3',
            }
            response = requests.post("https://fcm.googleapis.com/fcm/send",headers = headers, data=json.dumps(body))
            #print(response.status_code)
            #print(response.json())
            f3=1
        elif slot3_v==False and f3==1:
            GPIO.output(w_led3, False)
            GPIO.output(g_led3, True)
            print("spot 3 is not occupied")
            start=time.strftime("%H_%M_%S")
            result = firebase.put('parking','ccar3', 'off')
            body = {
            'notification': {'title': 'Slot 3',
                                'body': 'Slot 3 is not occupied'
                                },
            'to':'/topics/ccar3',
            }
            response = requests.post("https://fcm.googleapis.com/fcm/send",headers = headers, data=json.dumps(body))
            #print(response.status_code)
            #print(response.json())
            f3=0
        if slot4_v==True and f4==0:
            GPIO.output(w_led4, True)
            GPIO.output(g_led4, False)
            print("spot 4 is occupied")
            start=time.strftime("%H_%M_%S")
            result = firebase.put('parking','ccar4', 'on')
            body = {
            'notification': {'title': 'Slot 4',
                                'body': 'Slot 4 is occupied'
                                },
            'to':'/topics/ccar4',
            }
            response = requests.post("https://fcm.googleapis.com/fcm/send",headers = headers, data=json.dumps(body))
            #print(response.status_code)
            #print(response.json())
            f4=1
        elif slot4_v==False and f4==1:
            GPIO.output(w_led4, False)
            GPIO.output(g_led4, True)
            print("spot 4 is not occupied")
            start=time.strftime("%H_%M_%S")
            result = firebase.put('parking','ccar4', 'off')
            body = {
            'notification': {'title': 'Slot 4',
                                'body': 'Slot 4 is not occupied'
                                },
            'to':'/topics/ccar4',
            }
            response = requests.post("https://fcm.googleapis.com/fcm/send",headers = headers, data=json.dumps(body))
            #print(response.status_code)
            #print(response.json())
            f4=0 
        cv2.imshow("Frame", th)
        cv2.imshow("original frame", image)
        key = cv2.waitKey(1) & 0xFF
        if key == ord("q"):
            break 
    # clear the stream in preparation for the next frame
    rawCapture.truncate(0)
 
#     # if the `q` key was pressed, break from the loop
#     if key == ord("q"):
#         break
