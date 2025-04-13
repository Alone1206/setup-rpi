#!/bin/bash
# Raspberry Pi 5 FRC Driver Station Setup Script

echo "Installing necessary dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential git cmake libncurses5-dev \
                      i2c-tools libi2c-dev python3-smbus \
                      libgpiod2 libgpiod-dev \
                      libsdl2-dev libsdl2-ttf-dev \
                      wiringpi

# Enable I2C interface
echo "Enabling I2C interface..."
if ! grep -q "dtparam=i2c_arm=on" /boot/config.txt; then
    sudo sh -c 'echo "dtparam=i2c_arm=on" >> /boot/config.txt'
fi
sudo sh -c 'echo "i2c-dev" >> /etc/modules'

# Create project directory
echo "Creating project directory..."
mkdir -p ~/rpi-ds
cd ~/rpi-ds

# Clone LibDS repository
echo "Cloning LibDS repository..."
git clone https://github.com/FRC-Utilities/LibDS.git

# Build LibDS
echo "Building LibDS..."
cd LibDS
mkdir build && cd build
cmake ..
make -j4

# Creating project structure
echo "Creating project structure..."
cd ~/rpi-ds
mkdir -p src/include src/drivers

echo "Setup complete! Reboot your Raspberry Pi to activate I2C."
echo "After reboot, you can check I2C with: i2cdetect -y 1"
