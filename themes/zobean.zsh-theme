# Title:        Zobean's zsh theme!
# Author:       Zoey Llewellyn "Zobean" Hewll
# Last Edited:  2017-08-11
# Features:     running clock, including date and time
#               colorised exit status indicator
#               printed exit status if not 0/1
#               colorised git status indicator
#               full logical path, colored for convenience
#               ssh/scp path format user@hostname:path
#               polite command prompt, with customisable title
# Notes:        Enjoy your stay!
#               Let me know of any improvements!
#               (the actual code is pretty hacky)

# Title Customisation {{{
#_PROMPT_USER_TITLE="$(id --user --name)" # same as $USER
#_PROMPT_USER_TITLE="mistress"
_PROMPT_USER_TITLE="princess"
#_PROMPT_USER_TITLE="my queen"
#_PROMPT_USER_TITLE="your highness"
# }}}
# Body {{{
setopt PROMPT_SUBST

# Update the prompt per-second
TMOUT=1
TRAPALRM() {
	zle reset-prompt
}

# Git status in prompt
ZSH_THEME_GIT_PROMPT_PREFIX="%B%F{blue}git:(%F{red}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}*%F{blue})"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{blue})"

# Keep up to the last directory in path
# Functional counterpart to zsh's '%1/' prompt expansion
pwd_path() {
    #pwd | sed -E 's://+:/:g;s:^(.*/)([^/]*)/?$:\1:' # treats / as path
	pwd | sed -E 's://+:/:g;s:[^/]+/?$::;s:^/$::' # treats / as last directory
} 
# Keep only the last directory in path
# Functional equivalent to zsh's '%1/' prompt expansion
pwd_dir() {
    #pwd | sed -E 's://+:/:g;s:^(.*/)([^/]*)/?$:\2:' # treats / as path
	pwd | sed -E 's://+:/:g;s:^.*/([^/]+)/?:\1:' # treats / as last directory
} 

precmd_prompt() {
	#local ERRCOL="%(?:%F{green}:%F{red})"
    local EXIT_CODE=$?
    local ERRSTAT=''
	local ERRCOL
    case $EXIT_CODE in
        0)
            ERRCOL="%F{green}"
            ;;
        1)
            ERRCOL="%F{red}"
            ;;
        *)
            ERRCOL="%F{red}"
            ERRSTAT=" %Fexit: (${EXIT_CODE})%f"
            ;;
    esac    
	# There is an easier way to do this, using sed, but I can't be bothered. Zsh expansion is convenient-ish
	# Match all zsh-style formatting strings. Not great.
	local RAW_NG='%([BSUbfksu]|[FK]{*})' #non-greedy match - for when %F or %K is followed by {}
	local RAW_GR='%([FK])'               #greedy match - for the other case. no following {}
	
    local TIME_NOW="%D{%H:%M:%S}"
	local TIME_FIXED="${(%%):-"${TIME_NOW}"}" # expand it early, so it doesn't update
	local PROMPT_LAST="${ERRCOL}[%F%B${TIME_FIXED}%b${ERRCOL}]%f " # finish time of last command
	local PROMPT_NOW="%F%B[${TIME_FIXED}]%b%f " # start time of this command (current time)
	local PROMPT_GIT="$(git_prompt_info)"
	local PROMPT_DATE="%F%D{%Y-%m-%d}%f "

	local PROMPT_LEFT="${PROMPT_LAST}${PROMPT_NOW}${PROMPT_GIT}${ERRSTAT}"
	local PROMPT_RIGHT="${PROMPT_DATE}"
	local BARE_LEFT="${${(S)PROMPT_LEFT//$~RAW_NG}//$~RAW_GR}"
	local BARE_RIGHT="${${(S)PROMPT_RIGHT//$~RAW_NG}//$~RAW_GR}"
	
	# Calculate the padding required to right-pad the date
	local MIDDLE_WIDTH="$((${COLUMNS}-1-${#:-${(%):-$BARE_LEFT$BARE_RIGHT}}))" #must be one less, as rprompt sits one from the end of the screen
    local PROMPT_FILL="${(r:$MIDDLE_WIDTH:: :)}" # pad with spaces

	RPROMPT=''
	PROMPT="${PROMPT_LEFT}${PROMPT_FILL}${PROMPT_RIGHT}"
	PROMPT+=$'\n%F{green}%n%f@%F{yellow}%M%f:%F{blue}$(pwd_path)%B$(pwd_dir)%b%f'
	PROMPT+=$'\n%F{magenta}yes, %B'"${_PROMPT_USER_TITLE}"'%b%F{magenta}?%f : '
}
precmd_functions+=(precmd_prompt)

function err_status() {
}


# }}}
# Postamble {{{
# This is specifically to allow for cool vim folding.
# Note: 'modelines' should be at least the distance
# of the modeline from the top or bottom of the file
# Update: I have no idea how this following line works
set modeline modelines=5
# Modeline to enable marker-based folding, and ensure zsh syntax coloring
# vim:foldmethod=marker:filetype=zsh:
#  }}}
