import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BOARD)
led1 = 16
led2 = 18

GPIO.setup(led1,GPIO.OUT)     #Define pin 3 as an output pin
GPIO.setup(led2,GPIO.OUT)

count = 0

while True:	
	GPIO.output(led1,1)   #Outputs digital HIGH signal (5V) on pin 3
	GPIO.output(led2,1)
	time.sleep(1)      #Time delay of 1 second

	GPIO.output(led1,0)   #Outputs digital LOW signal (0V) on pin 3
	GPIO.output(led2,0)
	time.sleep(1) 