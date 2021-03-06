#!/usr/bin/env python3
import re
import sys
import time
import os

MONTH = "November.md"

def usage():
    print(
"""
Usage: log [show | start | new-day]
       log end <category> <topic> [<description>]  

Commands:

 show      show the log file
 new-day   start a new day
 start     start new session
 end       end a session

Example: 
 log start
 log end dev python Write script for adding log entry
           
""")
    
def main():
    if len(sys.argv) == 1:
        cmd = "show"            # for convenience 
    else:
        cmd = sys.argv[1]

    path = log_file()
    f = open(path, 'r')
    content = f.readlines()
    f.close()

    rm_trailing_newlines(content)

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

        else:
            end(content, sys.argv[2:len(sys.argv)])

    elif cmd == "new-day" or cmd == "new":
        new_day(content)

    else:
        print("Command not supported", cmd)
        usage()

def log_file():
    """Get name of log file to use."""
    dirname = os.path.dirname(os.path.realpath(__file__))
    return os.path.join(dirname, MONTH)

def rm_trailing_newlines(lines):
    """Remove trailing newlines from list."""
    while True:
        i = len(lines) - 1
        if lines[i] == '\n':
            lines.pop()
        else:
            break

def show(lines):
    for line in lines:
        print(line, end="")
    
def start(content):
    """Add start time to log."""
    content.append(now())
    write_file(content)

# args form: cat topic [desc ...]
def end(content, args):
    """Add end time to log."""
    cat = args[0]
    topic = args[1]
    
    entry = " " + now() + " " + cat + " " + topic + " -"

    for word in args[2:len(args)]:
        entry += " " + word

    entry += '  \n'             # Two spaces to satisfy markdown

    rm_trailing_newline_of_last_element(content)
    content.append(entry)
    write_file(content)
    
def new_day(content):
    """Add new day to log."""
    day = today()
    underscore = '-' * len(day) + '\n'

    content.append('\n')
    content.append(day)
    content.append('\n')

    content.append(underscore)
    content.append(now())
    write_file(content)
    show(content)

def now():
    """Return current time, form hh:mm"""
    return time.strftime("%H:%M")

def today():
    """Return day of week and date (dd/mm/yyyy)."""
    return time.strftime("%A %d/%m/%y")

def write_file(content):
    content.append('\n')
    out = "".join(content)

    path = log_file()
    f = open(path, 'w')
    f.write(out)
    f.close() 

def rm_trailing_newline_of_last_element(strings):
    i = len(strings) - 1
    strings[i] = strings[i].rstrip()

if __name__ == "__main__":
    main()

