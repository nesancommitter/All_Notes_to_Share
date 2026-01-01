#!/bin/bash

# Ignore duplicates + commands starting with space from .bash_history
export HISTCONTROL=ignoreboth:erasedups

# Append to history (don't overwrite) in .bash_history
shopt -s histappend

# Update history after every command (multi-session sync) for .bash_history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Optional: Ignore common redundant commands from logging in .bash_history
export HISTIGNORE="ls:ll:pwd:exit:date:xyz"

## Define Certain colors to make echo for important details

export BOLD='\033[1m'
export NC='\033[0m'   # No Color (Reset)

# Text colors
export BLACK='\033[30m'     
export WHITE='\033[37m'
export RED='\033[31m'
export GREEN='\033[32m'
export YELLOW='\033[33m'
export BLUE='\033[34m'
export MAGENTA='\033[35m'
export CYAN='\033[36m'
export GRAY='\033[90m'

# Bright foreground colors
export BRIGHT_BLACK='\033[90m'     
export BRIGHT_WHITE='\033[97m'
export BRIGHT_RED='\033[91m'
export BRIGHT_GREEN='\033[92m'
export BRIGHT_YELLOW='\033[93m'
export BRIGHT_BLUE='\033[94m'
export BRIGHT_MAGENTA='\033[95m'
export BRIGHT_CYAN='\033[96m'
export BRIGHT_GRAY='\033[90m'      # same code, name alias

# Background colors 
export BG_BLACK='\033[40m'  # background color black
export BG_RED='\033[41m'
export BG_GREEN='\033[42m'
export BG_YELLOW='\033[43m'
export BG_BLUE='\033[44m'
export BG_MAGENTA='\033[45m'
export BG_CYAN='\033[46m'
export BG_GRAY='\033[100m'


echo -e "${BOLD}${BLUE}***************************************************${NC}"
echo -e "${BOLD}${BLUE}****     ${BOLD}${YELLOW} Welcome To Sivanesan's DE genie ${BOLD}${BLUE}     ****${NC}"
echo -e "${BOLD}${BLUE}***************************************************${NC}"
source /mypyvenv/bin/activate
echo "python virtual environment mypuvenv is activated"
echo "path for mypyvenv is /mypyvenv    "
echo "alias set for python3 command so that it always uses mypyvenv whenever invoked with python3"

# Check if mysqld process is already running
if pgrep -x "mysqld" > /dev/null; then
    echo -e "${GREEN}MySQL service is already active (mysqld process found)${NC}"
else
    echo -e "${YELLOW}   Starting MySQL server...${NC}"
    /usr/sbin/mysqld --user=mysql &
    echo -e "${GREEN}Started MySQL server with command: ${BOLD}${YELLOW}/usr/sbin/mysqld --user=mysql &${NC}"
    sleep 2  # Give it a moment to start
fi

# Check if apache2 processes are running
if pgrep -x "apache2" > /dev/null; then
    echo -e "${GREEN}Apache2 service is already running (processes found)${NC}"
else
    echo -e "${YELLOW}   Starting Apache2 service...${NC}"
    /etc/init.d/apache2 start
    echo -e "${GREEN}Apache2 service started with command: ${BOLD}${YELLOW}:/etc/init.d/apache2 start${NC}"
fi

# Check if sshd process is already running
if pgrep -x "sshd" > /dev/null; then
    echo -e "${GREEN} sshd daemon is already running (processes found)${NC}"
else
    echo -e "${YELLOW}   Starting sshd daemon...${NC}"
    /usr/sbin/sshd -D &
    echo -e "${GREEN}sshd daemon started with command: ${BOLD}${YELLOW}/usr/sbin/sshd -D & ${NC}"
    sleep 2  # Wait for startup
fi
echo -e "${YELLOW}    Happy working with DE Genine image    ${NC}"
echo
echo
echo -e "${BOLD}${BLUE}**************************************************${NC}"
echo -e "${BOLD}${BLUE}****     ${CYAN}Info:${BOLD}${YELLOW} nesan.committer@gmail.com ${BOLD}${BLUE}     ****${NC}"
echo -e "${BOLD}${BLUE}**************************************************${NC}"
echo
echo

## Global Variables and settings
export EC2_INST_ID='i-0ca210a013f899c31'
export S3_BUKT_ID='learn-glue-csv-etl-bucket'
export EC2_INST_PIP=''
export HISTTIMEFORMAT="[%F %T] " 
export GIT_AUTHOR_NAME="Sivanesan G"
export GIT_AUTHOR_EMAIL="nesan.committer@gmail.com"


## FUNCTIONS ONLY - NO EXECUTION
awinststart() {
    local state=$(aws ec2 describe-instances --instance-ids "$EC2_INST_ID" --query 'Reservations[*].Instances[*].State.Name' --output text 2>/dev/null)
    
    if [[ "$state" == "running" ]]; then
        echo -e "${GREEN}Instance $EC2_INST_ID is already running${NC}"
    else
        echo -e "${YELLOW}Starting instance $EC2_INST_ID...${NC}"
        aws ec2 start-instances --instance-ids "$EC2_INST_ID" --output table
        echo -e "${CYAN}Waiting for instance to be running...${NC}"
        aws ec2 wait instance-running --instance-ids "$EC2_INST_ID"
    fi
	
    echo -e "${YELLOW}Fetching PIP of Instance $EC2_INST_ID${NC}"
    EC2_INST_PIP=$(aws ec2 describe-instances --instance-ids "$EC2_INST_ID" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
    echo -e "${BOLD}${YELLOW}Public IP: $EC2_INST_PIP${NC}"
}

awinstgetpip() {
    local state=$(aws ec2 describe-instances --instance-ids "$EC2_INST_ID" --query 'Reservations[*].Instances[*].State.Name' --output text 2>/dev/null)
    
    if [[ "$state" == "running" ]]; then
        EC2_INST_PIP=$(aws ec2 describe-instances --instance-ids "$EC2_INST_ID" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
        echo -e "${GREEN}Instance $EC2_INST_ID :: Public IP: ${BOLD}${YELLOW}$EC2_INST_PIP${NC}"
    else
        EC2_INST_PIP=""
        echo -e "${BOLD}${RED}Instance $EC2_INST_ID is NOT running (state: $state). EC2_INST_PIP set to empty.${NC}"
    fi
}

awinstssh() {
    local state=$(aws ec2 describe-instances --instance-ids "$EC2_INST_ID" --query 'Reservations[*].Instances[*].State.Name' --output text 2>/dev/null)
    
    if [[ "$state" == "running" ]]; then
        awinstgetpip
        if [[ -n "$EC2_INST_PIP" ]]; then
            ssh -i "/siva-ubuntu-dev-key.pem" ubuntu@"$EC2_INST_PIP"
        else
            echo -e "${RED}No public IP found for running instance $EC2_INST_ID : $EC2_INST_PIP${NC}"
        fi
    else
        echo -e "${RED}ERROR: Instance $EC2_INST_ID is NOT running (state: $state)${NC}"
        echo -e "${BOLD}${BLUE}Use command ${YELLOW}awinststart${BOLD}${BLUE} before you can ssh${NC}"
        return 1
    fi
}

## ALIASES
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias python='source /mypyvenv/bin/activate && python3'
alias rmysql='mysql -u root -p'
alias awinststop='aws ec2 stop-instances --instance-ids "$EC2_INST_ID" --output table'
alias lsserv='service --status-all'
alias vpya='source /mypyvenv/bin/activate'
alias vpyd='deactivate'
alias clpdgcache='rm -rf /var/lib/apt/lists/*'
alias clpipcache='pip cache purge && rm -rf ~/.cache/pip/*'
alias cltmpcache='rm -rf /tmp/* /var/tmp/*'
alias claptcache='apt-get clean'

## Trigger awinstgetpip just in case the instance was running already but IP is not fetched
##awinstgetpip     -- not required because before ssh we fetch the Public IP if its missing

## Run certain commands to so the env is all set to use
## Check if there is active tmux session newsess2 if not active then create the session and detach from that if there is session already do nothing
tmux has-session -t newsess2 2>/dev/null || tmux new-session -d -s newsess2
## Start the SSH agent Do this only if the agent is not active already
# SSH Agent: Start only if not already running (PS check)
if ! ps -ef | grep -q '[s]sh-agent'; then
    eval "$(ssh-agent -s)"      ## Start the ssh agent
    echo "SSH agent started"
else
    echo "SSH agent already running"
fi

## Function to delete last n commands and clean .bash_history file 
truncate_n_history() {
    # Check for no argument
    if [ $# -eq 0 ]; then
        echo "Usage: truncate_history <clear_after_line_number>"
        echo "Example: truncate_history 212     -- to delete all commands from line 212 till end" 
        return 1
    fi
    
    local max_lines=$1
    
    # Validate numeric argument
    if ! [[ "$max_lines" =~ ^[0-9]+$ ]]; then
        echo "Error: '$max_lines' is not a valid number"
        return 1
    fi
        
    # Confirmation
    read -p "Proceed? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return 1
    fi
    
    # Execute truncation
    sed -i "${max_lines},\$d" ~/.bash_history
    echo "Done! Kept first $((max_lines-1)) lines"
    
    # Reload history in current session
    history -r ~/.bash_history
}

## Function to delete and clean .bash_history file 
## of all commands starting with word passed as argument to Function
## Usage histdelstwith history    --- Deletes all commands in .bash_history that start with history
histdelstwith() {
    local word="$1"
    if [[ -z "$word" ]]; then
        echo -e "${RED}Usage: histdelstwith <word>${NC}"
        echo -e "Example: histdelstwith history"
        return 1
    fi
    
    echo -e "${YELLOW}Deleting all history commands starting with '$word'${NC}"
    
    # Collect ALL line numbers FIRST (before any deletion)
    local lines_to_delete=($(history | grep "^ *[0-9]\+  $word" | awk '{print $1}' | tac))
    
    # Delete in reverse order (safest)
    for num in "${lines_to_delete[@]}"; do
        history -d "$num"
        echo -e "${GREEN}Deleted history #$num${NC}"
    done
    
    # Save ONCE at the end
    history -w
    
    echo -e "${BOLD}${GREEN}Done! All '$word' commands removed from history.${NC}"
}


## Function to commit and push any git repo from local and to github 
cnpush() {

    # Parse -m parameter for commit message
    CUSTOM_MSG=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m)
                CUSTOM_MSG="$2"
                shift 2
                ;;
            *)
                echo -e "${BOLD}${RED}Unknown option: $1${NC}"
                echo -e "${BOLD}${YELLOW}Usage: cnpush [-m 'your message']${NC}"
                return 1
                ;;
        esac
    done

    # Check if pwd has Git repository .git folder
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${BOLD}${RED}ERROR: Not a Git repository!${NC}"
        return 1
    fi

    # Add all files (handle permission errors)
    if ! git add .; then
        echo -e "${BOLD}${RED}ERROR: git add failed (check file permissions/locks)${NC}"
        echo -e "${BOLD}${YELLOW}Close Excel/Office apps or add '~$*' to .gitignore${NC}"
        return 1
    fi
    
    # Check for changes in the modules
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${BOLD}${YELLOW}Changes detected - proceeding...${NC}"
    else
        echo -e "${BOLD}${YELLOW}No changes to commit!${NC}"
        return 0
    fi
    
    # Generate timestamp
    dtvar="dt_$(date +%Y_%m_%d)"
    repo_name=$(basename "$PWD")
    time_hm=$(date +%H_%m)
	
    # Build commit message
    BASE_MSG="Commit on ${dtvar}_${time_hm}"
    if [[ -n "$CUSTOM_MSG" ]]; then
        commit_msg="${BASE_MSG} - ${CUSTOM_MSG}"
    else
        commit_msg="$BASE_MSG"
    fi
    
    # Commit
    if git commit -m "$commit_msg"; then
        echo -e "Commit Successful: ${dtvar}_${time_hm}${NC}"
    else
        echo -e "${BOLD}${RED}ERROR: Commit failed${NC}"
        return 1
    fi
	
	# Fetch the remote name used for this git repo 
	REMOTE_NAME=$(git remote | head -1)  # First remote name
	if [[ -z "$REMOTE_NAME" ]]; then
	    echo -e "${BOLD}${RED}ERROR: No remotes found! (run: git remote -v)${NC}"
    	return 1
	fi
    
    # Push (with remote check)
    local remote_url=$(git remote get-url "$REMOTE_NAME" 2>/dev/null || echo "")
    if [[ -z "$remote_url" ]]; then
        echo -e "${BOLD}${RED}ERROR: Cannot get Remote URL for '$REMOTE_NAME'${NC}"
        return 1
    fi
    
    if git push -u "$repo_name" main; then
        echo -e "${BOLD}${GREEN}Pushed: ${dtvar}_${time_hm} → $repo_name${NC}"
        echo -e "${BOLD}${YELLOW}Remote: $remote_url${NC}"
    else
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Push failed (check internet/permissions)${NC}"
        return 1
    fi
}

genie() {
	echo -e "${BOLD}${BLUE}***********************************************${NC}"
    echo -e "${BOLD}${BLUE}****     ${BOLD}${YELLOW}  This is Sivanesan's DE genie ${BOLD}${BLUE}     ****${NC}"
    echo -e "${BOLD}${BLUE}*************************************************${NC}"
	echo
	echo -e "${BOLD}${BLUE}*************************************************${NC}"
	echo -e "${BOLD}${BLUE}****        ${RED}Container Env details            ${BLUE}****${NC}"
	echo -e "${BOLD}${BLUE}*************************************************${NC}"	
	echo -e "${BOLD}${GREEN}   msql : ${YELLOW}MySQL server pre-installed ${NC}"
	echo -e "${BOLD}${GREEN}       Port forwarding : ${BOLD}${YELLOW}-p 3306:3306${NC}"
	echo -e "${BOLD}${GREEN}       Users           : root:${BOLD}${YELLOW}root${NC}"
	echo -e "${BOLD}${GREEN}       Users           : phpmyadmin:${BOLD}${YELLOW}letmego${NC}"
	echo
	echo -e "${BOLD}${GREEN}   apache2 : ${YELLOW}apache2 web server is pre-installed  ${NC}"
	echo -e "${BOLD}${GREEN}       Port forwarding : ${BOLD}${YELLOW}-p 8080:80${NC}"	
	echo -e "${BOLD}${GREEN}       source location : ${BOLD}${YELLOW}/var/www/html/index.html  ${NC}"
	echo -e "${BOLD}${GREEN}       end point       : ${BOLD}${YELLOW}http://localhost:8080/ ${NC}"
	echo
	echo -e "${BOLD}${GREEN}   phpmyadmin : ${YELLOW}Mysql IDE in browser pre-installed  ${NC}"
	echo -e "${BOLD}${GREEN}       source location : ${BOLD}${YELLOW}/var/www/phpmyadmin  ${NC}"
	echo -e "${BOLD}${GREEN}       Config file     : ${BOLD}${YELLOW}/etc/apache2/sites-available/phpmyadmin.conf  ${NC}"
	echo -e "${BOLD}${GREEN}       end point       : ${BOLD}${YELLOW}http://localhost:8080/phpmyadmin ${NC}"
	echo -e "${BOLD}${GREEN}       Users           : phpmyadmin$:${BOLD}${YELLOW}letmego${NC}"	
	echo
	echo -e "${BOLD}${GREEN}   sshd : ${YELLOW}SSH demon is per-installed ${NC}"
	echo -e "${BOLD}${GREEN}       Port forwarding : ${BOLD}${YELLOW}-p 2222:22${NC}"
	echo -e "${BOLD}${GREEN}       source location : ${BOLD}${YELLOW}/var/run/sshd ${NC}"	
	echo -e "${BOLD}${GREEN}       Config file     : ${BOLD}${YELLOW}/etc/ssh/sshd_config ${NC}"	
	echo -e "${BOLD}${GREEN}       end point       : ${BOLD}${YELLOW}ssh ubuntussh@localhost -p 2222${NC}"
	echo -e "${BOLD}${GREEN}       Users           : ubuntussh:${BOLD}${YELLOW}ubuntussh123${NC}"
	echo
	echo -e "${BOLD}${BLUE}*************************************************${NC}"	
	echo
	echo -e "${BOLD}${BLUE}*************************************************${NC}"
	echo -e "${BOLD}${BLUE}****        ${RED}CLI tools pre-installed          ${BLUE}****${NC}"
	echo -e "${BOLD}${BLUE}*************************************************${NC}"		
	echo -e "${BOLD}${GREEN}   aws        : ${YELLOW}AWS CLI is pre-installed  ${NC}"
	echo -e "${BOLD}${GREEN}   az         : ${YELLOW}Azure CLI is pre-installed  ${NC}"
	echo -e "${BOLD}${GREEN}   snow       : ${YELLOW}Snowflake CLI is pre-installed  ${NC}"
	echo -e "${BOLD}${GREEN}   databricks : ${YELLOW}databricks CLI is pre-installed  ${NC}"
	echo -e "${BOLD}${BLUE}*************************************************${NC}"	
	echo
	echo -e "${BOLD}${BLUE}*************************************************${NC}"
	echo -e "${BOLD}${BLUE}****     ${RED}Python libraries pre-installed      ${BLUE}****${NC}"
	echo -e "${BOLD}${BLUE}*************************************************${NC}"		
	echo -e "${BOLD}${GREEN}   aws        : ${YELLOW}boto3  ${NC}"
	echo -e "${BOLD}${GREEN}   az         : ${YELLOW}azure-core  ${NC}"
	echo -e "${BOLD}${GREEN}   snowflake  : ${YELLOW}snowflake-connector-python  ${NC}"
	echo -e "${BOLD}${GREEN}   databricks : ${YELLOW}databricks-sdk  ${NC}"
	echo -e "${BOLD}${BLUE}*************************************************${NC}"	
	echo
	echo -e "${BOLD}${BLUE}**************************************************${NC}"
	echo -e "${BOLD}${BLUE}****  ${RED}Internal commands for use in Container  ${BLUE}****${NC}"
	echo -e "${BOLD}${BLUE}**************************************************${NC}"	
    echo -e "${BOLD}${GREEN}   genie         : ${YELLOW}Help on the DE Genie environment ${NC}" 
	echo -e "${BOLD}${GREEN}   rmysql        : ${YELLOW}connect to local mysql server with root  ${NC}"
	echo -e "${BOLD}${GREEN}   lsserv        : ${YELLOW}list all the services       ${NC}"
	echo -e "${BOLD}${GREEN}   histdelstwith : ${YELLOW}keep bash_history clean remove unwanted commands ${NC}"
	echo -e "${BOLD}${GREEN}   truncate_n_history : ${YELLOW}clean bash_history remove Last n commands${NC}"
    echo -e "${BOLD}${GREEN}   setgit        : ${YELLOW}Setup the current folder into git repo and set github repo for the same ${NC}" 	
    echo -e "${BOLD}${GREEN}   cnpush        : ${YELLOW}Commit changes of the current folder and push to github ${NC}" 
	echo -e "${BOLD}${BLUE}*************************************************${NC}"
	echo 
	echo -e "${BOLD}${BLUE}*************************************************${NC}"
	echo -e "${BOLD}${BLUE}****   ${RED}Useful python commands in Container   ${BLUE}****${NC}"
	echo -e "${BOLD}${BLUE}*************************************************${NC}"	
	echo -e "${BOLD}${GREEN}   vpya          : ${YELLOW}activate and enter python venv /mypyvenv ${NC}"
	echo -e "${BOLD}${GREEN}   vpyd          : ${YELLOW}exit python venv /mypyvenv      ${NC}"
	echo -e "${BOLD}${GREEN}   colorpallet   : ${YELLOW}Display echo color pallet ${NC}"
	echo -e "${BOLD}${GREEN}   clpdgcache    : ${YELLOW}Clear Cached package index files ${NC}"
	echo -e "${BOLD}${GREEN}   clpipcache    : ${YELLOW}Clear pip Cached files ${NC}"	
	echo -e "${BOLD}${GREEN}   cltmpcache    : ${YELLOW}Clear tmp folders ${NC}"	
	echo -e "${BOLD}${GREEN}   claptcache    : ${YELLOW}Clear apt-get package folders${NC}"





	echo -e "${BOLD}${BLUE}*************************************************${NC}"	
    echo 
	echo -e "${BOLD}${BLUE}*************************************************${NC}"
	echo -e "${BOLD}${BLUE}****         ${RED}AWS commands for use            ${BLUE}****${NC}"
	echo -e "${BOLD}${BLUE}*************************************************${NC}"
	echo -e "${BOLD}${GREEN}   '\$EC2_INST_ID' : ${YELLOW}Default AWS EC2 instacne       ${NC}"
	echo -e "${BOLD}${GREEN}   awinststart    : ${YELLOW}command to start default EC2 instance      ${NC}"
	echo -e "${BOLD}${GREEN}   awinstgetpip   : ${YELLOW}Get the public IP of default EC2 instance ${NC}"
	echo -e "${BOLD}${GREEN}   awinstssh      : ${YELLOW}Connect to default EC2 instance              ${NC}"
	echo -e "${BOLD}${GREEN}   awinststop     : ${YELLOW}Stop the default EC2 instance               ${NC}"
	echo -e "${BOLD}${BLUE}*************************************************${NC}"
}

colorpallet() {
	echo -e "COLOR    BOLD COLOR  BRIGHT COLOR  BACKGROUND COLOR${NC}"
	echo -e "${BLACK}******     ${BOLD}${BLACK}*******     ${BRIGHT_BLACK}*******      ${BG_BLACK}******${NC}"
	echo -e "${WHITE}******     ${BOLD}${WHITE}*******     ${BRIGHT_WHITE}*******      ${BG_WHITE}******${NC}"
	echo -e "${RED}******     ${BOLD}${RED}*******     ${BRIGHT_RED}*******      ${BG_RED}******${NC}"
	echo -e "${GREEN}******     ${BOLD}${GREEN}*******     ${BRIGHT_GREEN}*******      ${BG_GREEN}******${NC}"
	echo -e "${YELLOW}******     ${BOLD}${YELLOW}*******     ${BRIGHT_YELLOW}*******      ${BG_YELLOW}******${NC}"
	echo -e "${BLUE}******     ${BOLD}${BLUE}*******     ${BRIGHT_BLUE}*******      ${BG_BLUE}******${NC}"
	echo -e "${MAGENTA}******     ${BOLD}${MAGENTA}*******     ${BRIGHT_MAGENTA}*******      ${BG_MAGENTA}******${NC}"
	echo -e "${CYAN}******     ${BOLD}${CYAN}*******     ${BRIGHT_CYAN}*******      ${BG_CYAN}******${NC}"
	echo -e "${GRAY}******     ${BOLD}${GRAY}*******     ${BRIGHT_GRAY}*******      ${BG_GRAY}******${NC}"
}

