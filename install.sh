#!/bin/bash

# Set up the script to exit on errors
set -e

#############################
### Software Installation ###
#############################

# Install Firefox if not already installed
if ! command -v "firefox" &> /dev/null; then
    echo "Firefox not found. Installing..."
    sudo apt update
    sudo apt install -y firefox
else
    echo "Firefox is already installed."
fi

# Install Simplenote
echo "Installing Simplenote..."
sudo apt update
sudo apt install -y simplenote

# Install Gnumeric
echo "Installing Gnumeric..."
sudo apt update
sudo apt install -y gnumeric

# Install QGIS
echo "Installing QGIS..."
sudo apt update
sudo apt install -y qgis

# Install XSane
echo "Installing XSane..."
sudo apt update
sudo apt install -y xsane

# Install Google Earth
echo "Installing Google Earth..."
wget https://dl.google.com/earth/client/earth_stable_current_amd64.deb
sudo dpkg -i earth_stable_current_amd64.deb
sudo apt install -f  # Fix any dependencies that might be missing

# Install VS Code
echo "Installing VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code

# Install VS Code Extensions
echo "Installing VS Code Extensions..."
if command -v code &> /dev/null; then
  extensions=(
    ms-toolsai.datawrangler
    cweijan.vscode-database-client2
    cweijan.dbclient-jdbc
    ms-azuretools.vscode-docker
    github.copilot
    ms-toolsai.jupyter
    ms-toolsai.vscode-jupyter-cell-tags
    ms-toolsai.jupyter-keymap
    ms-toolsai.jupyter-renderers
    ms-toolsai.vscode-jupyter-slideshow
    ms-python.vscode-pylance
    ms-python.python
    ms-python.debugpy
    KevinRose.vsc-python-indent
    mechatroner.rainbow-csv
    adpyke.vscode-sql-formatter
    emmanuelbeziat.vscode-great-icons
  )
  for ext in "${extensions[@]}"; do
    code --install-extension "$ext"
  done
else
  echo "VS Code is not installed or not in PATH. Skipping extensions."
fi

# Install Command Line Tools
echo "Installing command line tools..."
sudo apt update
sudo apt install -y curl git unzip zsh tree direnv

# Configure direnv
echo "Configuring direnv..."
if ! grep -q 'direnv hook zsh' ~/.zshrc; then
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
fi

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
RUNZSH=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install GitHub CLI
echo "Installing GitHub CLI..."
sudo apt remove -y gitsome || true
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh
echo "GitHub CLI version:"
gh --version

# Install GCloud CLI
echo "Installing GCloud CLI..."
sudo apt-get install apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor > /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install -y google-cloud-sdk google-cloud-sdk-app-engine-python
echo "GCloud version:"
gcloud --version

# Install pyenv and its dependencies
echo "Installing pyenv..."
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev python3-dev

# Install Python 3.12.6 and virtualenv
echo "Installing Python 3.12.6..."
pyenv install 3.12.6
pyenv global 3.12.6
git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
pyenv virtualenv 3.12.6 generic
pyenv global generic
pip install --upgrade pip
echo "Python version:"
python --version

# Install Docker
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker || true
sudo gpasswd -a "$USER" docker
echo "Testing Docker installation..."
docker --version
docker run hello-world

# Install PostgreSQL 16 and PostGIS 3.4.0
echo "Installing PostgreSQL 16 and PostGIS 3.4.0..."
sudo apt update
sudo apt install -y gnupg2 curl lsb-release ca-certificates
sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c | awk '{print $2}')-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/postgresql.asc
sudo apt update
sudo apt install -y postgresql-16 postgresql-client-16
sudo apt install -y postgis postgresql-16-postgis-3
sudo systemctl enable postgresql
sudo systemctl start postgresql
echo "PostgreSQL version:"
psql --version
echo "PostGIS version:"
psql -d postgres -c "SELECT PostGIS_Version();"

echo "Software installation completed!"

############################
### System Configuration ###
############################

# Backup and Symlink Functionality
backup() {
  target=$1
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.backup"
    echo "-----> Moved your old $target config file to $target.backup"
  fi
}

symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    ln -s "$file" "$link"
    echo "-----> Symlinking $link"
  fi
}

# Apply Symlinks
echo "Configuring dotfiles..."
for name in aliases gitconfig irbrc rspec zprofile zshrc; do
  target="$HOME/.$name"
  backup "$target"
  symlink "$PWD/$name" "$target"
done

# Install zsh plugins
echo "Configuring zsh..."
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGINS_DIR"
cd "$ZSH_PLUGINS_DIR"
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting
fi
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions
fi

# Symlink VS Code settings
echo "Configuring VS Code..."
CODE_PATH="$HOME/.config/Code/User"
mkdir -p "$CODE_PATH"
for name in settings.json keybindings.json; do
  target="$CODE_PATH/$name"
  backup "$target"
  symlink "$PWD/$name" "$target"
done

# Final Refresh
source ~/.zshrc
echo "Setup completed!"