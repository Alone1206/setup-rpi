# Create a new setup script
cat > setup_fixed.sh << 'EOF'
#!/bin/bash
# Raspberry Pi 5 FRC Driver Station Setup Script

echo "Installing necessary dependencies..."
sudo apt-get update || { echo "Failed to update package lists"; exit 1; }

# Install cmake first, before trying to use it
echo "Installing build tools..."
sudo apt-get install -y build-essential git cmake || { echo "Failed to install build tools"; exit 1; }

echo "Installing I2C and GPIO libraries..."
# Replace wiringpi with pigpio (modern alternative)
sudo apt-get install -y libncurses5-dev i2c-tools libi2c-dev python3-smbus \
                      libgpiod2 libgpiod-dev libpigpio-dev pigpio \
                      libsdl2-dev libsdl2-ttf-dev || { echo "Failed to install libraries"; exit 1; }

# Enable I2C interface
echo "Enabling I2C interface..."
if ! grep -q "dtparam=i2c_arm=on" /boot/config.txt; then
    sudo sh -c 'echo "dtparam=i2c_arm=on" >> /boot/config.txt'
fi
sudo sh -c 'echo "i2c-dev" >> /etc/modules'

# Create project directory
echo "Creating project directory..."
mkdir -p ~/rpi-ds
cd ~/rpi-ds || { echo "Failed to create/enter project directory"; exit 1; }

# Clone LibDS repository
echo "Cloning LibDS repository..."
git clone https://github.com/FRC-Utilities/LibDS.git || { echo "Failed to clone LibDS"; exit 1; }

# Build LibDS
echo "Building LibDS..."
cd LibDS || { echo "Failed to enter LibDS directory"; exit 1; }
mkdir -p build && cd build || { echo "Failed to create/enter build directory"; exit 1; }
cmake .. || { echo "Failed to run cmake"; exit 1; }
make -j4 || { echo "Failed to build LibDS"; exit 1; }

# Creating project structure
echo "Creating project structure..."
cd ~/rpi-ds || { echo "Failed to return to project directory"; exit 1; }
mkdir -p src/include src/drivers

echo "Setup complete! Reboot your Raspberry Pi to activate I2C."
echo "After reboot, you can check I2C with: i2cdetect -y 1"
EOF

# Make it executable
chmod +x setup_fixed.sh

# Run it
./setup_fixed.sh