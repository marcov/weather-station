# Get radlib and wview tar.gz's
....

# Install some stuff

sudo apt-get install -t testing opencv
sudo apt-get install -t testing libopencv-stitching-dev
sudo apt-get install -t testing libopencv-stitching-dev python3 python3-pip

sudo apt-get install build-essential
sudo apt-get install -t testing libgd-dev
sudo apt-get install libsqlite3
sudo apt-get install libsqlite3-0
sudo apt-get install libsqlite3-dev

sudo apt-get install libcurl-dev
sudo apt-get install libcurl4-gnutls-dev

sudo apt-get install libudev-dev
sudo apt-get install libusb-dev
sudo apt-get install libusb-1.0-0
sudo apt-get install libusb-1.0-0-dev
sudo apt-get install libssl1.1
sudo apt-get install libssl-dev


# Compile radlib

cd radlib-xxx/
mkdir build
cd build
../configure --enable-sqlite --prefix=/usr/local
make
sudo make install


# Compile wview

cd wview-xxx/
mkdir build
cd build
../configure --prefix=/usr/local
make
sudo make install


# Generate the inital wview-conf.sdb configuration file

sudo apt-get install sqlite3

# Generate the initial database file

sqlite3 wview-conf.sdb

> .read /usr/local/etc/wview/wview-conf.sql
> .exit

cp wview-conf.sdb /usr/local/var/wview/wview-conf.sdb


# Install nginx

sudo apt-get install nginx-light

---> Use sites-enabled / available from this git repo!


# Other
sudo pip3 install pycurl

