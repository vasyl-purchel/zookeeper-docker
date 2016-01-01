#!/bin/bash

# default values for ZOOKEEPER_HOME, ZOOKEEPER_CONFIG_FILE and ZK_DATA_DIR
# are set in docker file so no need to check them here

# if zookeeper node id is setted up, then we're running in replicated mode
# so we need more changes
if [[ -n "$ZK_ID" ]]; then
    if [[ -z "${ZK_SERVERS}" ]]; then
        echo "Please set ZK_SERVERS environment variable to use replicated mode."
        exit 1
    fi
    echo "${ZK_ID}" > $ZK_DATA_DIR/myid
    # add servers entries into config file
    IFS=' ' read -r -a servers <<< "$ZK_SERVERS"
    for id in "${!servers[@]}"
    do
        echo "server.$((id+1))=${servers[id]}" >> $ZOOKEEPER_CONFIG_FILE
    done
fi

for VAR in `env`
do
    # for each environment variable that starts with ZK_
    # and not ZK_ID or ZK_SERVERS used before for replicated mode
    if [[ $VAR =~ ^ZK_ && ! $VAR =~ ^ZK_ID && ! $VAR =~ ^ZK_SERVERS ]]; then
        # remove ZK_ and convert underscores to camelCase
        config_name=`echo "$VAR" | sed -r "s/ZK_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | sed -r 's/([a-z]+)_([a-z])([a-z]+)/\1\U\2\L\3/'`
        # get the value of the variable
        config_value=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
        # if config name is already exists in config file then update value,
        # else add new entry to config file
        if egrep -q "(^|^#)$config_name=" $ZOOKEEPER_CONFIG_FILE; then
            sed -r -i "s@(^|^#)($config_name)=(.*)@\2=${!config_value}@g" $ZOOKEEPER_CONFIG_FILE
            # note that no config values may contain an '@' char
        else
            echo "$config_name=${!config_value}" >> $ZOOKEEPER_CONFIG_FILE
        fi
     fi
done

# Uncomment next 2 lines to verify script works fine
#echo "Generated config file:"
#cat $ZOOKEEPER_CONFIG_FILE

exec "$@"
