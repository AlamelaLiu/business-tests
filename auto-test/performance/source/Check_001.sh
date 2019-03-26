#!/bin/bash

#*****************************************************************************************
# *用例名称：Check_001                                                       
# *用例功能：32*16G内存主槽位插法检查                                                 
# *作者：lwx652446                                                                      
# *完成时间：2019-2-21                                                               
# *前置条件：                                                                            
#   1、D06单板内存主槽位插16根32G内存条                                                                  
# *测试步骤：                                                                               
#   1 启动D06服务器，进入操作系统
#	2 使用free -g命令查询内存    
# *测试结果：                                                                            
#   查询到系统总内存大小为16*32G                                                       
#*****************************************************************************************

#加载公共函数
. ../../../../utils/error_code.inc
. ../../../../utils/test_case_common.inc
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib
. ../../../../utils/sshpasswd.sh

#获取脚本名称作为测试用例名称
test_name=$(basename $0 | sed -e 's/\.sh//')
#创建log目录
TMPDIR=./logs/temp
mkdir -p ${TMPDIR}
#存放脚本处理中间状态/值等
TMPFILE=${TMPDIR}/${test_name}.tmp
#存放每个测试步骤的执行结果
RESULT_FILE=${TMPDIR}/${test_name}.result
test_result="pass"

#预置条件
function init_env()
{
  #检查结果文件是否存在，创建结果文件：
	fn_checkResultFile ${RESULT_FILE}
	
}

#测试执行
function test_case()
{
	#查询总内存大小是否512G
	memory=`free -g|grep Mem|awk '{print $2}'`
	echo "内存大小是："$memory"G"
	if [ $memory -gt 500 ]
	then
		PRINT_LOG "INFO" "memory is da yu 500"
        fn_writeResultFile "${RESULT_FILE}" "memory" "pass"
    else 
        PRINT_LOG "FATAL" "memory is not 512"
        fn_writeResultFile "${RESULT_FILE}" "memory" "fail"
	fi

	num=`dmidecode -t memory | grep -E "Size.*GB|Size.*MB" |wc -l`
	echo "内存条有："$num"条"
	if [ $num -lt 16 ]
	then
		echo "内存条个数小于16条"
	else
		echo "内存条个数大于16条"
	fi
	mem=`dmidecode -t memory | grep -E "Size.*GB|Size.*MB" | awk '{print  $2 $3}'`
	echo "每条内存的大小是："$mem
	
	
	#检查结果文件，根据测试选项结果，有一项为fail则修改test_result值为fail，
	check_result ${RESULT_FILE}

}


#恢复环境
function clean_env()
{
	#清除临时文件
	FUNC_CLEAN_TMP_FILE
}


function main()
{
	init_env || test_result = "fail"
	if [ "$test_result" = "pass" ]
	then
		test_case || test_result = "fail"
	fi
	clean_env || test_result = "fail"
	[ "$test_result" = "pass" ] && return 1
}

main $@
ret=$?
#LAVA平台上报结果接口，勿修改
lava-test-case "$test_name" --result ${test_result}
exit ${ret}
