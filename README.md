# postgres-wal-sizer
It designed to manage postgres wal files with a simple interactive bash script.

Usage: 
It designed/tested to use on a <b>single postgres instance</b> via <b>postgres linux user</b>.

Attention: 
Please <b>do not use the script in production environment</b> and it is not suitable for postgres cluster as well.

Test info: 
Run/tested on a <b>RockLinux 5.14.0-284.18.1.el9_2.x86_64</b> VM and a <b>postgres 13.11</b> instance version.

Future plans:
* Show current WAL settings
* Check new settings before changing them
* Add new variables for WAL management
