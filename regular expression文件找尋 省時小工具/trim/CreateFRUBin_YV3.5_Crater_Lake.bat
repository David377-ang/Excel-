@ECHO OFF
COLOR E0
SET CREATEFRUBIN_PATH=%~dp0
SET THIS_NAME=%~n0
PATH=%PATH%;%CREATEFRUBIN_PATH%Tool\;%CREATEFRUBIN_PATH%Tool\py\;%CREATEFRUBIN_PATH%Tool\py\SFCSTool\;%CREATEFRUBIN_PATH%Tool\py\WPy64-3771\scripts\;
SET pyAWK=%CREATEFRUBIN_PATH%Tool\py\awk.py

ECHO [This is the pyawk version]
ECHO.
ECHO =============================================
ECHO ========= Create FRU Binary
ECHO =============================================
ECHO.
ECHO.
ECHO ========= Setting Test Parameters
SET FPX=%THIS_NAME%-
SET LOG_DIR=%CREATEFRUBIN_PATH%
SET BASE_BIN=Base_YV3_DeltaLake_FRU.bin

SET STAGE=TA

REM :: FRU Update: USN, UPN, Customer PN, Board Product Name, PCB, MFG Date/Time
SET SFCS_CAT_UPN=35
SET SFCS_SEQ_UPN=1

SET SFCS_CAT_CUSTOMERPN=17
SET SFCS_SEQ_CUSTOMERPN=1

SET SFCS_INFONAME_PCB=HARDWARE
SET SFCS_INFONAME_PRODUCTNAME=FW


:MAIN
ECHO.
ECHO ========= Check Arguments: "%*"

IF (%1) == () (
    ECHO --------- [Error]: At Least Input One Serial Number
	GOTO FAIL
)

SET gNUM=1
:MAIN_LOOP

SET UUT_SN=%1
SET BIN_SN=SN%gNUM%_FRU.bin
SET LOG_SN=%LOG_DIR%SN%gNUM%_FRU_log.txt
ECHO.
ECHO --------- Run Serial %gNUM% [%UUT_SN%]
CALL:RUN_ALL > %LOG_SN%
::CALL:RUN_ALL
IF ERRORLEVEL 1 GOTO FAIL
TYPE %LOG_SN%

SHIFT
set /A gNUM=%gNUM%+1

IF (%1) == () GOTO MAIN_LOOP_BREAK
GOTO MAIN_LOOP
:: EOF for Main

:MAIN_LOOP_BREAK
GOTO TEST_DONE


ECHO =============================================
ECHO ========= Sub Function
ECHO =============================================
:RUN_ALL
ECHO.
ECHO ========= Run All Process [%UUT_SN%]
CALL:QUERY_INFO_FROM_SFCS
IF ERRORLEVEL 1 (
    ECHO [Error] Query SFCS for [%UUT_SN%] Fail
    EXIT /B 1
)
CALL:CREATE_FRU
IF ERRORLEVEL 1 (
    ECHO [Error] Create FRU Binary for [%UUT_SN%] Fail
    EXIT /B 1
)
EXIT /B 0
REM :: EOF for ":RUN_ALL"

:QUERY_INFO_FROM_SFCS
ECHO.
ECHO ========= Query SFCS Information
ECHO --------- Get UPN
CALL:QUERY_SFCS_ACTION "UPN" "Unit P/N:" "GetUSNGenealogyBasic --USN %UUT_SN% --Stage %STAGE%"
IF ERRORLEVEL 1 EXIT /B 1
SET UUT_PN=%g_retval_QUERY_SFCS_ACTION%
SET UUT_PPName=Yosemite V3 PVT
SET UUT_PV=PVT
ECHO Unit Part Number: [%UUT_PN%]
ECHO.

SET test_flag=false


REM 01/22
IF (%UUT_PN%) == (B81.04G10.0236) SET test_flag=true
IF (%test_flag%) == (true) GOTO CHANGE_FRU
REM 5/17
IF NOT (%UUT_PN%) == (B81.04G10.xxxx) SET test_flag=false
IF (%test_flag%) == (false) GOTO EXIT1

:CHANGE_FRU
	
REM IF (%test_flag%) == (true) GOTO QUERY_UPN_FIN
	ECHO --------- It's MP Pilot
    ECHO --------- Re Get UPN
    SET UUT_PPName=Crater Lake PVT
    SET UUT_PV=YoCL035
	
    :QUERY_UPN_FIN
    REM :: End of "Use Once, for mixed build"

ECHO.

REM IF NOT (%UUT_PN%) == (B81.02610.0230) GOTO QUERY_UPN_FIN

    REM :: "Use Once, for mixed build"
REM    ECHO --------- It's MP Pilot
REM    ECHO --------- Re Get UPN    
REM    SET UUT_PPName=Delta Lake MP T8
REM    SET UUT_PV=YoDL03
	
REM    :QUERY_UPN_FIN
    REM :: End of "Use Once, for mixed build"

REM ECHO.

ECHO --------- Get Customer PN
CALL:QUERY_SFCS_ACTION "CustomerPN" "Component S/N:" "GetUSNItem --USN %UUT_SN% --Stage %STAGE% --Category %SFCS_CAT_CUSTOMERPN% --Sequence %SFCS_SEQ_CUSTOMERPN%"
IF ERRORLEVEL 1 EXIT /B 1
SET UUT_CustomerPN=%g_retval_QUERY_SFCS_ACTION%
ECHO Customer PN: [%UUT_CustomerPN%]
ECHO.

ECHO --------- PCB Supplier
REM :: CALL:QUERY_SFCS_DB_ACTION "PCBSupplier" "%UUT_SN%" "SFCPCB.v_pcbrand MBSN %UUT_SN%"
CALL:QUERY_SFCS_ACTION "PCBSupplier" "Board Vendor:" "GetDynamicData_GETUSNBRAND --USN %UUT_SN%"
IF ERRORLEVEL 1 EXIT /B 1
SET UUT_PCB=%g_retval_QUERY_SFCS_ACTION%
ECHO PCB Supplier: [%UUT_PCB%]

SET UUT_PCB_SUPPLIE_TRIPOD=TRIPOD
SET UUT_PCB_SUPPLIE_BOARDTEK=BOARDTEK
SET UUT_PCB_SUPPLIE_WUSHK=WUSHK

IF %UUT_PCB% EQU %UUT_PCB_SUPPLIE_TRIPOD% GOTO PCB_TRIPOD

IF %UUT_PCB% EQU %UUT_PCB_SUPPLIE_BOARDTEK% GOTO PCB_BOARDTEK

IF %UUT_PCB% EQU %UUT_PCB_SUPPLIE_WUSHK% GOTO PCB_WUSHK
GOTO PCB_FINISH

:PCB_TRIPOD
SET UUT_PCB=TRI
GOTO PCB_FINISH

:PCB_BOARDTEK
SET UUT_PCB=BTK

:PCB_WUSHK
SET UUT_PCB=WUS


:PCB_FINISH


ECHO.

REM ECHO --------- Board Product Name
REM CALL:QUERY_SFCS_ACTION "BoardProductName" "InfoValue:" "GetUPNInformation --USN %UUT_SN% --Stage %STAGE% --InfoName %SFCS_INFONAME_PRODUCTNAME%"
REM IF ERRORLEVEL 1 EXIT /B 1
REM SET UUT_BPName=%g_retval_QUERY_SFCS_ACTION%
REM ECHO Board Product Name: [%UUT_BPName%]
REM ECHO.

EXIT /B 0
REM :: EOF for ":QUERY_INFO_FROM_SFCS"

:QUERY_SFCS_ACTION
REM :: User Can Get the Value of the Item
SET g_retval_QUERY_SFCS_ACTION=UNKNOW

SET A_ITEM=%~1
SET A_KEY=%~2
SET A_METHOD=%~3

ECHO --------- [%A_ITEM%]
SET A_VALUE=UNKNOW
SET A_ITEM_LOG=%LOG_DIR%%FPX%SFCS_%A_ITEM%.txt
SET A_TMP_LOG=%LOG_DIR%%FPX%SFCS_%A_ITEM%_tmp.txt
CALL SFCSTool.bat %A_METHOD% > %A_ITEM_LOG%
::IF ERRORLEVEL 1 EXIT /B 1
TYPE %A_ITEM_LOG%
CALL python.bat %pyAWK% -F ":" -p "%A_KEY%" -i "2" -f "%A_ITEM_LOG%" > %A_TMP_LOG%
SET /P A_VALUE=<%A_TMP_LOG%
FOR /F "TOKENS=2 DELIMS=:" %%X IN ('TYPE %A_ITEM_LOG% ^| FIND "%A_KEY%"') DO SET A_VALUE=%%X
IF "%A_VALUE%" == "UNKNOW" EXIT /B 1
IF "%A_VALUE%" == "None" EXIT /B 1
ECHO %A_ITEM%: [%A_VALUE%]
ECHO.
SET g_retval_QUERY_SFCS_ACTION=%A_VALUE%

EXIT /B 0
REM :: EOF for ":QUERY_SFCS_ACTION"

:QUERY_SFCS_DB_ACTION
REM :: User Can Get the Value of the Item
SET g_retval_QUERY_SFCS_ACTION=UNKNOW

SET A_ITEM=%~1
SET A_KEY=%~2
SET A_METHOD=%~3

ECHO --------- [%A_ITEM%]
SET A_VALUE=UNKNOW
SET A_ITEM_LOG=%LOG_DIR%%FPX%SFCS_%A_ITEM%.txt
SET A_TMP_LOG=%LOG_DIR%%FPX%SFCS_%A_ITEM%_tmp.txt
:: CALL QueryOracleDB_getBoardNameByUSN.bat %A_METHOD% > %A_ITEM_LOG%
CALL QueryOracleDB.bat %A_METHOD% > %A_ITEM_LOG%
IF ERRORLEVEL 1 EXIT /B 1
TYPE %A_ITEM_LOG%
CALL python.bat %pyAWK% -F "," -p "%A_KEY%" -i "2" -f "%A_ITEM_LOG%" > %A_TMP_LOG%
SET /P A_VALUE=<%A_TMP_LOG%
IF "%A_VALUE%" == "UNKNOW" EXIT /B 1
IF "%A_VALUE%" == "None" EXIT /B 1
ECHO %A_ITEM%: [%A_VALUE%]
ECHO.
SET g_retval_QUERY_SFCS_ACTION=%A_VALUE%

EXIT /B 0
REM :: EOF for ":QUERY_SFCS_DB_ACTION"

:CREATE_FRU
ECHO.
ECHO ========= Create FRU Binary
ECHO --------- Copy Basic FRU Binary File
SET SRC_FILE=%CREATEFRUBIN_PATH%Tool\%BASE_BIN%
SET TAR_FILE=%CREATEFRUBIN_PATH%%BIN_SN%
ECHO Copy [%SRC_FILE%] [%TAR_FILE%]
COPY %SRC_FILE% %TAR_FILE% /y
IF ERRORLEVEL 1 EXIT /B 1

ECHO --------- Update Board SN
fruTool.exe --dev %TAR_FILE% --BS="%UUT_SN%"
IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1

ECHO --------- Update Board PN
fruTool.exe --dev %TAR_FILE% --BP="%UUT_PN%"
IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1

ECHO --------- Update Board Product Name
fruTool.exe --dev %TAR_FILE% --BPN="Crater Lake"
IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1

ECHO --------- Update Board Manufacturing Date/Time
fruTool.exe --dev %TAR_FILE% --BMT="now"
IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1

ECHO --------- Update Customer PN
fruTool.exe --dev %TAR_FILE% --index=1 --BEX="%UUT_CustomerPN%"
IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1

ECHO --------- Update Product Product Name
fruTool.exe --dev %TAR_FILE% --index=1 --PPN="%UUT_PPName%"
IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1

ECHO --------- Update Product Version
fruTool.exe --dev %TAR_FILE% --index=1 --PV="%UUT_PV%"
IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1

ECHO --------- Update Board PCB Supplier
fruTool.exe --dev %TAR_FILE% --index=2 --BEX="PCB Supplier - %UUT_PCB%"
IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1

ECHO.
ECHO --------- Show FRU
fruTool.exe --dev %TAR_FILE% --show
IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1

EXIT /B 0
REM :: EOF for ":CREATE_FRU"

:TEST_DONE
REM :: Remove Temp Files
REM :: DEL /F /Q %LOG_DIR%\%FPX%*.txt
:EXIT1
IF (%test_flag%) == (false) EQU 0 EXIT /B 1
ECHO "Wrong PartNumber Pls Check FRU_Program"
ECHO "%UUT_PN%"
Exit