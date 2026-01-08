#!/bin/bash

# Ignore duplicates + commands starting with space from .bash_history
export HISTCONTROL=ignoreboth:erasedups

# Append to history (don't overwrite) in .bash_history
shopt -s histappend

# Update history after every command (multi-session sync) for .bash_history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Optional: Ignore common redundant commands from logging in .bash_history
export HISTIGNORE="ls:ll:pwd:exit:date:xyz"

# Set the environment variables for odbc connectivity
export ODBCSYSINI=/etc
export ODBCINI=/etc/odbc.ini
export ODBCInstLib=/usr/lib/x86_64-linux-gnu/libodbcinst.so.2

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

## Invoke ssh-agent if its not active already
start_ssh_agent

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
alias claptcache='sudo apt-get clean'

## Trigger awinstgetpip just in case the instance was running already but IP is not fetched
##awinstgetpip     -- not required because before ssh we fetch the Public IP if its missing

### Run certain commands to so the env is all set to use
## Check if there is active tmux session newsess2 if not active then create the session and detach from that if there is session already do nothing
tmux has-session -t newsess2 2>/dev/null || tmux new-session -d -s newsess2

## Start the SSH agent Do this only if the agent is not active already

### Function definitions start
## Function to start ssh-agent if there is no active ssh-agent
start_ssh_agent () {
# SSH Agent: Start only if not already running (PS check)
if ! ps -ef | grep -q '[s]sh-agent'; then
    eval "$(ssh-agent -s)"      ## Start the ssh agent
    echo "SSH agent started"
else
    echo "SSH agent already running"
fi
}

## Function to trim image/container remove unwanted files
trim_img () {

# 1. Remove unused dependencies (autoremove)
	echo -e "${BOLD}${YELLOW} Remove unused dependencies - apt autoremove${NC}"
	echo ""
	sudo apt autoremove -y

# 2. Remove unused dependencies + config files (purge)
	echo -e "${BOLD}${YELLOW} Remove unused dependencies + config files - apt autoremove --purge${NC}"
	echo ""
	sudo apt autoremove --purge -y

# 3. Clean package cache
	echo -e "${BOLD}${YELLOW} Clean package cache - apt autoclean${NC}"
	echo ""
	sudo apt autoclean

# 4. Clear all downloaded package files
	echo -e "${BOLD}${YELLOW} Clear all downloaded package files - apt clean${NC}"
	echo ""
	sudo apt clean
	clpdgcache
	claptcache

# 5. Clear pip Cached files
	echo -e "${BOLD}${YELLOW} Clear pip Cached files${NC}"
	echo ""
    clpipcache
	
# 6. Clear tmp folders
	echo -e "${BOLD}${YELLOW} Clear tmp folders${NC}"
	echo ""
	cltmpcache
}


## Function to Load the private and public key for github web
load_sshkey_github() {
## Load the private and public key for github web
# Load SSH key only if connection fails
if ssh -T git@github.com 2>&1 | grep -q "Hi nesancommitter! You've successfully"; then
    echo -e "${BOLD}${GREEN} SSH already working (github key loaded)${NC}"
else
    echo -e "${BOLD}${WHITE}Pass is : ${BOLD}${YELLOW}passgithubweb${NC}"
	# Add private key
    ssh-add ~/.ssh/githubweb

    # Verify after loading keys
    if ssh -T git@github.com 2>&1 | grep -q "Hi nesancommitter! You've successfully"; then
        echo -e "${BOLD}${GREEN} SSH key loaded successfully!${NC}"
    else
        echo -e "${BOLD}${RED}ERROR : ${BOLD}${YELLOW}SSH still failing after key load${NC}"
        return 1
    fi
fi
}


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
## Usage hisdany history    --- Deletes all commands in .bash_history that start with history
hisd() {
    local in_word_list="$1"
    if [[ -z "$in_word_list" ]]; then
        echo -e "${RED}Usage: hisd 'word1,word2,word3'${NC}"
        echo -e "Example: hisd 'cd,rm,ping'${NC}"
        return 1
    fi
    
    # Split comma-separated in_word_list into array
    IFS=',' read -ra words <<< "$in_word_list"
    
    echo -e "${YELLOW}Deleting history for: ${words[*]}${NC}"
    
    # Loop through each word
    for word in "${words[@]}"; do
        word=$(echo "$word" | xargs)  # trim whitespace
        
        echo ""
        echo "Searching for '$word'..."
        
        # Get matching lines starting with word
        local matches=($(history | grep -E "^ *[0-9]+ *\[.*\] +${word}" | awk '{print $1}' | tac))
		
        
        if [[ ${#matches[@]} -gt 0 ]]; then
            echo "Found ${#matches[@]} matches: ${matches[*]}"
            
            # Delete matches for this word
            for num in "${matches[@]}"; do
                history -d "$num"
                echo -e "${GREEN}Deleted #$num${NC}"
            done
            
            # Save history IMMEDIATELY after each word
            history -w
            echo -e "${GREEN}Saved history after '$word' cleanup${NC}"
        else
            echo "No matches for '$word'"
        fi
    done
    
    echo ""
    echo -e "${BOLD}${GREEN}Complete! All words processed.${NC}"
}

## Usage hisdany history    --- Deletes all commands in .bash_history that contains given words with history
hisdany() {
    local in_word_list="$1"
    if [[ -z "$in_word_list" ]]; then
        echo -e "${RED}Usage: hisdany 'word1,word2,word3'${NC}"
        echo -e "Example: hisdany 'cd,rm,ping'${NC}"
        return 1
    fi
    
    # Split comma-separated in_word_list into array
    IFS=',' read -ra words <<< "$in_word_list"
    
    echo -e "${YELLOW}Deleting history for: ${words[*]}${NC}"
    
    # Loop through each word
    for word in "${words[@]}"; do
        word=$(echo "$word" | xargs)  # trim whitespace
        
        echo ""
        echo "Searching for '$word'..."
        
        # Get matching lines for this word
        local matches=($(history | grep -E "^ *[0-9]+ *\[.*\] +.*$word" | awk '{print $1}' | tac))	
        
        if [[ ${#matches[@]} -gt 0 ]]; then
            echo "Found ${#matches[@]} matches: ${matches[*]}"
            
            # Delete matches for this word
            for num in "${matches[@]}"; do
                history -d "$num"
                echo -e "${GREEN}Deleted #$num${NC}"
            done
            
            # Save history IMMEDIATELY after each word
            history -w
            echo -e "${GREEN}Saved history after '$word' cleanup${NC}"
        else
            echo "No matches for '$word'"
        fi
    done
    
    echo ""
    echo -e "${BOLD}${GREEN}Complete! All words processed.${NC}"
}


## Function to setup git repo in the current folder also set repo for github push
setgit() {

	# Call the function to load the github ssh keys
	load_sshkey_github

	echo ""
    # Parse -des parameter for commit message
    CUSTOM_MSG=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            -des)
                CUSTOM_MSG="$2"
                shift 2
                ;;
            *)
                echo -e "${BOLD}${RED} Unknown option: $1${NC}"
                echo -e "${BOLD}${YELLOW} Usage: cnpush [-des 'your description for github']${NC}"
				echo ""
                return 1
                ;;
        esac
    done

    # Check if pwd has Git repository .git folder if not ask and create local repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Not a Git repository!${NC}"
		echo ""
		echo -e "${BOLD}${YELLOW}INFO: No .git folder found. Create local Git repository? (y/N)${NC}"
		echo ""    
		read -r -p "Enter Y to proceed [y/N]: " response
		response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
		
		# Create local git repo in the current folder
		if [[ "$response" =~ ^(y|yes)$ ]]; then
			echo -e "${BOLD}${GREEN}INFO: Creating local Git repository...${NC}"
			echo ""
			if ! git init; then
				echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}git init failed${NC}"
				echo ""
				return 1
			fi
			
			echo -e "${BOLD}${GREEN} Git repository initialized!${NC}"
		    echo ""	
		else
			echo -e "${BOLD}${RED}ERROR: Git Repo is not created.${NC}"
			echo -e "${BOLD}${YELLOW}INFO: Git initialization skipped by user.${NC}"
			echo ""
			return 1
		fi
	else
		echo -e "${BOLD}${YELLOW}INFO: Git Repo already present.${NC}"
		echo -e "${BOLD}${YELLOW}INFO: Git initialization skipped.${NC}"
		echo ""
    fi

    # Create the default .gitignore file
	if [[ ! -f .gitignore ]]; then	
		echo "~*" >> .gitignore
		echo "*~" >> .gitignore
		echo "~\$*" >> .gitignore
		echo "*.log" >> .gitignore
	else 
		echo -e "${BOLD}${YELLOW}INFO: .gitignore present.${NC}"
		echo ""
	fi
	
    # Add all files (handle permission errors)
    if ! git add .; then
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}git add failed (check file permissions/locks)${NC}"
        echo -e "${BOLD}${YELLOW} Close Excel/Office apps or add '~$*' to .gitignore${NC}"
		echo ""
        return 1
	else
		echo -e "${BOLD}${GREEN} Git add successful${NC}"
		echo ""	
    fi

    # Check for changes in the modules
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${BOLD}${YELLOW} Changes detected - proceeding to commit${NC}"
		echo ""
    else
        echo -e "${BOLD}${YELLOW} No changes to commit!${NC}"
		echo ""
        return 0
    fi
	
	# Generate timestamp
    dtvar="dt_$(date +%Y_%m_%d)"
    repo_name=$(basename "$PWD")
    time_hm=$(date +%H_%m)

    # Validate inputs
    if [[ -z "$repo_name" ]]; then
        echo -e "${BOLD}${RED}ERROR: repo_name is required${NC}"
		echo ""		
        return 1
    fi

    # Build commit message
    BASE_MSG="Commit on ${dtvar}_${time_hm}"
    if [[ -n "$CUSTOM_MSG" ]]; then
        commit_msg="${BASE_MSG} - ${CUSTOM_MSG}"
    else
        commit_msg="$BASE_MSG"
    fi
    
    # Commit
    if git commit -m "$commit_msg"; then
		echo ""
		echo -e "${BOLD}${GREEN} Commit Successful: ${dtvar}_${time_hm}${NC}"
		echo ""
    else
		echo ""
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Commit failed${NC}"
		echo ""
        return 1
    fi

	# Check if current branch is main
	CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null)

	if [[ "$CURRENT_BRANCH" == "main" ]]; then
		echo -e "${BOLD}${GREEN} Current branch is main${NC}"
		echo ""
	else
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Current branch is NOT main${NC}"
		echo -e "${BOLD}${YELLOW}Current branch is: $CURRENT_BRANCH ${BOLD}${GREEN}(expected: main)${NC}"
		echo -e "${BOLD}${YELLOW}Fix this and proceed with github push${NC}"
		echo ""
		return 1
	fi
	
	# Check github auth status -- gh authentication
    if ! gh auth status > /dev/null 2>&1; then
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Not authenticated with GitHub CLI. Run: gh auth login${NC}"
		echo ""		
        return 1
	else
		echo -e "${BOLD}${YELLOW} gh auth status is ACTIVE${NC}"
		echo ""		
    fi	

	echo ""	
	# Create a public repo in github
    if ! gh repo create "$repo_name" --public --description "$commit_msg"; then
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Failed to create GitHub repo '$repo_name'${NC}"
        echo -e "${BOLD}${YELLOW}Check if repo already exists or name is valid${NC}"
		echo ""		
        echo -e "${BOLD}${YELLOW}Try to use cnpush when repo already exists${NC}"
		echo ""		
        return 1
	else
		echo -e "${BOLD}${GREEN} GitHub repo created: $repo_name${NC}"	
		echo ""		
    fi

    # Add remote repository in github 
    if ! git remote add "$repo_name" "git@github.com:nesancommitter/$repo_name.git"; then
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Failed to add remote '$repo_name'${NC}"
        echo -e "${BOLD}${YELLOW}Check: git remote remove $repo_name && retry${NC}"
		echo ""		
        return 1
    fi
	
	# Check the remote -v has right configuration
	# Check if git remote -v matches exact expected output
	EXPECTED_REMOTE=$repo_name
	EXPECTED_URL="git@github.com:nesancommitter/$repo_name.git"

	REMOTE_OUTPUT=$(git remote -v 2>/dev/null)

	if [[ $? -ne 0 ]]; then
		echo -e "${BOLD}${RED}ERROR: git remote -v failed (not a git repo?)${NC}"
		echo ""			
		return 1
	fi

	# Extract remote name and URL from output
	ACTUAL_REMOTE=$(echo "$REMOTE_OUTPUT" | awk '{print $1}' | head -1)
	ACTUAL_URL=$(echo "$REMOTE_OUTPUT" | awk '{print $2}' | head -1)

	if [[ "$ACTUAL_REMOTE" == "$EXPECTED_REMOTE" && "$ACTUAL_URL" == "$EXPECTED_URL" ]]; then
		echo -e "${BOLD}${GREEN} Remote matches expected:${NC}"
		echo -e "   $ACTUAL_REMOTE $ACTUAL_URL (fetch)${NC}"
		echo -e "   $ACTUAL_REMOTE $ACTUAL_URL (push)${NC}"
		echo ""			
	else
		echo -e "${BOLD}${RED} Remote mismatch:${NC}"
		echo -e "   Expected: $EXPECTED_REMOTE $EXPECTED_URL${NC}"
		echo -e "   Actual:   $ACTUAL_REMOTE $ACTUAL_URL${NC}"
		echo ""	
		return 1
	fi

    #Check and start ssh-agent
    start_ssh_agent

    #Add the private key of github web to the SSH agent
	# Check if any key in SSH agent contains "nesan.committer@gmail.com (ED25519)"
	if ! ssh-add -l | grep -q "nesan.committer@gmail.com (ED25519)"; then
	    echo ""
	    echo -e "${BOLD}${YELLOW}passphrase: passgithubweb${NC}"
		echo ""
		ssh-add ~/.ssh/githubweb
	fi	

	# Check if any SSH test connection to git@github returns "Hi nesancommitter"
	if ssh -T git@github.com | grep -q "Hi nesancommitter"; then
	    echo ""
        echo -e "${BOLD}${RED}ERROR: github test connect is not for nesancommitter${NC}"
		echo ""
		return 1
	else
		echo -e "${BOLD}${GREEN}SUCCESS: github test connect for nesancommitter${NC}"	
	fi
	
    # Push the local repo to remote github repo that is created now
    echo -e "${BOLD}${GREEN}Pushing to GitHub...${NC}"
	echo ""			
    if ! git push -u "$repo_name" main; then
        echo "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}git push failed${NC}"
        echo "${BOLD}${YELLOW}Check SSH keys: ssh -T git@github.com${NC}"
		echo ""			
        return 1
    fi
    
    echo "${BOLD}${GREEN}SUCCESS: Repo '$repo_name' created and pushed!${NC}"
    echo "${BOLD}${BLUE}https://github.com/nesancommitter/$repo_name${NC}"
	echo ""		
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
				echo ""
                return 1
                ;;
        esac
    done

    # Check if pwd has Git repository .git folder
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Not a Git repository!${NC}"
		echo ""
        return 1
	else
        echo -e "${BOLD}${YELLOW}This folder has .git repo${NC}"
		echo ""			
    fi

    # Add all files (handle permission errors)
    if ! git add .; then
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}git add failed (check file permissions/locks)${NC}"
        echo -e "${BOLD}${YELLOW}Close Excel/Office apps or add '~$*' to .gitignore${NC}"
		echo ""
        return 1
	else
        echo -e "${BOLD}${YELLOW}git add successful${NC}"
		echo ""	
    fi
    
    # Check for changes in the modules
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${BOLD}${YELLOW}Changes detected - proceeding...${NC}"
		echo ""
    else
        echo -e "${BOLD}${YELLOW}No changes to commit!${NC}"
		echo ""
        return 0
    fi
    
    # Generate timestamp
    dtvar="dt_$(date +%Y_%m_%d)"
    repo_name=$(basename "$PWD")
    time_hm=$(date +%H_%m)

    # Validate inputs
    if [[ -z "$repo_name" ]]; then
        echo -e "${BOLD}${RED}ERROR: repo_name is required${NC}"
		echo ""		
        return 1
    fi
	
    # Build commit message
    BASE_MSG="Commit on ${dtvar}_${time_hm}"
    if [[ -n "$CUSTOM_MSG" ]]; then
        commit_msg="${BASE_MSG} - ${CUSTOM_MSG}"
    else
        commit_msg="$BASE_MSG"
    fi
    
    # Commit
    if git commit -m "$commit_msg"; then
        echo -e "${BOLD}${GREEN}Commit Successful: ${dtvar}_${time_hm}${NC}"
		echo ""
    else
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Commit failed${NC}"
		echo ""
        return 1
    fi
	
	# Fetch the remote name used for this git repo 
	REMOTE_NAME=$(git remote | head -1)  # First remote name
	if [[ -z "$REMOTE_NAME" ]]; then
	    echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}No remotes found! (run: git remote -v)${NC}"
		echo ""
    	return 1
	else
        echo -e "${BOLD}${GREEN}Remote Found with repo name : $REMOTE_NAME${NC}"
		echo ""
	fi

    # Check Remote repo name is same as the local folder
	if [[ "$REMOTE_NAME" == "$repo_name" ]]; then   #space added
        echo -e "${BOLD}${GREEN}Remote repo name match with local folder${NC}"
		echo ""
	else
	    echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Remote repo not match with local folder${NC}"
        echo -e "${BOLD}${YELLOW}Remote Repo : $REMOTE_NAME${NC}"		
        echo -e "${BOLD}${YELLOW}Local folder : $repo_name${NC}"			
		echo ""
    	return 1
	fi

    # Push (with remote check)
    local remote_url=$(git remote get-url "$REMOTE_NAME" 2>/dev/null || echo "")
    if [[ -z "$remote_url" ]]; then
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Cannot get Remote URL for '$REMOTE_NAME'${NC}"
		echo ""
        return 1
	else
        echo -e "${BOLD}${YELLOW}Remote URL : $remote_url${NC}"
		echo ""	
    fi

    #Check and start ssh-agent
    start_ssh_agent

    #Add the private key of github web to the SSH agent
	# Check if any key in SSH agent contains "nesan.committer@gmail.com (ED25519)"
	if ! ssh-add -l | grep -q "nesan.committer@gmail.com (ED25519)"; then
	    echo ""
	    echo -e "${BOLD}${YELLOW}passphrase: passgithubweb${NC}"
		echo ""
		ssh-add ~/.ssh/githubweb
	fi	

	# Check if any SSH test connection to git@github returns "Hi nesancommitter"
	if ssh -T git@github.com | grep -q "Hi nesancommitter"; then
	    echo ""
        echo -e "${BOLD}${RED}ERROR: github test connect is not for nesancommitter${NC}"
		echo ""
		return 1
	else
		echo -e "${BOLD}${GREEN}SUCCESS: github test connect for nesancommitter${NC}"	
	fi
    
    if git push -u "$repo_name" main; then
        echo -e "${BOLD}${GREEN}Pushed: ${dtvar}_${time_hm} → $repo_name${NC}"
		echo ""
    else
        echo -e "${BOLD}${RED}ERROR: ${BOLD}${YELLOW}Push failed (check internet/permissions)${NC}"
		echo ""
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
	echo -e "${BOLD}${GREEN}   hisd          : ${YELLOW}keep bash_history clean remove unwanted commands - start with ${NC}"
	echo -e "${BOLD}${GREEN}   hisdany       : ${YELLOW}keep bash_history clean remove unwanted commands - contains ${NC}"
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
	echo -e "${BOLD}${BLUE}*************************************************${NC}"	
    echo 
	echo -e "${BOLD}${BLUE}*************************************************${NC}"
	echo -e "${BOLD}${BLUE}****   ${RED}Useful commands to manage Container   ${BLUE}****${NC}"
	echo -e "${BOLD}${BLUE}*************************************************${NC}"	
	echo -e "${BOLD}${GREEN}   colorpallet   : ${YELLOW}Display echo color pallet ${NC}"
	echo -e "${BOLD}${GREEN}   clpdgcache    : ${YELLOW}Clear Cached package index files ${NC}"
	echo -e "${BOLD}${GREEN}   clpipcache    : ${YELLOW}Clear pip Cached files ${NC}"	
	echo -e "${BOLD}${GREEN}   cltmpcache    : ${YELLOW}Clear tmp folders ${NC}"	
	echo -e "${BOLD}${GREEN}   claptcache    : ${YELLOW}Clear apt-get package folders${NC}"
	echo -e "${BOLD}${GREEN}   trim_img      : ${YELLOW}Delete unwanted apt libraries and pip catch folders${NC}"
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

