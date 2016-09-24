#!/usr/bin/env python3
import re

class Day:
    'Work day'

    def __init__(self, date):
        self.date = date
        self.sessions = []

    def add_session(self, session):
        self.sessions.append(session)

    def print_day(self):
        print(self.date)
        for s in self.sessions:
            s.print_session()
    

class Session:
    'Work session'

    def __init__(self, duration, cat, topic, desc=""):
        self.duration = duration
        self.cat = cat
        self.topic = topic
        self.desc = desc

    def print_session(self):
        print("session: ", self.duration, self.cat, self.topic, self.desc)
    

def add_to(f, d):
    line = next(f)
    while True:
        (cat, desc) = line.split("=", 2)
        d[cat] = desc.strip()
        line = next(f)
        if "###" in line:
            break


# 16:00 19:28 dev rwh - this is the description
def add_sessions(f, day, line):
    while True:
        print(line)
        (meta, desc) = line.split("-", 2)
        (start, end, cat, topic) = meta.split()
        duration = calc_duration(start, end)
        day.add_session(Session(duration, cat, topic, desc))

        line = next(f)
        print("l:", line)

        if not line.strip():
            break
        

def calc_duration(start, end):
    (sh, sm) = start.split(":", 2)
    (eh, em) = end.split(":", 2)

    shi = int(sh)
    smi = int(sm)
    ehi = int(eh)
    emi = int(em)

    if ehi == shi:
        duration = emi - smi
    
    if ehi < shi:
        ehi += 24

    duration = (ehi - shi - 1) * 60 + (60 - smi + emi)

g    return duration


CATEGORY_HEADER = "### Category Key #"
TOPIC_HEADER = "### Topic Key #"

categories = {}
topics = {}
days = []

regex = r'(\d{1,2})[/-](\d{1,2})[/-](\d{1,4})'

f = open("dev.md","r")
for line in f:
    if CATEGORY_HEADER in line:
        add_to(f, categories)
        
    if TOPIC_HEADER in line:
        add_to(f, topics)
        
    # parse individual sessions
    match = re.search(regex, line)
    if match:
        day = Day(match.group(0))
        days.append(day)
        day.print_day()
        line = next(f)                 # skip underline
        line = next(f)
        add_sessions(f, day, line)


print(categories)
print(topics)
        
for d in days:
    d.print_day()


