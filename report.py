#!/usr/bin/env python3
import re
import argparse
import time
import datetime

"""
Print report of log files.

report --categories --topics --by-category --by-topic September.md

"""

CATEGORY_HEADER = "### Category Key"
TOPIC_HEADER = "### Topic Key"

categories = {}
topics = {}
DAYS = []

regex = r'(\d{1,2})[/-](\d{1,2})[/-](\d{1,4})'

def parse_log_files(files):
    """parse list of files"""
    for f in files:
        parse_log_file(f)
        
def parse_log_file(log_file):
    """parse file"""
    f = open(log_file,"r")
    for line in f:
        if CATEGORY_HEADER in line:
            add_to(f, categories)
            
        if TOPIC_HEADER in line:
            add_to(f, topics)
        
        # parse individual sessions
        match = re.search(regex, line)
        if match:
            day = Day(match.group(0))
            DAYS.append(day)
            line = next(f)                 # skip underline
            line = next(f)                 # get first log entry
            add_sessions(f, day, line)

def add_to(f, dictionary):
    """Parse f for lines of form 'code = description', add to dictionary"""
    line = next(f)
    while True:
        (code, desc) = line.split("=", 2)
        code = code.strip()
        desc = desc.strip()
        if not code in dictionary:
            dictionary[code] = desc
        else:
            if dictionary[code] != desc:
                print("Warning: multiple descriptions found (for code)",
                      code, dictionary[code], desc)

        line = next(f)
        if not line.strip():    # break on empty line
            break

# form: '16:00 19:28 dev rwh - this is the description'
def add_sessions(f, day, line):
    """Parse f for lines, create session and add to day."""
    while True:
        if "-" in line:
            (meta, desc) = line.split("-", 2)
        else:
            meta = line.strip()
            desc = ""
        (start, end, cat, topic) = meta.split()

        duration = calc_duration(start, end)
        day.add_session(Session(duration, cat, topic, desc))

        line = next(f)
        if not line.strip():    # break on empty line
            break
        
# time format: '13:20' 
def calc_duration(start, end):
    """Return duration in minutes"""
    (shs, sms) = start.split(":", 2)
    (ehs, ems) = end.split(":", 2)

    sh = int(shs)
    sm = int(sms)
    eh = int(ehs)
    em = int(ems)

    if eh == sh:
        duration = em - sm
    
    if eh < sh:
        eh += 24

    duration = (eh - sh - 1) * 60 + (60 - sm + em)
    
    return duration

def total_hours(days):
    """Return total hours from days."""
    total = 0
    for d in days:
        total += d.total_hours()

    return total

def merge(d, e):
    """Merge two dictionaries"""
    merged = {}
    
    for k in d:
        increment_key_value(merged, k, d[k])
    
    for k in e:
        increment_key_value(merged, k, e[k])

    return merged

def increment_key_value(d, k, v):
    """Add k,v to d, if key already present increment d[k]"""
    if k in d:
        d[k] += v
    else:
        d[k] = v


class Day:
    """Work day"""

    def __init__(self, date):
        self.date = date
        self.sessions = []

    def add_session(self, session):
        self.sessions.append(session)

    def total_hours(self):
        minutes = 0
        for s in self.sessions:
            minutes += s.duration

        return minutes // 60

    def print_day(self):
        print(self.date)
        for s in self.sessions:
            s.print_session()
        print("")

    def minutes_by_category(self):
        acc = {}
        for s in self.sessions:
            increment_key_value(acc, s.cat, s.duration)

        return acc

    def minutes_by_topic(self):
        acc = {}
        for s in self.sessions:
            increment_key_value(acc, s.topic, s.duration)

        return acc
            

class Session:
    """Work session"""

    def __init__(self, duration, cat, topic, desc=""):
        self.duration = duration
        self.cat = cat
        self.topic = topic
        self.desc = desc

    # is this the 'python way' to do this?
    def minutes(self):
        return self.duration

    def hours(self):
        return self.duration // 60
    
    def print_session(self):
        print("session: ", self.duration, self.cat, self.topic, self.desc, end="")

# output functions

def dump():
    print(categories)
    print(topics)
        
    for d in days:
        d.print_day()
        
def show_categories():
    show_dictionary(categories, "Categories")
        
def show_topics():
    show_dictionary(topics, "Topics")

def show_dictionary(d, title):
    """Pretty print dictionary"""
    print(title, ":")
    for c in title:
        print("-", end="")
    print("--\n")
    
    pp_dict(d)

def pp_dict(d):       
    for k in sorted(d):
        print(k, ":", d[k])
    print("")

def days_today(days):
    """Return singular list of today's Day."""
    now = datetime.datetime.now()
    date = now.strftime("%d/%m/%y")

    for d in days:
        if d.date == date:
            return [d]

    return None

def days_this_week(days):
    """Return list of this weeks Days."""
    week = []
    for d in days:
        if is_this_week(d.date):
            week.append(d)

    return week

# date form: dd/mm/yy
def is_this_week(date):
    """this week is defined as last Sunday until today."""
    now = datetime.datetime.now()
    today = now.strftime("%d/%m/%y")

    (td, tm, ty) = today.split("/", 3)
    (dd, dm, dy) = date.split("/", 3)
                    
    if ty != dy or tm != dm:
        return False

    n = todays_day_number()

    if int(dd) + n >= int(td):
        return True

    return False

def todays_day_number():
    dow = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    now = datetime.datetime.now()
    day = now.strftime("%A")

    for i in range(7):
        if dow[i] == day:
            return i

    return -1                   # error
    
def log_file_for_this_month():
    """Return name of this month."""
    now = datetime.datetime.now()
    return now.strftime("%B") + '.md'
    
def show_stats(days):
    td = len(days)
    th = total_hours(days)

    print("Total days worked: ", td)
    print("Total hours logged: ", th)
    print("")

def show_by_category(days):
    totals = {}
    print("Hours worked by category:")
    print("-------------------------")

    for d in days:
        totals = merge(totals, d.minutes_by_category())

    for k in totals:
        print(k, ": ", end="")
        pp_minutes(totals[k])

    print("")

def show_by_topic(days):        
    totals = {}
    print("Hours worked by topic:")
    print("----------------------")

    for d in days:
        totals = merge(totals, d.minutes_by_topic())

    for k in totals:
        print(k, ": ", end="")
        pp_minutes(totals[k])

    print("")

def pp_minutes(m):
    """Pretty print minutes"""
    h = m // 60
    r = m - (h * 60)
    print("%s h %s m" % (h, r))

def results_argsparse():    
    """Parse args and return results."""
    parser = argparse.ArgumentParser(description='Print report from work logs.')

    parser.add_argument('--categories', action='store_true', default=False,
                        dest='show_categories',
                        help='Show description of categories')

    parser.add_argument('--topics', action='store_true', default=False,
                        dest='show_topics',
                        help='Show description of topics')

    parser.add_argument('--by-category', action='store_true', default=False,
                        dest='by_category', help='Show work time logged by category')

    parser.add_argument('--by-topic', action='store_true', default=False,
                    dest='by_topic', help='Show work time logged by topic')

    parser.add_argument('--period', action='store', dest='period', default="month",
                        help='(day | week | month), report period')
    
    parser.add_argument('log', nargs='*', help='input files')
#                        default=log_file_for_this_month())

    results = parser.parse_args()
    
    if not results.log:
        print("Please supply input log files")
        return None

    return results

def main():
    op = results_argsparse()
    if op == None:
        exit()

    parse_log_files(op.log)

    if op.period == "day":
        days = days_today(DAYS)
    elif op.period == "week":
        days = days_this_week(DAYS)
    elif op.period == "month":
        days = DAYS
    else:
        print("Error: unsupported period (day | week | month): ", op.period)
        exit()
       
    if days == None or days == []: # is this correct Python?
        print("Error: you don't appear to have any logged days for that period")
        exit()
        
    if op.show_categories:
        show_categories(days)
    if op.show_topics:
        show_topics(days)
    if op.by_category:
        show_by_category(days)
    if op.by_topic:
        show_by_topic(days)

    show_stats(days)

if __name__ == "__main__":
    main()
