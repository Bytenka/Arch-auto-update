LOG_FOLDER=logs
LOG_FILE=$LOG_FOLDER/$(date +"%Y%m%d-%T").log
LOG_FILE_YAY=${LOG_FILE}.yay
HTML_MAIL="mail_to_send.html"                 # Arbitrary name. This file is just a buffer and will exist only for the duration of the script
MAIL_GEN_SCRIPT="generate-mail.py"


## ---------- Utility functions ---------- ##
function isKernelUpToDate {
    local runningVersion=$(uname -r | cut -d "-" -f1)
    local installedVersion=$(pacman -Q linux | cut -d " " -f2 | cut -d "." -f1-3)

    if [[ $runningVersion != $installedVersion ]]; then
        echo "$runningVersion -> $installedVersion"
    else
        echo ""
    fi
}

function perform_update() {
  yay -Syu --noprogressbar --color never --noconfirm > $LOG_FILE_YAY 2>&1
  local exitCode=$?
  
  #local restartRequired="$(cat $LOG_FILE_YAY | grep 'upgrading linux...' | wc -l)"

  if [[ $exitCode -eq 0 ]]; then
    local nbPackages="$(cat $LOG_FILE_YAY | grep 'upgrading' | wc -l)"
    echo "success~No error reported during update.\nUpgraded $nbPackages packages."

  else
    echo "failed~Something went wrong while running \"yay -Syu\".\nAuto-updates have been disabled to prevent further incidents.\nManual intervention is required."
  fi

  #return $(($restartRequired))
}
## --------------------------------------- ##



mkdir -p $LOG_FOLDER
echo "---------- Beginning log ----------" >> $LOG_FILE



## -- Performing the update -- ##

dateStarted=$(date +%s)
echo "Running yay -Syu..."
msgStatus="$(perform_update)"
echo "done"
dateFinished=$(date +%s)



## ----- Analysing the results ----- ##

updateStatus=$(echo "$msgStatus" | cut -d "~" -f1)
updateMsg=$(echo "$msgStatus" | cut -d "~" -f2)
restartRequired="$(isKernelUpToDate)"

if [[ -n $restartRequired ]]; then
  updateMsg="$updateMsg\n\n<b>Restart required to apply kernel upgrade\n($restartRequired)</b>"  
fi

cat $LOG_FILE_YAY >> $LOG_FILE
echo "------------- End log -------------" >> $LOG_FILE



## ----- Generating the mail (python script) ----- ##
echo "Generating mail..."
python $MAIL_GEN_SCRIPT "$dateStarted" "$dateFinished" "$updateStatus" "$updateMsg" "$(realpath $LOG_FILE)" > $HTML_MAIL
echo "done"


## --- Sending the mail --- ##
echo "Sending mail..."
mail -C "Content-Type: text/html" -s "Xeonize performed auto-update" hugo.trsd@gmail.com < $HTML_MAIL
echo "done"



## --- Cleaning up () --- ##

if [[ -e $LOG_FILE_YAY ]]; then
  rm -f $LOG_FILE_YAY
fi

if [[ -e $HTML_MAIL ]]; then
  rm -f $HTML_MAIL
fi
