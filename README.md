# Xipetotec Project

Xipetotec is a collection of bash scripts that help with the administration of a server, this is a project for the Professor Melchor Adrian Leal Suarez @ Universidad Autónoma de Querétaro giving the OS Admin subject.

## Installation

Use the package manager [pip](https://pip.pypa.io/en/stable/) to install foobar.

```bash
pip3 install telebot
```

## Usage

```bash
##To install the programs you need to run the install.sh script,
##it needs some arguments to start the install, you must specify the following
## -p ==> Directory Path
## -t ==> Telegram Token
## -n ==> Servername
##So it should look something like this

 ./install.sh -p /opt/ -n newServerName -t "523301333:AAFoDVQcngPxRa"

##Once installed you can use the next application to know if a user exists
 userExists username

##To activate the Smart Vigilance Service, you can use systemctl 
 systemctl start VVI2

##To check the status of the service, try the next command
 systemctl status VVI2

##To stop the service try this
 systemctl stop VVI2

##If you need to restart, try the next command
 systemctl restart VVI2

##To uninstall program
 /opt/newServerName/uninstall.sh
```

## Contributing
Proyect made for the OS Admin subject given by Prof. Melchor Adrian Leal Suarez @ Universidad Autónoma de Querétaro Facultad de Informática
