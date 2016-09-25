#!/usr/bin/env python3
import re
import sys
import time

FILE = "September.md"

def usage():
    print(
"""
Usage: log (show | start | new-day)
       log end <category> <topic> [<description>]  

Commands:

 show      show the log file
 new-day   start a new day
 start     start new session
 end       end a session

Example: 
 
 log end dev python wrote script for adding log entry
           

""")
    exit()
    
def main():
    if len(sys.argv) == 1:
        cmd = "show"            # for convenience 
    else:
        cmd = sys.argv[1]

    f = open(FILE, 'r')
    content = f.readlines()
    rm_trailing_newlines(content)

    f.close()

    if cmd == "show":
        show(content)

    elif cmd == "-h" or cmd == "--help":
        usage()
    
    elif cmd == "start":
        start(content)

    elif cmd == "end":
        if len(sys.argv) < 4:
            print("not enough arguments to %s end" % sys.argv[0])
            usage()

        end(content, sys.argv[2:len(sys.argv)])

    elif cmd == "new-day" or cmd == "new":
        new_day(content)

    else:
        print("Command not supported", cmd)
        usage()

def rm_trailing_newlines(lines):
    """remove trailing newlines from list."""
    while True:
        i = len(lines) - 1
        if lines[i] == '\n':
            lines.pop()
        else:
            break

def show(lines):
    for l in lines:
        print(l, end="")
    
def start(content):
    """Add start time to log"""
    content.append(now())

    write_file(content)

# args form: cat topic [desc ...]
def end(content, args):
    """Add end time to log"""
    cat = args[0]
    topic = args[1]
    
    suffix = " " + now() + " " + cat + " " + topic + " - "

    for word in args[2:len(args)]:
        suffix += " " + word

    suffix += '\n'

    rm_trailing_newline_of_last_element(content)
    content.append(suffix)

    write_file(content)
    
def new_day(content):
    """Add new day to log"""
    day = today()
    underscore = '-' * len(day) + '\n'

    content.append('\n')
    content.append(day)
    content.append('\n')

    content.append(underscore)
    content.append(now())
    write_file(content)

def now():
    """Return current time, form hh:mm"""
    return time.strftime("%H:%M")

def today():
    """Return day of week and date (dd/mm/yyyy)."""
    return time.strftime("%A %d/%m/%Y")

def write_file(content):
    content.append('\n')
    out = "".join(content)

    f = open(FILE, 'w')
    f.write(out)
    f.close() 

def rm_trailing_newline_of_last_element(strings):
    i = len(strings) - 1
    strings[i] = strings[i].rstrip()

if __name__ == "__main__":
    main()

