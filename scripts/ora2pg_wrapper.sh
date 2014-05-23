# Script to manage unique table migration from Oracle to Postgresql using ora2pg



# Variables
export LD_LIBRARY_PATH=/usr/X11R6/lib:$ORACLE_HOME/lib

TABLE_NAME=$1
DB=$2
REF_ORA2PG_CONF_FILE=ora2pg.conf
WORK_DIR=$HOME/${DB}_migration/${TABLE_NAME}

# Oracle side
ORA_DB_SERVER=''
ORA_USER='system'
ORA_PASSWORD=''

# Postgresql side
PG_DB_SERVER='localhost'
PG_PORT='5432'
PG_USER=''
PG_DATABASE=''

# Preparing the environement

mkdir -p $WORK_DIR

# Forging temporary ora2pg file that will be used

cp $REF_ORA2PG_CONF_FILE $WORK_DIR/

echo "ALLOW ${TABLE_NAME}" >> $WORK_DIR/ora2pg.conf

# Exporting DDL
echo "$(date) : ${TABLE_NAME} : Begin"
ora2pg -t TABLE -c $WORK_DIR/ora2pg.conf -o create_table.sql -b ${WORK_DIR} --table_name ${TABLE_NAME}

sed -i "s/TRUNC(LOCALTIMESTAMP, 'MONTH')/date_trunc('month', LOCALTIMESTAMP)/g ; s/trunc(LOCALTIMESTAMP, 'MONTH')/date_trunc('month', LOCALTIMESTAMP)/g" ${WORK_DIR}/create_table.sql

# Creating table
psql -X -h $PG_DB_SERVER -p $PG_PORT -U $PG_USER $PG_DATABASE << EOF
drop table  IF EXISTS ${TABLE_NAME};
\i ${WORK_DIR}/create_table.sql
EOF

if [[ ${TABLE_NAME} == *_something ]] 
then
	psql -X -h $PG_DB_SERVER -p $PG_PORT -U $PG_USER $PG_DATABASE << EOF
\i create_all_part.sql
EOF
fi


ora2pg -t COPY -c $WORK_DIR/ora2pg.conf  -j 10 --table_name ${TABLE_NAME}

echo "$(date) : ${TABLE_NAME} : End"
