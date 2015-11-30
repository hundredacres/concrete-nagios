#!/usr/bin/python
import os
import json
import getopt
import sys

def usage():
    help = "This check will process a json file and check for either a specific value (-p) or for \n\
a value below a warning or critical level (-w and -c) \n\
\n\
Parameters:\n\
    -f file to check. This is required. This should be a full path.\n\
    -v variable to check. This is required by the script.\n\
    -p pass value. This is optional but one of -p and -c are required\n\
    -w warning value. This optional.\n\
    -c critical value\n\
    -x extra variable to return in check text\n\
    -h this help"
    print(help)

try:
    opts, args = getopt.getopt(sys.argv[1:], 'f:w:c:v:p:h')
except getopt.GetoptError:
    usage()
    sys.exit(2)

file_path = None
warning = None
critical = None
pass_value = None
variable = None
extra_variable = None


for opt, arg in opts:
    if opt in ('-h'):
        usage()
        sys.exit(2)
    elif opt in ('-w'):
        warning = arg
    elif opt in ('-c'):
        critical = arg
    elif opt in ('-p'):
        pass_value = arg
    elif opt in ('-v'):
        variable = arg
    elif opt in ('-f'):
        file_path = arg
    elif opt in ('-x'):
        extra_variable = arg

if critical == None and pass_value == None:
    print("one of critical or pass value must be defined")
    usage()
    sys.exit(2)
elif critical != None and pass_value != None:
    print("only one of critical or pass value must be defined")
    usage()
    sys.exit(2)
elif variable == None:
    print("variable must be defined")
    usage()
    sys.exit(2)
elif file_path == None:
    print("file path must be defined")
    usage()
    sys.exit(2)
elif not os.path.exists(file_path):
    print("json file does not exist")
    sys.exit(2)
elif warning == None and critical != None:
    warning = critical

try:
    with open(file_path, "rb") as json_file:
        parsed_json = json.load(json_file)
except:
    print("problem parsing json")
    sys.exit(2)

if pass_value != None:
    if pass_value == parsed_json[variable]:
        if extra_variable == None:
            print("OK - " + variable + " is " + str(parsed_json[variable]) )
        else:
            print("OK - " + variable + " is " + str(parsed_json[variable]) + extra_variable + " is " + str(parsed_json[extra_variable]) )
        sys.exit(0)
    else:
        if extra_variable == None:
            print("CRITICAL - " + variable + " is " + str(parsed_json[variable]) )
        else:
            print("CRITICAL - " + variable + " is " + str(parsed_json[variable]) + extra_variable + " is " + str(parsed_json[extra_variable]) )
        sys.exit(2)
else:
    if float(parsed_json[variable]) > float(critical):
        if extra_variable == None:
            print("CRITICAL - " + variable + " is " + str(parsed_json[variable]) )
        else:
            print("CRITICAL - " + variable + " is " + str(parsed_json[variable]) + extra_variable + " is " + str(parsed_json[extra_variable]) )
        sys.exit(2)
    elif float(parsed_json[variable]) > float(warning):
        f extra_variable == None:
            print("WARNING - " + variable + " is " + str(parsed_json[variable]) )
        else:
            print("WARNING - " + variable + " is " + str(parsed_json[variable]) + extra_variable + " is " + str(parsed_json[extra_variable]) )
        sys.exit(1)
    else:
        f extra_variable == None:
            print("OK - " + variable + " is " + str(parsed_json[variable]) )
        else:
            print("OK - " + variable + " is " + str(parsed_json[variable]) + extra_variable + " is " + str(parsed_json[extra_variable]) )
        sys.exit(0)