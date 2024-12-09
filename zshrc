ZSH=$HOME/.oh-my-zsh

ZSH_THEME="robbyrussell"

# Load Oh-My-Zsh plugins
plugins=(git gitfast last-working-dir common-aliases zsh-syntax-highlighting history-substring-search ssh-agent direnv)

# Load Oh-My-Zsh
ZSH_DISABLE_COMPFIX=true
source "${ZSH}/oh-my-zsh.sh"
unalias rm # Avoid interactive `rm` from plugins/common-aliases

# Set the default browser
export BROWSER=firefox

# Load pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
type -a pyenv > /dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init - 2> /dev/null)" && RPROMPT+='[🐍 $(pyenv version-name)]'

# Encoding setup
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Editor settings
export BUNDLER_EDITOR=code
export EDITOR=code

# Python debugger
export PYTHONBREAKPOINT=ipdb.set_trace

# Load aliases
alias myip="curl ipinfo.io/ip"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
alias sd='shutdown -h now'
alias rb='reboot'
alias ap='connect_airpods'

# Define the connect to AirPods function
connect_airpods() {
    bluetoothctl connect CC:68:E0:25:E1:C5

    # Wait for the AirPods to connect
    sleep 2

    # Verify connection
    if bluetoothctl info CC:68:E0:25:E1:C5 | grep -q "Connected: yes"; then

        # Set the profile to HFP
        if pactl set-card-profile bluez_card.CC_68_E0_25_E1_C5 handsfree_head_unit; then
            echo "Profile set to HFP"

            # Check and set the correct source and sink
            source_port=$(pactl list sources short | grep bluez_source.CC_68_E0_25_E1_C5.handsfree_head_unit | awk '{print $2}')
            sink_port=$(pactl list sinks short | grep bluez_sink.CC_68_E0_25_E1_C5.handsfree_head_unit | awk '{print $2}')

            if [ -n "$source_port" ] && [ -n "$sink_port" ]; then
                # Set the AirPods as the default input/output devices
                if pactl set-default-sink "$sink_port" && \
                   pactl set-default-source "$source_port"; then
                    echo "AirPods set as default input/output devices"
                else
                    echo "Failed to set AirPods as default input/output devices"
                fi
            else
                echo "Failed to find the correct source or sink port"
            fi
        else
            echo "Failed to set profile to HFP"
        fi
    else
        echo "Failed to connect to AirPods"
    fi
}