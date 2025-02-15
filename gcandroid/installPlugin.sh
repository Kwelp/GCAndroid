# Score-Inc/GCAndroid is licensed under the
# GNU General Public License v3.0

installPlugin_Download() {
    credit_hah
    line5 "Install Plugin Download"
    echo "${YC}Enter b/B for back${WC}"
    echo
    echo -n "${GC}Enter link Download .jar : ${WC}"
    read -r installPlugin_Download_Link
    if [[ $installPlugin_Download_Link == "" ]]; then
        echo "${RC}Please enter link!${WC}"
        sleep 1s
        installPlugin_Download
    elif [[ $installPlugin_Download_Link == "b" ]] || [[ $installPlugin_Download_Link == "B" ]]; then
        installPlugin
    fi
    folderNamePlugin=$HOME/PluginsGC
    if [ -d "$folderNamePlugin" ]; then
        rm -rf $folderNamePlugin
        mkdir $folderNamePlugin
    fi
    if [ ! -d "$folderNamePlugin" ]; then
        mkdir $folderNamePlugin
    fi
    cd $folderNamePlugin
    run_Program() {
        wget $installPlugin_Download_Link &>$HOME/zerr.log
        errCode=$?
        log "$errCode"
    }
    run_Program &
    pid=$!
    spin "${GC}Download .jar plugin${WC}" "0" "Plugins Menu" "installPlugin"
    getNamePlugin=$(ls $folderNamePlugin | sed "s/.*\///g")
    if [ ! -d "$HOME/Grasscutter/plugins" ]; then
        mkdir "$HOME/Grasscutter/plugins"
    fi
    if [[ $(echo "$getNamePlugin" | sed "s/.*\.//g") != "jar" ]]; then
        echo "${RC}Cannot continue because $getNamePlugin not .jar file!${WC}"
        echo
        rm -rf $folderNamePlugin
        read -p "Press enter for back to Menu!"
        main_menu
        return
    fi
    if [ -f "$HOME/Grasscutter/plugins/$getNamePlugin" ]; then
        echo "${YC}Failed to install because $getNamePlugin already installed${WC}"
        echo
        echo -n "Press enter for back to Plugin Menu!"
        rm -rf $folderNamePlugin
        read
        installPlugin
        return
    fi
    run_Program() {
        cp $folderNamePlugin/$getNamePlugin $HOME/Grasscutter/plugins/$getNamePlugin &>$HOME/zerr.log
        errCode=$?
        log "$errCode"
    }
    run_Program &
    pid=$!
    spin "${GC}Installing .jar plugin${WC}" "0" "Plugins Menu" "installPlugin"
    if [ -f "$HOME/Grasscutter/plugins/${getNamePlugin}" ]; then
        echo "${GC}Install plugin ${getNamePlugin} success!${WC}"
        echo
        rm -rf $folderNamePlugin
        echo -n "Press enter for back to Menu!"
        read
        main_menu
        return
    else
        echo "${RC}Install plugin ${getNamePlugin} failed!${WC}"
        echo
        rm -rf $folderNamePlugin
        echo -n "Press enter for back to Menu!"
        read
        main_menu
        return
    fi
}

installPlugin_from_directory() {
    credit_hah
    line5 "Install Plugin Directory"
    echo "1. ${CCB}Using dialog command${WC}"
    echo "2. ${CCB}Manual Typing${WC}"
    echo "3. ${CCB}Help for Dialog command${WC}"
    echo "0. ${RC}Back${WC}"
    echo
    echo -n "Enter input : "
    read -r installPlugin_from_directory_input
    case $installPlugin_from_directory_input in
    "1")
        installPlugin_from_directory_Input="1"
        installPlugin_from_directory_process
        ;;
    "2")
        installPlugin_from_directory_Input="2"
        installPlugin_from_directory_process
        ;;
    "3")
        credit_hah
        echo "${YC}1. ${CCB}Space on your keyboard for select file!${WC}"
        echo "${YC}2. ${CCB}Use ↑, ↓, ←, → for interaction!${WC}"
        echo "${YC}3. ${CCB}Enter on your keyboard to continue if the choice is correct${WC}"
        echo
        echo -n "Press enter for back!"
        read
        installPlugin_from_directory
        ;;
    "0") installPlugin ;;
    *)
        echo "${RC}Wrong input!${WC}"
        sleep 1s
        installPlugin_from_directory
        ;;
    esac
}

installPlugin_from_directory_process() {
    if [[ $installPlugin_from_directory_Input == "1" ]]; then
        FILE=$(dialog --stdout --title "Please choose a .jar plugin" --fselect /sdcard/ 14 48)
        clear
        installPlugin_from_directory_Input_File=$FILE
        fileSearchDialog=true
        # echo "$installPlugin_from_directory_Input_File"
        # exit
        credit_hah
        line5 "Install Plugin Directory"
    elif [[ $installPlugin_from_directory_Input == "2" ]]; then
        credit_hah
        line5 "Install Plugin Directory"
        echo "${YC}Enter b/B for back${WC}"
        echo
        echo "${CCB}Please enter where .jar plugin${WC}"
        echo
        echo -n "${GC}Path : ${WC}"
        read -r installPlugin_from_directory_Input_File
    else
        echo "${RC}Wrong input!${WC}"
        sleep 1s
        installPlugin_from_directory
        return
    fi
    if [[ $installPlugin_from_directory_Input_File == "" ]]; then
        if [[ $fileSearchDialog = true ]]; then
            echo "${RC}Cancel by user${WC}"
            sleep 1s
            installPlugin_from_directory
        else
            echo "${RC}Please enter path!${WC}"
            sleep 1s
            installPlugin_from_directory_process
            return
        fi
    elif [[ $installPlugin_from_directory_Input_File == "b" ]] || [[ $installPlugin_from_directory_Input == "B" ]]; then
        installPlugin_from_directory
        return
    fi
    if ! [ -f "$installPlugin_from_directory_Input_File" ]; then
        echo "${RC}.jar not found! in ${installPlugin_from_directory_Input_File}${WC}"
        sleep 1.5s
        installPlugin_from_directory
        return
    else
        if ! [ "$(ls $installPlugin_from_directory_Input_File | sed "s/.*\.//g")" == "jar" ]; then
            echo "${RC}Cannot continue because $(echo "$installPlugin_from_directory_Input_File" | sed "s/.*\///g") not .jar file!${WC}"
            echo
            read -p "Press enter for back to Menu!"
            main_menu
            return
        else
            cp "$installPlugin_from_directory_Input_File" $HOME/Grasscutter/plugins &>/dev/null
        fi
        getNamePlugin=$(ls $installPlugin_from_directory_Input_File | sed "s/.*\///g")
        if [[ ! -f "$HOME/Grasscutter/plugins/$(echo $installPlugin_from_directory_Input_File | sed "s/.*\///g")" ]]; then
            echo "${RC}Failed install ${getNamePlugin} plugin to Grasscutter Folder!${WC}"
            echo
            read -p "Press enter for back to Menu!"
            main_menu
            return
        else
            echo "${GC}Plugin ${getNamePlugin} success installed!${WC}"
            echo
            read -p "Press enter for back to Menu!"
            main_menu
            return
        fi
    fi
}

installPlugin_Compile() {
    if ! command -v mvn &>/dev/null; then
        credit_hah
        line10 "Installing Program maven"
        run_Program() {
            sudo apt install maven &>$HOME/zerr.log
            errCode=$?
            log "$errCode"
        }
        run_Program &
        pid=$!
        spin "${GC}Installing Maven${WC}" "0" "Menu Plugin" "installPlugin"
    fi
    if ! command -v git &>/dev/null; then
        credit_hah
        line10 "Installing Program git${WC}"
        run_Program() {
            sudo apt install git &>$HOME/zerr.log
            errCode=$?
            log "$errCode"
        }
        run_Program &
        pid=$!
        spin "${GC}Installing Git${WC}" "0" "Menu Plugin" "installPlugin"
    fi
    credit_hah
    line5 "Install Plugin Clone Repo"
    echo "${YC}Enter b/B for back!${WC}"
    echo
    echo "${CCB}Enter link Github Repo for Clone!${WC}"
    echo -n "Link : "
    read -r installPlugin_Compile_Link
    if [[ $installPlugin_Compile_Link == "" ]]; then
        echo "${RC}Please enter link!${WC}"
        sleep 1s
        installPlugin_Compile
    fi
    if [[ $installPlugin_Compile_Link == "b" ]] || [[ $installPlugin_Compile_Link == "B" ]]; then
        installPlugin
    fi
    folderRepo="$HOME/GCCloneRepo"
    if [ ! -d "$folderRepo" ]; then
        mkdir $folderRepo
    fi
    if [ -d "$folderRepo" ]; then
        rm -rf $folderRepo
        mkdir $folderRepo
    fi
    credit_hah
    line10 "Compiling"
    cd $folderRepo
    run_Program() {
        git clone $installPlugin_Compile_Link &>$HOME/zerr.log
        errCode=$?
        log "$errCode"
    }
    run_Program &
    pid=$!
    spin "${GC}Git Clone Repo${WC}" "0" "Try Again" "installPlugin_Compile"
    getRepoName=$(basename "$installPlugin_Compile_Link")
    if echo "$getRepoName" | grep ".*.git" &>/dev/null; then
        getRepoName=$(echo "$getRepoName" | sed "s/.git//g")
    fi
    cd $getRepoName || exit 1
    echo "${YC}If first time, it will take long time. so wait!${WC}"
    run_Program() {
        mvn package &>$HOME/zerr.log
        errCode=$?
        log "$errCode"
    }
    run_Program &
    pid=$!
    spin "${GC}Compiling Plugin${WC}" "0" "Menu Plugin" "installPlugin"
    getNamePlugin=$(basename "$(ls "target/" | grep ".*.jar" | sed "s/original-//g" | head -1)")
    if [ -f "$HOME/Grasscutter/plugins/$getNamePlugin" ]; then
        echo "${YC}Plugin $getNamePlugin already installed!${WC}"
    else
        run_Program() {
            cp "target/$getNamePlugin" "$HOME/Grasscutter/plugins" &>$HOME/zerr.log
            errCode=$?
            log "$errCode"
        }
        run_Program &
        pid=$!
        spin "${GC}Installing Plugins${WC}" "0" "Menu Plugin" "installPlugin"
    fi
    rm -rf $folderRepo
    if [ -f "$HOME/Grasscutter/plugins/$getNamePlugin" ]; then
        echo "${GC}Plugins $getNamePlugin success installed!${WC}"
        echo
        echo -n "Press enter for back to Menu Plugin"
        read
        installPlugin
        return
    else
        echo "${RC}Plugins $getNamePlugin failed install${WC}"
        echo
        echo -n "Press enter for back to Menu Plugin"
        read
        installPlugin
        return
    fi
}

installPlugin() {
    credit_hah
    line10 "Install Plugin"
    if ! [ -d "$HOME/Grasscutter" ]; then
        echo "${RC}Folder Grasscutter in $HOME/Grasscutter is not found!${WC}"
        echo
        read -p "Press enter for back to Menu Grasscutter Tools"
        Grasscutter_Tools
    fi
    echo "1. ${CCB}Download plugin and Install${WC}"
    echo "2. ${CCB}Install Plugin from local directory${WC}"
    echo "0. ${RC}Back${WC}"
    echo
    echo -n "Enter input : "
    read -r installPlugin_Input
    case $installPlugin_Input in
    "1") installPlugin_Download ;;
    "2") installPlugin_from_directory ;;
    "0") Grasscutter_Tools ;;
    *)
        echo "${RC}Wrong input!${WC}"
        sleep 1s
        installPlugin
        ;;
    esac
}
