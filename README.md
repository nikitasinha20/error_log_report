Creates a report of error occurrence  from the log files given as input.

Prerequisites:

1. Ruby version 2.4.1p111 installed
2. Mysql server installed and running

Assumption:

1. Mysql has a user "root" with no password

Steps to execute:

1. gem install mysql2
2. gem install parallel
3. ruby ErrorReport.rb

Example execution and its output:

    NikitaS-MacMini:ErrorLogReport nikitas$ ruby ErrorReport.rb 
    Enter comma separated values of filename to be processed: input1.txt,input2.txt,input3.txt,input4,txt,input5.txt,input6.txt,input7.txt
    Enter the number of files to be processed simultaneously: 2

    The Error Analysis Report is as follows:

    NullPointerException  02:00:00 - 02:14:59  1
    IllegalArgumentsException  04:45:00 - 04:59:59  1
    IllegalArgumentsException  07:30:00 - 07:44:59  1
    IllegalArgumentsException  10:45:00 - 10:59:59  5
    NullPointerException  11:00:00 - 11:14:59  5
    IllegalArgumentsException  11:15:00 - 11:29:59  5
    IllegalArgumentsException  11:30:00 - 11:44:59  5
    IllegalArgumentsException  11:45:00 - 11:59:59  5
    IllegalArgumentsException  14:30:00 - 14:44:59  1
    NullPointerException  14:45:00 - 14:59:59  1
    NullPointerException  20:30:00 - 20:44:59  1
    NullPointerException  23:15:00 - 23:29:59  1
    NikitaS-MacMini:ErrorLogReport nikitas$ 

