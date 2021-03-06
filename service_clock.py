#!/usr/bin/env python3
import os
import socket
import datetime
from time import sleep

def service():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    while 1:
        text = datetime.datetime.now().strftime('%-I:%M')
        folder = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
        msg = '{}/clock/set:{}'.format(folder, text)
        sock.sendto(msg.encode(), ('127.0.0.1', 4444))
        sleep(1)


if __name__ == '__main__':
    service()
