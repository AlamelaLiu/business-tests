#!/bin/bash

#*****************************************************************************************
# *用例名称：Suse_Relevant_007                                                         
# *用例功能: 防火墙打开/关闭功能                                                  
# *作者：mwx547872                                                                       
# *完成时间：2019-2-21                                                                   
# *前置条件：                                                                            
#   1、预装linux操作系统                                                                   
# *测试步骤：                                                                               
#   1、 进入linux操作系统。         
#   2.  执行防火墙打开/关闭功能        
# *测试结果：                                                                            
#  防火墙可以正常关闭/打开                                                         
#*****************************************************************************************
set -x
#加载公共函数
. ../../../utils/test_case_common.inc
. ../../../utils/error_code.inc
. ../../../utils/sys_info.sh
. ../../../utils/sh-test-lib		

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
        if [ `whoami` != 'root' ]; then
            echo "You must be the superuser to run this script" > $2
            exit 1
        fi
}

#测试执行
function test_case()
{
	check_result ${RESULT_FILE}
        fn_get_os_type distro_type
        case $distro_type in
           "ubuntu" | "debian" )
             apt-get install ufw -y
              ufw enable
              ufw status|grep "active"
               if [ $? -eq 0 ]
               then
                 fn_writeResultFile "${RESULT_FILE}" "ufw-enable" "pass"
                 PRINT_LOG "INFO" "ufw enable is success"
              else
                 fn_writeResultFile "${RESULT_FILE}" "ufw-enable" "fail"
                 PRINT_LOG "INFO" "ufw enable is fail"
              fi
          ;;
          
         
           "centos" | "redhat" )
            systemctl start firewalld.service
            systemctl status firewalld.service|grep "running"
            if [ $? -eq 0 ]
            then
               fn_writeResultFile "${RESULT_FILE}" "start-firewalld" "pass"
          
               PRINT_LOG "INFO" "start firewalld  is success"

          else
         
              fn_writeResultFile "${RESULT_FILE}" "start-firewalld" "fail"
              PRINT_LOG "INFO" "start firewalld  is fail"

          fi
          ;;

          "suse")
           systemctl start firewalld 
           systemctl status firewalld|grep "running"
           if [ $? -eq 0 ]

           then

               fn_writeResultFile "${RESULT_FILE}" "start-firewalld" "pass"

               PRINT_LOG "INFO" "start firewalld  is success"


          else

               fn_writeResultFile "${RESULT_FILE}" "start-firewalld" "fail"

               PRINT_LOG "INFO" "start firewalld"

           fi
           ;;

         esac
         check_result ${RESULT_FILE}
           
       

}
function clean_env()
{
       FUNC_CLEAN_TMP_FILE
     	case $distro_type in
       "ubuntu"|"debian")
          ufw disable
          ufw status|grep "inactive"
           if [ $? -eq 0 ]
               then
                 fn_writeResultFile "${RESULT_FILE}" "ufw-disable" "pass"
                 PRINT_LOG "INFO" "ufw disable is success"
              else
                 fn_writeResultFile "${RESULT_FILE}" "ufw-disable" "fail"
                 PRINT_LOG "INFO" "ufw disable is fail"
              fi
        ;;
       "centos"|"redhat")
          systemctl stop firewalld.service
          systemctl status firewalld.service |grep "dead"
          if [ $? -eq 0 ]
            then
               fn_writeResultFile "${RESULT_FILE}" "stop-firewalld" "pass"

               PRINT_LOG "INFO" "stop firewalld  is success"

          else

              fn_writeResultFile "${RESULT_FILE}" "stop-firewalld" "fail"
              PRINT_LOG "INFO" "stop firewalld  is fail"

          fi

          
        ;;
      "suse")
           systemctl stop firewalld 
           systemctl status firewalld|grep "dead"
           if [ $? -eq 0 ]

           then

               fn_writeResultFile "${RESULT_FILE}" "stop-firewalld" "pass"

               PRINT_LOG "INFO" "stop firewalld  is success"


          else

               fn_writeResultFile "${RESULT_FILE}" "stop-firewalld" "fail"

               PRINT_LOG "INFO" "stop firewalld"

           fi

       ;;
    esac

}

function main()
{
	init_env|| test_result="fail"
        if [ ${test_result} = "pass" ]
        then
              
        test_case || test_result="fail"
       fi
        clean_env || test_result="fail"
        [ "${test_result}" = "pass" ] || return 1
	
}

main 
ret=$?
#LAVA平台上报结果接口，勿修改
lava-test-case "$test_name" --result ${test_result}
exit ${ret}
