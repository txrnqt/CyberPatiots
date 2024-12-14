#downlading
sudo apt update
sudo apt install clamav chkrootkit rkhunter

#updating virus database
sudo freshclam

#scan for viruses 
clamscan
clamscan -r

#run chkrootkit
chkrootkit -l


#run RKHunter
rkhunter --update
rkhunter --propupd
rkhunter -c --enable all --disable none

#remove antivirus 
sudo apt remove clamav chkrootkit rkhunter
sudo apt autoremove

sudo apt install ufw

sudo ufw enable