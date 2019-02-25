# oracle-tips
Here's multiple Oracle tips and tricks can enhance working with oracle Forms & Database.

## Run Oracle Forms 12c Without Browser
In the URL of forms , add webstart instaed of config name <br />
if your application URL is : http://localhost:9001/forms/frmservlet?config=myapp <br />
then edit it to : http://localhost:9001/forms/frmservlet?config=webstart <br />
this will download exe file in JNLP format, when you double click it, it will lauch your application browserless , no need to any browser yet.

## Browse specific Files in Forms 6i
Under When Button_Pressed add the following code: <BR />
* To Get Excel Path into Field Excel_Path at the MAIN_BLOCK  <BR />
~~~
DECLARE
 V_File_Name varchar2(200); 
BEGIN 
V_File_Name := GET_FILE_NAME(File_Filter=> 'EXE Files (*.exe)|*.exe|'); 
:MAIN_BLOCK.Excel_Path := V_File_Name; 
END;
~~~
## Reading Image Files in Forms 6i
* Add Field of type: IMAGE 
* When_Mouse_Double_Click TRIGGER add the following code:
~~~
DECLARE  
  V_File_Name VARCHAR2(4000); 
BEGIN  
  V_File_Name := GET_FILE_NAME( File_Filter => 'jpg files (*.jpg)|*.jpg|gif files (*.gif)|*.gif|all files (*.*)|*.*|') ;
  :MAIN_BLOCK.Image_Path := V_File_Name ;
  READ_IMAGE_FILE(V_File_Name, 'JPG', 'MAIN_BLOCK.Item_Image') ;
END;
~~~

## Export Oracle Forms to EXCEL File
You can export current form data to Excel file using any of the two following methods :
1. Using DDE PACKAGE
~~~plsql
BEGIN
Appid := DDE.APP_BEGIN('C:\Program Files (x86)\Microsoft Office\Office12\EXCEL.EXE',DDE.APP_MODE_MAXIMIZED);
DDE.APP_FOCUS(APPID);
ConvId := DDE.INITIATE('EXCEL','Sheet1' );
-------------------REPORT HEADER ROW 2----
DDE.POKE(Convid, 'R1C1',BPT_Product_Code  , DDE.CF_TEXT, 10000); 
DDE.POKE(Convid, 'R1C2',BPT_Product_Name  , DDE.CF_TEXT, 10000); 
DDE.POKE(Convid, 'R1C3',BPT_Product_Price , DDE.CF_TEXT, 10000); 
DDE.POKE(Convid, 'R1C4',BPT_Barcode       , DDE.CF_TEXT, 10000); 
------------------------------------------
V_Count := 1;
GO_BLOCK('VINV_SCALE_PRODUCTS');
FIRST_RECORD;
	LOOP
     V_Count:= V_Count+1;
     SYNCHRONIZE;
     ------------------INSERT INTO EXCEL SHEET COLUMNS------------------
     DDE.POKE(Convid, 'R'||V_Count||'C1', NVL(:VINV_SCALE_PRODUCTS.Product_Code , ' ') , DDE.CF_TEXT, 10000);
     DDE.POKE(Convid, 'R'||V_Count||'C2', NVL(:VINV_SCALE_PRODUCTS.Product_Name , ' ') , DDE.CF_TEXT, 10000);
     DDE.POKE(Convid, 'R'||V_Count||'C3', NVL(:VINV_SCALE_PRODUCTS.Product_Price, ' ') , DDE.CF_TEXT, 10000);
     DDE.POKE(Convid, 'R'||V_Count||'C4', NVL(:VINV_SCALE_PRODUCTS.Scale_Barcode, ' ') , DDE.CF_TEXT, 10000);
     -----------#
     EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
     NEXT_RECORD;
     -----------#
	END LOOP;
	------------------------
	DDE.TERMINATE(convid);
  ------------------------
	EXCEPTION 
		WHEN DDE.DDE_APP_FAILURE THEN 
		     MESSAGE('WINDOWS APPLICATION CANNOT START.'); 
    WHEN DDE.DDE_PARAM_ERR THEN 
         MESSAGE('A NULL VALUE WAS PASSED TO DDE'); 
    WHEN DDE.DMLERR_NO_CONV_ESTABLISHED THEN 
         MESSAGE('DDE CANNOT ESTABLISH A CONVERSATION'); 
    WHEN DDE.DMLERR_NOTPROCESSED THEN 
         MESSAGE('A TRANSACTION FAILED');
END;
~~~

2- Using System Parameters
~~~
DECLARE
 Prm_List  PARAMLIST ;
 Full_Path VARCHAR2(100) := NULL;
BEGIN
 Full_Path :=  GET_FILE_NAME ( NULL, NULL, 'All Files(*.*)|*.*|', 'Save report', SAVE_FILE, FALSE); 
 -----------------------------------------
 IF NOT ID_NULL(GET_PARAMETER_LIST('cus'))then
     DESTROY_PARAMETER_LIST('cus');
 END IF ;
     Prm_List := CREATE_PARAMETER_LIST('cus');  
     -----------------------------------------
     -- Adding parameters to the parameter list 
     -----------------------------------------
     ADD_PARAMETER(Prm_List,'P_Login_Lang_Code',TEXT_PARAMETER, :GLOBAL.Login_Lang_Code) ;
     ADD_PARAMETER(Prm_List,'P_Type_Id'        ,TEXT_PARAMETER, :MAIN_BLOCK.Type_Id) ;
     ADD_PARAMETER(Prm_List,'P_Coupon_Id_From' ,TEXT_PARAMETER, LEAST(:MAIN_BLOCK.Start_Id    , :MAIN_BLOCK.End_Id)) ;
     ADD_PARAMETER(Prm_List,'P_Coupon_Id_To'   ,TEXT_PARAMETER, GREATEST(:MAIN_BLOCK.Start_Id , :MAIN_BLOCK.End_Id)) ;
     -----------------------------------------
     -- Setting System Parameters 
     ----------------------------------------- 
     ADD_PARAMETER(Prm_List,'DESTYPE'     , TEXT_PARAMETER, 'FILE');
     ADD_PARAMETER(Prm_List,'DESFORMAT'   , TEXT_PARAMETER, 'DELIMITED');
     ADD_PARAMETER(Prm_List,'DESNAME'     , TEXT_PARAMETER, Full_Path||'.XLS');
      ADD_PARAMETER(Prm_List,'paramform'   , TEXT_PARAMETER, 'NO');
     -----------------------------------------
     RUN_PRODUCT(REPORTS, 'RepFileName', SYNCHRONOUS, RUNTIME, FILESYSTEM, 'cus', NULL);
END;
~~~

## When running Oracle Forms , LOGON DENIED: <br />
- ORA-01017 : invalid username/password ; logon denied
1. CONNECT AS SYS
2. alter system set SEC_CASE_SENSITIVE_LOGON = FALSE;

## Cannot run Forms 6i after installing Patch18: <br />
You need to replace the following twon DLL files in this directory: <br />
C:\orant\BIN
NN60.DLL and NNB60.DLL

Two files are uploaded to this repository 

## Adding Icons to Buttons in Forms 6i: <br />
To make Buttons iconic in forms 6i , you need to add full path of .ico file or image in PROPERTY of BUTTON, <br />
The easiest method is to : <br />
- From windows Start MENU , GOTO RUN
- REGEDIT
- Search for HKEY_LOCAL_MACHINE , SOFTWARE, ORACLE
- in the Right Pane add new STRING VALUE <br />
- - Name: UI_ICON
- - VALUE: C:\Icos;
Now you add just name of icon (query) in BUTTON property
