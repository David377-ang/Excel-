@echo off

cls

SET A_TMP_LOG=tmp.txt

IF NOT EXIST %A_TMP_LOG% (

rem 創建txt
echo create %A_TMP_LOG%
copy nul %A_TMP_LOG%

) ELSE (

rem 清空txt 內容
echo clear %A_TMP_LOG%
powershell.exe -ExecutionPolicy Bypass -Command "Clear-Content %A_TMP_LOG%"

)
::SET B_line=WOW
::echo %B_line% > %A_TMP_LOG%


rem 顯示批次檔存在的目錄中所有符合.mp4 .avi *.mpg的檔案名稱
rem for %%i in (*.mp4 *.avi *.mpg) DO @echo %%i
rem for %%i in (*.csv) DO @echo %%i

rem 找尋部分檔名符合的file
rem set Str_User_part="*.txt"
rem set Str_User_Key="*WL*"
rem for %%i in (%Str_User_part%) DO echo %%i


rem 找出 "wytn_20220720221727_WL8322800CJN01.txt" 含有 "@A-JUM" 字串,並寫入tmp.txt
rem SET A_read_LOG=wytn_20220720221727_WL8322800CJN01.txt
rem SET A_key=@A-JUM
rem FOR /F %%X IN ('FINDSTR %A_key% %A_read_LOG%') DO ( 
rem echo %%X > %A_TMP_LOG%
rem echo %%X
rem )

::set Str_User_part="wytn*.txt"
set Str_User_part="wytn_20220720221727_WL8322800CJN01.txt"

::SET A_key=@A-JUM
SET A_key="{@A-JUM.*P12V_FAN0"
FOR %%i IN (%Str_User_part%) DO (

	FOR /F %%X IN ('FINDSTR %A_key% %%i') DO ( 
	
	
	echo %%X >> %A_TMP_LOG%
	echo %%X
	)
	
echo %%i
)


rem 列出只用兩個字元作為檔名的文字檔案
rem for %%i in (??.txt) do echo "%%i"


rem FOR /R – 列舉目前目錄下的全部子目錄名所有檔案
rem FOR /R %%i IN (*) DO echo %%i


rem FOR /D – 列舉目前目錄下的子目錄名
rem FOR /D %i IN (*) DO echo %i


rem ------------------------------------------------------
rem 如果把字符串當作蛋糕，Delims像刀子，用來切蛋糕，tokens像叉子，用來取切好的蛋糕。
rem 第一個變數為%i並設並tokens=1-3，則後面將得到的變數為%%i、%%j、%%k
rem Set a=aaa_bbb_111-222-333
rem For /F "tokens=1-3 delims=_" %%i in ("%a%") do echo %%i  %%j  %%k

rem 第一個變數為%i並設並tokens=2,3，則後面將得到的變數為%%i、%%j
rem Set a=aaa_bbb_111-222-333
rem For /F "tokens=2,3 delims=_" %%i in ("%a%") do echo %%i  %%j
rem ------------------------------------------------------



:EOF
pause







