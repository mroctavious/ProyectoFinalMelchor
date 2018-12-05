# It echoes any incoming text messages.
import telebot
from telebot import types
import sys

API_TOKEN = sys.argv[1] #recibe el el token del bot telegram
VIDEO_PATH = sys.argv[2] #recibe el parametro del directrorio del video
ID_USER = sys.argv[3] #recibe el id chat del usuario de telegram
FECHA = sys.argv[4] #recibe la fecha en que se detecto movimiento
bot = telebot.TeleBot(API_TOKEN) #recibe el parametro API_TOKEN
bot.send_message(ID_USER, "ALERTA!!! \n") #manda mensaje de alerta al usuario indicado con el parametro recibido ID_USER
bot.send_message(ID_USER, "Se detecto movimiento: "+ FECHA + "\n ")  #manda mensaje al usuario indicado con el parametro recibido ID_USER
video_file = open(VIDEO_PATH, 'rb') #recibe el parametro del directrorio para enviarlo VIDEO_PATH
bot.send_video_note(ID_USER, video_file) #envia video al usuario cusuario indicado con el parametro recibido ID_USER

