import socket
import datetime
from time import sleep

def service():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    while 1:
        text = datetime.datetime.now().strftime('%-I:%M')
        sock.sendto('next-beamer/clock/set:{}'.format(text), ('127.0.0.1', 4444))
        sleep(1)


if __name__ == '__main__':
    service()
