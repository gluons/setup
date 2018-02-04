YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m'

cd $HOME

# Real current user while using sudo.
# See https://unix.stackexchange.com/a/304761/221509
CURRENT_USER=$(who | awk '{print $1}')

# My dotfiles
echo "${YELLOW}Installing my dotfiles...${NC}"
mkdir -p "$HOME/my-projects"
su - $CURRENT_USER -c "git clone https://github.com/gluons/dotfiles.git $HOME/my-projects/dotfiles"
echo "source ~/my-projects/dotfiles/.profile" >> $HOME/.zprofile
# Dot files on home
ln -sf "$HOME/my-projects/dotfiles/.editorconfig" "$HOME/.editorconfig"
ln -sf "$HOME/my-projects/dotfiles/.eslintrc.json" "$HOME/.eslintrc.json"
## Owner
sudo chown $CURRENT_USER: "$HOME/.zprofile"
sudo chown -h $CURRENT_USER: "$HOME/.editorconfig"
sudo chown -h $CURRENT_USER: "$HOME/.eslintrc.json"
## Permission
sudo chmod 664 "$HOME/.zprofile"
## Change repo remote url
dotfiles_url='git@github.com:gluons/dotfiles.git'
su - $CURRENT_USER -c "cd \"$HOME/my-projects/dotfiles\" && git remote set-url origin $dotfiles_url" # Perform as real current user
cd

# Oh My Zsh
echo "\n${YELLOW}Installing Oh My Zsh...${NC}"
sudo apt-get install zsh -y -qq --show-progress
su - $CURRENT_USER -c "git clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh"
su - $CURRENT_USER -c "cp $HOME/.zshrc $HOME/.zshrc.orig 2>/dev/null || :"
su - $CURRENT_USER -c "cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc"
chsh -s /bin/zsh $CURRENT_USER

# zsh-syntax-highlighting
echo "\n${YELLOW}Installing zsh-syntax-highlighting...${NC}"
su - $CURRENT_USER -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# zsh-autosuggestions
echo "\n${YELLOW}Installing zsh-autosuggestions...${NC}"
su - $CURRENT_USER -c "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# nvm
echo "\n${YELLOW}Installing nvm...${NC}"
su - $CURRENT_USER -c "$(curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh)"

# rbenv
echo "\n${YELLOW}Installing rbenv...${NC}"
sudo apt-get install gcc -y -qq
su - $CURRENT_USER -c "git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv"
su - $CURRENT_USER -c "cd $HOME/.rbenv && src/configure && make -C src || true"
cd
echo '' >> $HOME/.zshrc
echo '# rbenv' >> $HOME/.zshrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.zshrc
echo 'eval "$(rbenv init -)"' >> $HOME/.zshrc
## rbenv ruby-build
su - $CURRENT_USER -c "mkdir -p \"$($HOME/.rbenv/bin/rbenv root)\"/plugins"
su - $CURRENT_USER -c "git clone https://github.com/rbenv/ruby-build.git \"$($HOME/.rbenv/bin/rbenv root)\"/plugins/ruby-build"
PATH="$HOME/.rbenv/bin:$PATH" # Temporary set path for rbenv-doctor
eval "$($HOME/.rbenv/bin/rbenv init -)" # Load rbenv shims
echo "\n${YELLOW}Running rbenv-doctor...${NC}"
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash # Verify rbenv
sudo find $HOME/.rbenv -maxdepth 1 -type d -exec chown $CURRENT_USER: {} + # Change owner to real current user

# Fonts
if [ ! -d "$HOME/.local/share/fonts" ]; then
	mkdir -p $HOME/.local/share/fonts
fi
## Fira Mono
echo "\n${YELLOW}Installing Fira Mono font...${NC}"
for type in Bold Medium Regular; do
	wget -q --show-progress --progress=bar -O $HOME/.local/share/fonts/FiraMono-${type}.ttf \
	"https://github.com/mozilla/Fira/blob/master/otf/FiraMono-${type}.otf?raw=true";
done
## Fira Code
echo "\n${YELLOW}Installing Fira Code font...${NC}"
for type in Bold Light Medium Regular Retina; do
	wget -q --show-progress --progress=bar -O $HOME/.local/share/fonts/FiraCode-${type}.ttf \
	"https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true";
done
## Powerline fonts
echo "\n${YELLOW}Installing Powerline fonts...${NC}"
git clone https://github.com/powerline/fonts.git "powerline-fonts" --depth=1
cd powerline-fonts
./install.sh
cd .. && rm -rf powerline-fonts
fc-cache -f # Clean & rebuild font cache

# VS Code
echo "\n${YELLOW}Installing VS Code...${NC}"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get update && sudo apt-get install code -y -q --show-progress

# Ensure downloads directory exists
if [ ! -d "$HOME/Downloads" ]; then
	mkdir -p "$HOME/Downloads"
fi

# Discord
echo "\n${YELLOW}Installing Discord...${NC}"
curl -fL# "https://discordapp.com/api/download?platform=linux&format=deb" -o $HOME/Downloads/discord.deb
sudo dpkg -i $HOME/Downloads/discord.deb
rm $HOME/Downloads/discord.deb # Clean up

# Hyper
echo "\n${YELLOW}Installing Hyper...${NC}"
curl -fL# "https://releases.hyper.is/download/deb" -o $HOME/Downloads/hyper.deb
sudo dpkg -i $HOME/Downloads/hyper.deb
rm $HOME/Downloads/hyper.deb # Clean up

# Spotify
echo "\n${YELLOW}Installing Spotify...${NC}"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client -y -q --show-progress

echo "\n${GREEN}Done.${NC}"
