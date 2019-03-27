#!/bin/bash
#用例名称：NIC_BASIC_Statistics_001
#用例功能：GE网口标准统计数据获取功能测试
#作者：lwx652446
#完成时间：2019-1-30
#前置条件
#    1.单板启动正常
#    2.所有GE网口各模块加载正常
#测试步骤
#    1.执行ifconfig 网口名，有结果A）
#    2.执行ifconfig 网口名 ，网口名不存在，有结果B）
#测试结果
#    A）正确显示网口信息，ip、mac地址，收发包统计，重点关注dropped、overruns字段
#    B）显示设备不存在
#*****************************************************************************************

#加载公共函数,具体看环境对应的位置修改
. ../../../../utils/error_code.inc
. ../../../../utils/test_case_common.inc
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib
#. ./utils/error_code.inc
#. ./utils/test_case_common.inc
#获取脚本名称作为测试用例名称
test_name=$(basename $0 | sed -e 's/\.sh//')
#创建log目录
TMPDIR=./logs/temp
mkdir -p ${TMPDIR}
#存放脚本处理中间状态/值等
TMPFILE=${TMPDIR}/${test_name}.tmp
#存放每个测试步骤的执行结果
RESULT_FILE=${TMPDIR}/${test_name}.result

#自定义变量区域（可选）
#var_name1="xxxx"
#var_name2="xxxx"
test_result="pass"

#************************************************************#
# Name        : eth_a                        #
# Description : 查找GE网口                                 #
# Parameters  : 无     
# return	  : 无                                      #
#************************************************************#
function eth_a()
{
	eth=`ip link | grep "state UP" | awk '{ print $2 }' | sed 's/://g'|grep -v vir`
	echo $eth
	for i in $eth
	do
		xge=`ethtool $i|grep Speed|cut -d " " -f2|cut -d "M" -f1`
		if [ $xge -eq 1000 ]
		then
			echo $i "It is GE"
			ifconfig -a $i
			ethtools=ethtool -S $i |grep -E "dropped|overruns"	
			PRINT_LOG "INFO" "$i It is GE. The dropped and overruns:$ethtools"
			fn_writeResultFile "${RESULT_FILE}" "$i It is GE" "pass"
                else
                        echo $i " It is not GE"
                        PRINT_LOG "FATAL" "$i It is not GE ."
                        fn_writeResultFile "${RESULT_FILE}" "$i It is not GE" "fail"

		fi
		
	done
}
#************************************************************#
# Name        : eth_b                        #
# Description : 查找不存在的网口                                 #
# Parameters  : 无     
# return	  : 无                                      #
#************************************************************#
function eth_b()
{
	ifconfig xxx
	return 0

}


#预置条件
function init_env()
{
    #检查结果文件是否存在，创建结果文件：
    fn_checkResultFile ${RESULT_FILE}
    
    #root用户执行
    if [ `whoami` != 'root' ]
    then
        PRINT_LOG "WARN" " You must be root user " 
        return 1
    fi

    #自定义测试预置条件检查实现部分：比如工具安装，检查多机互联情况，执行用户身份 
      #需要安装工具，使用公共函数install_deps，用法：install_deps "${pkgs}"
      #需要日志打印，使用公共函数PRINT_LOG，用法：PRINT_LOG "INFO|WARN|FATAL" "xxx"
}

#测试执行
function test_case()
{
	eth_a
	eth_b
    #检查结果文件，根据测试选项结果，有一项为fail则修改test_result值为fail，
    check_result ${RESULT_FILE}
}

#恢复环境
function clean_env()
{
    #清除临时文件
    FUNC_CLEAN_TMP_FILE
    #自定义环境恢复实现部分,工具安装不建议恢复
      #需要日志打印，使用公共函数PRINT_LOG，用法：PRINT_LOG "INFO|WARN|FATAL" "xxx"

}


function main()
{
    init_env || test_result="fail"
    if [ ${test_result} = 'pass' ]
    then
        test_case || test_result="fail"
    fi
    clean_env || test_result="fail"
	[ "${test_result}" = "pass" ] || return 1
}

main $@
ret=$?
#LAVA平台上报结果接口，勿修改
lava-test-case "$test_name" --result ${test_result}
exit ${ret}


