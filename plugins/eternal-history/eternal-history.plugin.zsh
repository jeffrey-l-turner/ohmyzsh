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
        local stmt='system("bash -c date -r $1"); $1=""; printf $0'
        local CMD="awk { ${stmt}; $1=''; printf $0 }" 
      #'{ system("bash -c date -r $1 +%Y-%m-%d_%H:%M:%S") }' 
        shift
      else
        local CMD=cat
    fi
    local QU="cat ~/.eternal_history"
    for GR in "$@"
    do
        QU="${QU} | grep -i ${GR} " 
    done
    echo "${QU}" | ${CMD} 
    eval "${QU}" | ${CMD} 
}

function humanReadableDate() {
  date -r $1 +"%Y-%m-%d %H:%M:%S"
}

# searches history by "anding" set of parameters together via grep
function ht() {
    local QU="history "
    for GR in "$@"
    do
        QU="${QU} | grep -i ${GR} " 
    done
    eval "${QU}"
}

# incomplete functions for appending to eternal history
function _concatToEternalHist() {
  local last recent linenum
  last=$(grep -Fn "$(tail -1 ~/OneDrive/_eternal_hist | cut -f 5 | cut -d ' ' -f 4)" ~/OneDrive/_eternal_hist  | sed s/:.*$//)
  recent=$(wc -l ~/._eternal_history | sed 's/ \/.*//' | sed 's/^ *//')
  # shellcheck disable=SC2219
  let linenum="${recent} - ${last}"
  tail -n "${linenum}" ~/.eternal_history >> ~/OneDrive/_eternal_hist
}

function mergeEternalHist() {
  rm -f /tmp/_eternal_hist
  _concatToEternalHist 
  sort -n --key=8 ~/OneDrive/_eternal_hist  | LC_ALL=C uniq > /tmp/_eternal_hist
  chmod 600 /tmp/_eternal_hist
  cp -i /tmp/_eternal_hist ~/OneDrive/_eternal_hist  
  mv -i /tmp/_eternal_hist ~/.eternal_history 
  rm -f /tmp/_eternal_hist
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
