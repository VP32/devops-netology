#!/usr/bin/env python3

import logging
import random
import time

while True:

    number = random.randrange(0, 4)

    format = '{\"level\":\"%(levelname)s\",\"message\":\"%(message)s\"}'
    if number == 0:
        logging.basicConfig(format=format, level=logging.INFO)
        logging.info('Hello there!!')
    elif number == 1:
        logging.basicConfig(format=format, level=logging.WARNING)
        logging.warning('Hmmm....something strange')
    elif number == 2:
        logging.basicConfig(format=format, level=logging.ERROR)
        logging.error('OH NO!!!!!!')
    elif number == 3:
        logging.basicConfig(format=format, level=logging.DEBUG)
        logging.exception(Exception('this is exception'))

    time.sleep(1)