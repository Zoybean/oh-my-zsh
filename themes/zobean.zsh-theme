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
# Misc {{{
# Allow zsh substitution in prompt
setopt PROMPT_SUBST

# Update the prompt per-second
TMOUT=1
TRAPALRM() {
    zle reset-prompt
}
# }}}
# Git status in prompt {{{
ZSH_THEME_GIT_PROMPT_PREFIX="%B%F{blue}git:(%F{red}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}*%F{blue})%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{blue})%f"
ZSH_THEME_GIT_PROMPT_AHEAD="%F{yellow}↑%f"
ZSH_THEME_GIT_PROMPT_BEHIND="%F{green}↓%f"
# }}}
# Path Formatting {{{
# Keep up to the last directory in path
# Functional counterpart to zsh's '%1/' prompt expansion
pwd_path() {
    pwd | sed -E 's://+:/:g;s:^(.*/)([^/]*)/?$:\1:' # treats / as path
	#pwd | sed -E 's://+:/:g;s:[^/]+/?$::;s:^/$::' # treats / as last directory
} 
# Keep only the last directory in path
# Functional equivalent to zsh's '%1/' prompt expansion
pwd_dir() {
    pwd | sed -E 's://+:/:g;s:^(.*/)([^/]*)/?$:\2:' # treats / as path
    #pwd | sed -E 's://+:/:g;s:^.*/([^/]+)/?:\1:' # treats / as last directory
} 
# }}}
# Prompt Function {{{
precmd_prompt() {
    #local ErrCol="%(?:%F{green}:%F{red})"
    local ExitCode=$?
    local Errstat=''
    local ErrCol
    case $ExitCode in
        0)
            ErrCol="%F{green}"
            ;;
        1)
            ErrCol="%F{red}"
            ;;
        *)
            ErrCol="%F{red}"
            Errstat=" %Fexit: (${ExitCode})%f"
            ;;
    esac    
    # There is an easier way to do this, using sed, but I can't be bothered. Zsh expansion is convenient-ish
    # Match all zsh-style formatting strings. Not great.
    local RawNg='%([BSUbfksu]|[FK]{*})' #non-greedy match - for when %F or %K is followed by {}
    local RawGr='%([FK])'               #greedy match - for the other case. no following {}
    
    local TimeNow="%D{%H:%M:%S}"
    local TimeFix="${(%%):-"${TimeNow}"}" # expand it early, so it doesn't update
    local PromptLast="${ErrCol}[%F%B${TimeFix}%b${ErrCol}]%f " # finish time of last command
    local PromptNow="%F%B[${TimeNow}]%b%f " # start time of this command (current time)
    local GitStat="$(git_prompt_info)"
    local GitBehind="$(git_prompt_behind)"
    local GitAhead="$(git_prompt_ahead)"
    local PromptGit="${GitStat}${GitAhead}${GitBehind}"
    local PromptDate="%F%D{%Y-%m-%d}%f "

    local PromptLeft="${PromptLast}${PromptNow}${PromptGit}${Errstat}"
    local PromptRight="${PromptDate}"
    local BareLeft="${${(S)PromptLeft//$~RawNg}//$~RawGr}"
    local BareRight="${${(S)PromptRight//$~RawNg}//$~RawGr}"
    
    local Offset=3 # currently, it will creep up if you use a number less than 3
    # Calculate the padding required to right-pad the date
    local PadWidth="$((${COLUMNS}-${Offset}-${#:-${(%):-$BareLeft$BareRight}}))"
    local PromptFill="${(r:$PadWidth:: :)}" # pad with spaces

    RPROMPT=''
    PROMPT="${PromptLeft}${PromptFill}${PromptRight}"
    PROMPT+=$'\n%F{green}%n%f@%F{yellow}%M%f:%F{blue}$(pwd_path)%B$(pwd_dir)%b%f'
    PROMPT+=$'\n%F{magenta}yes, %B'"${_PROMPT_USER_TITLE}"'%b%F{magenta}?%f : '
}
precmd_functions+=(precmd_prompt)
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
