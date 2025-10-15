#!/bin/sh

# CONSTANT VARIABLES
CONFIG_DIR=/etc/salt

logg() {
    level=$1
    shift
    msg="$*"
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf "[%s] [%s] %s\n" "$timestamp" "$level" "$msg"
}

validate_configurations() {
    if [ -z "$SALT_MASTER" ]; then
        logg ERROR "Error. SALT_MASTER is not set or empty"
        exit 1
    else
        logg INFO "SALT_MASTER is set to ${SALT_MASTER}"
    fi
    if [ -z "$SALT_MINION_ID" ]; then
        logg ERROR "SALT_MINION_ID is not set or empty"
        exit 1
    else
        logg INFO "SALT_MINION_ID is set to ${SALT_MINION_ID}"
    fi
}

create_config_file() {
    salt_config_path="$CONFIG_DIR/minion"
    if [ -f "$salt_config_path" ]; then
        logg INFO "Minion config file exists."
    else
        logg INFO "Minion config file does not exist. Creating it:"
        mkdir -p "$CONFIG_DIR"
        {
          echo "master: ${SALT_MASTER}"
          echo "id: ${SALT_MINION_ID}"
        } > "$salt_config_path"
    fi
    logg INFO "Content of $salt_config_path:"
    cat "$salt_config_path"
}

run_minion() {
    salt-minion -l info -c "$CONFIG_DIR"
}

validate_configurations
create_config_file
run_minion