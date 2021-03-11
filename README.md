# pi3d_pictureframe_menu
Pi3d pictureframe with dummy menu. 

I continually come up with new ideas to add to this as well as find and fix bugs. Check back occasionally for the latest files. Sorry I dont know how to use git very well this probably isn't commented as well as it could be but that is something I also continue to work on.

This is essentially my first foray into anything linux. Having never done any kind of programming of any sort, this is my
beginners project. I set out to build a smart digital pictureframe to build as a gift for grandma. Pi3d software is perfect
for this as it comes with a python script just for this purpose, along with a config script that makes the pictureframe
highly customizable. All of the instructions for building the digital pictureframe came from https://thedigitalpictureframe.com.
The problem was that grandma, or anyone else that might receive this, is not likely to be technically proficient enough to
make alterations to the config files, or want to remember a bunch of CLI commands. So I decided to make something that anyone
can use. In this repository is an installation script for installing all necessary software for running a digital pictureframe
on a raspberry pi. It will work on all models of raspberry pi although it is not recommended on the raspberry pi 0.

On a fresh install of Raspberry Pi OS with desktop,
clone the repository by typing in the terminal from your home directory
git clone https://github.com/skydivr12/pic_frame
Run install script with 'bash pic_frame/install_master.sh'
There are 2 points of user interaction during the install process. Follow the instructions and once the installation is complete
the pictureframe can be operational.

Now everything can be managed through the CLI via a simple menu system.

Start the menu by typing 'menu' into the terminal
First thing you should do is go to User Accounts and Passwords and select setup_master. This will walk you through all personalization
settings of the system. After completeing this step the pictureframe will automatically start downloading from email and google drive.
Since it syncs from Google Drive to the Raspberry Pi, users can delete pictures from the frame simply by removing them from Google Drive.

Menu system allows user complete control over all Pi3D pictureframe config settings without having to know anything at all about
linux. Can turn the display on or off. Can switch between desktop and pictureframe mode. Perform system updates. Setup downloading
from Gmail and syncing with Google Drive. 
 
Includes scripts to download pictures from emails and sync with google drive. With systemd services to automate operation.
Can be used with multiple google accounts and will keep each respective account's content seperate.
If you can type "menu" you can setup and operate this Pi3d Pictureframe.

3/10/2021
 bug fixes in download_pics script
 bug fixes in User Accounts functions
