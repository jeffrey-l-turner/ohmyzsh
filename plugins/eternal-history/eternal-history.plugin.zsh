# Eternal history with review aliases
#
# Functions
#
# add to history ~/.eternal_history via prompt

# Aliases & Functions
# (sorted alphabetically)

function eternalhist() {
    # option -d; parse UTC seconds timestamp into readable local time date
    if [ "$1" = "-d" ] || [ "$1" = "--date" ] ; then
        opt="date"
        shift
    fi
    local QU="cat ~/.eternal_history |"
    for GR in "$@"
    do
        QU="${QU} grep -i ${GR} | " 
    done
    if [ "$opt" = "date" ]; then
        # shellcheck disable=SC2154
        eval "${QU}" cut -f 5- 
    else
        eval "${QU} cut -d ' ' -f 5-"
    fi
}

# ---------------------------------------------------------
#  Set various zsh parameters based on whether the shell is 'interactive'
#  or not.  An interactive shell is one you type commands into, a
#  non-interactive one is the bash environment used in scripts.
if [[ ${+PS1} ]]; then
    if [[ -x /usr/bin/tput ]] && [[ "${TERM}" != "dumb" ]]; then
        if [[ "x$(tput kbs)" != "x" ]]; then # We can't do this with "dumb" terminal -- this if stmt does not work on Mac OS 
            stty erase "$(tput kbs)"
        elif [[ -x /usr/bin/wc ]]; then
            if [[ "$(tput kbs|wc -c )" -gt 0 ]]; then # We can't do this with "dumb" terminal
                stty erase "$(tput kbs)"
            fi
        fi
    fi
    case $TERM in
    xterm*)
        if [[ -e /etc/sysconfig/bash-prompt-xterm ]]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
        else
            PROMPT_COMMAND='echo -n "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
        fi
        ;;
    screen)
        if [[ -e /etc/sysconfig/bash-prompt-screen ]]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
        else
        PROMPT_COMMAND='echo -n "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\033\\"'
        fi
        ;;
    dumb)
        PROMPT_COMMAND="echo -n dumb terminal"
        ;;
    *)
        [[ -e /etc/sysconfig/bash-prompt-default ]] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default

        ;;
    esac

    # eternal history
    # --------------------
    # This snippet allows infinite recording of every command you've ever
    # entered on the machine, without using a large HISTFILESIZE variable,
    # and keeps track if you have multiple screens and ssh sessions into the
    # same machine. It is adapted from:
    # http://www.debian-administration.org/articles/543.
    #
    # The way it works is that after each command is executed and
    # before a prompt is displayed, a line with the last command (and
    # some metadata) is appended to ~/.eternal_history.
    #
    # This file is a tab-delimited, timestamped file, with the following
    # columns:
    #
    # 1) user
    # 2) hostname
    # 3) screen window (in case you are using GNU screen)
    # 4) date/time
    # 5) current working directory (to see where a command was executed)
    # 6) the last command you executed
    #
    # The only minor bug: if you include a literal newline or tab (e.g. with
    # awk -F"\t"), then that will be included verbatime. It is possible to
    # define a bash function which escapes the string before writing it; if you
    # have a fix for that which doesn't slow the command down, please submit
    # a patch or pull request.
    PROMPT_COMMAND="setPS1; ${PROMPT_COMMAND:+$PROMPT_COMMAND ; }"'echo -n $$\\t$USER\\t$HOSTNAME\\tscreen $WINDOW\\t`date +%D%t%T%t%Y%t%s`\\t$PWD" >> ~/.eternal_history'

    # Turn on checkwinsize
    #shopt -s checkwinsize

    #Prompt edited from default
    [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\\u \\w]\\$ "

    if [ "x$SHLVL" != "x1" ]; then # We're not a login shell
        for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
                # shellcheck disable=SC1091,SC1090
            . "$i"
        fi
    done
    fi
fi

# Append to history
# See: http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
# shopt -s histappend
