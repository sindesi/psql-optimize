#!/bin/bash
#===============================================================================
#
#          FILE:  opt_pgsql.sh
# 
#         USAGE:  ./opt_pgsql.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Nuno Leitao (nunogrl@gmail.com), 
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  12-02-2007 15:00:47 WET
#      REVISION:  ---
#===============================================================================

#-------------------------------------------------------------------------------
#   Variables
#-------------------------------------------------------------------------------
RAM=`free -b| head -n2 | tail -n1 | awk '{ print $2 }'`
SHMMAX=`cat /proc/sys/kernel/shmmax`
POSTGRESQL_CONF=/var/lib/pgsql/data/postgresql.conf
#-------------------------------------------------------------------------------
banner ()
{
	clear
	echo -e "\\033[0;44mFev-07                                                                          \\033[0;39m"
	echo -e "\\033[1;37m\033[1;44m           Sindesi - Sistemas e Solucoes Informaticas, Lda                      \\033[0;39m"
	echo -e "\\033[0;44m                                                                                \\033[0;39m"
}

calculate_kernel_shmmax ()
{
	#	echo -e "\\033[1;37m\033[1;44m+------------------------------------------------------------------------------+\\033[0;39m"
	#	echo -e "\\033[1;37m\033[1;44m| Memory = $RAM      Actual shmmax value: $SHMMAX"
	#	echo -e "+------------------------------------------------------------------------------+\\033[0;39m"
	echo "Actual memory available for postgresql: $SHMMAX bytes"
	shmmax_memory_attribution $SHMMAX
	echo 
	
	#-------------------------------------------------------------------------------
	#  Calculate kernel.shmmax -> A * X^2 + B * X + C  
	#-------------------------------------------------------------------------------
	RAM_SQUARE=$(($RAM*$RAM))
	RAM_milesime=$(($RAM_SQUARE/1000))
	SHMMAX_POWER=$((5164*$RAM_milesime))
	A=$(($SHMMAX_POWER/100000000000))
	B=$((64133998*$RAM))
	B=$(($B/100000000))
	C=56173
	result=$(($(($B+$C))-$A))
	echo "Postgresql usage after optimization:    $result bytes"
	
	shmmax_memory_attribution $result
	
	# echo "new kernel.shmmax =  $result"
	
	#  -0.00000000005164* X ^2+0.64133998* X + 56173.7128
}

shmmax_memory_attribution ()
{
	value=$1
	max_chars=72

	# percentage=$(($(($SHMMAX*100))/$RAM))
	percentage=$(($(($value*100))/$RAM))
	echo "   +------------------------------------------------------------------------+"
	echo  -n  "   |"
	chars=$(($(($percentage*70))/100))
	for ((i=1;i<=$chars;i++)); do
		echo -n "#";
	done
	for ((i=1;i<=$((max_chars-$chars));i++)); do
		echo -n ".";
	done
	echo "|"
	echo "   +------------------------------------------------------------------------+"
	echo "   Postgresql usage: $percentage % "
}

read_postgresql_conf ()
{
	echo -e "\\033[1;37m\033[1;44m+------------------------------------------------------------------------------+\\033[0;39m"
	# echo -e "--------------------------------------------------------------------------------\\033[0;39m"
 	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep tcpip_socket`\t\t\ttcpip_socket = true"
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep max_connections`\t\t\tmax_connections = true"
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep shared_buffers`\t\t\tshared_buffers = true"
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep sort_mem`\t\t\t\tsort_mem = " 
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep vacuum_mem`\t\t\tvacuum_mem = true" 
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep wal_buffers`\t\t\twal_buffers = true" 
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep checkpoint_segments`\t\t\tcheckpoint_segments = " 
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep checkpoint_timeout`\t\tcheckpoint_timeout = " 
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep checkpoint_warning`\t\t\tcheckpoint_warning = true"
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep effective_cache_size`\t\teffective_cache_size = true"
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep lc_messages`\t\tlc_messages = true" 
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep lc_monetary`\t\tlc_monetary = true"
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep lc_numeric`\t\tlc_numeric = true" 
	echo -e "`cat $POSTGRESQL_CONF | awk -F"#" '{ print $1 }' | awk -F"\t" '{ print $1 }'| grep lc_time`\t\t\tlc_time = true"
	
	
}

banner
calculate_kernel_shmmax
# read_postgresql_conf


