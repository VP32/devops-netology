#!/usr/bin/env python3

import logging
import random
import time
import sentry_sdk

sentry_sdk.init(
    dsn="https://29e9aaffdb7a460181872f95b16efcfd@o4504128959807488.ingest.sentry.io/4504128981237760",

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=1.0
)

while True:

    number = random.randrange(0, 5)

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
        logging.exception(Exception('this is exception'), exc_info=True)
    elif number == 4:
        logging.basicConfig(format=format, level=logging.ERROR)
        logging.error("Sample error!")

    time.sleep(1)