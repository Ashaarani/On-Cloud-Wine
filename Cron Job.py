# -*- coding: utf-8 -*-
"""
Created on Wed Apr 10 17:12:17 2024

@author: krall
"""

#pip install schedule
import schedule
import time

dir = 'C:\\Users\\krall\\.spyder-py3\\Import to SQL Combined.py'

def job(dir):
#job logic goes here
# Schedule the job to run on the first day of every month
    schedule.every().day.at("17:28").do(job)
# Run the scheduler continuously

while True: 
    schedule.run_pending()
    time.sleep(1)