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
 Check : http://kashif11071973.blogspot.com/2017/01/dde-poke.html
 and
 https://www.experts-exchange.com/questions/20980703/DDE-in-Oracle-forms.html
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

## Create Dynamic List Item
1. connect to hr/hr@orcl
2. add DPARTMENTS to a new block
3. create new Record Group named : DEPT_RG  <br />
and write the following Query : 
~~~
SELECT Department_name,TO_CHAR(Department_ID) 
FROM Departments
~~~
4. Create trigger WHEN_NEW_FORM_INSTANCE <br />
and  write the following Query:
 ~~~
 Declare
 n number;
 BEGIN
 n:=populate_group('DEPT_RG');
 populate_list('DEPARTMENT_ID' , 'DEPT_RG');
 END;
~~~
5. go to DEPARTMENT_ID item property Palette , and change the following attributes:<br />
 Item Type: List Item <br />
 Elements in List : clear any data <br />

6. Run form , you're done...

## Handling Errors Messages in Oracle Forms
When running Oracle Forms, You may get errors because of CODE or User-related errors <br />
So Here's a simple trick to handle such these errors:
1. Create ERROR_MESSAGES table
~~~
create table ERROR_MESSAGES (
    MSG_Code                       varchar2(15),
    MSG_Type                       varchar2(15),
    MSG_Desc                       varchar2(200)
) ;
~~~
2. Insert The following Data:
~~~
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40401, '1', 'No changes currently made to be saved.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40202, '1', 'This field must be entered, navigation not allowed.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40301, '1', 'No records retrieved.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40400, '1', 'Data is successfully saved.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40600, '1', ' This record is already exist');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40508, '1', ' unable to insert record.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50000, '1',' Attention pls. your characters inputs exceeded the allowed limits.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50001, '1',' Acceptable characters are a-z, A-Z, and space.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50002, '1', 'Months must be between 1 and 12');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50003, '1', 'Year must be in proper range.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50004, '1', 'The Day must be between 1 and last day of the month');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50025, '1', 'Attention pls. your date or time must be in the proper format. ');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50026, '1', ' pls. re-enter the date in the requested format. ');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50006, '1',' Legal characters are 0-9 + and -.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
 VALUES (50007, '1',' Attention pls. too many digits after the decimal point.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50009, '1',' Attention pls. too many decimal points.');  
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (50016, '1', 'Accepts Numbers Only');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40100, '1', ' The First Record');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (41830, '1', ' No LOV Entries.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (41049, '1', 'Delete Is Not Allowed');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40509, '1', 'Update Is Not Allowed');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (41051, '1', 'Insert Is Not Allowed');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40360, '1', 'Query Is Not Allowed');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40510, '1', 'This Record Related to Other Data');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40102, '1', 'Record Must Be Inserted or Deleted');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (41003, '1', 'Query Is Not Allowed.');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40212, '1', 'Incorrect Value Inserted');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40352, '1', 'Last Record');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40350, '1', 'No Data Retrieved');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40200, '1', 'Protected Against Update');
INSERT INTO ERROR_MESSAGES (MSG_CODE, MSG_TYPE, MSG_DESC)
VALUES (40353, '1', ' Query Cancelled');
COMMIT;
~~~
3. In the Oracle Forms, Create ON-ERROR TRIGGER:
~~~
DECLARE
    V_MSG_Code             VARCHAR2(15) := ERROR_CODE;
    V_MSG_Type             VARCHAR2(15) := ERROR_TYPE;
    V_MSG_Text             VARCHAR2(200):= ERROR_TEXT;
    V_Msg_Desc             VARCHAR2(200);
BEGIN
	---------------
	SELECT Msg_DESC
	INTO   V_Msg_Desc
	FROM   ERROR_MESSAGES
	WHERE  Msg_Code = V_MSG_Code;
	---------------
	MESSAGE(V_Msg_Desc);
	MESSAGE(V_Msg_Desc);
	---------------
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	MESSAGE (V_MSG_Text);
	MESSAGE (V_MSG_Text);
END;
~~~
4. You are done. thanks to https://oracledevelopertrainingtasks.blogspot.com/2016/06/oracle-forms-errors-english-in-thename.html

 ## How to combine TABLES with a composite key?
1.  Say we have TABLE_A and TABLE_B
2. TABLE_A  has the composite key (A_Id, A_Name, A_Code) refers columns (B_Id, B_Name, B_Code) in TABLE_B
3. When combine two tables we use this query:
~~~
SELECT *
FROM   TABLE_A , TABLE_B
WHERE  TABLE_A.A_Id = TABLE_B.B_Id
AND    TABLE_A.A_Name = TABLE_B_B_Name
AND    TABLE_A.A_Code = TABLE_B.B_Code
~~~
4. But the correct way is :
~~~
SELECT *
FROM   TABLE_A , TABLE_B
WHERE  (A_Id, A_Name, A_Code) = ((B_Id, B_Name, B_Code))
~~~
## How to Automatically Execute query when TAB pages changes?
1. Create Tab Canvas (ACCPETANCE_TAB_CANVAS)
2. Add two Tab Pages (Accept_1, Accep_2)
3. Add two Data Blocks (Accept_1_Block, Accept_2_Block)
4. Add WHEN_TAB_PAGE_CHANGED trigger (FORM_LEVEL) ,and add the following code:
~~~
DECLARE
  V_Tab_Page     VARCHAR2( 30 ):=:SYSTEM.TAB_NEW_PAGE ;
  V_Msg_Level    NUMBER := :SYSTEM.MESSAGE_LEVEL;
BEGIN
 --------------
 :SYSTEM.MESSAGE_LEVEL:= 10;
 COMMIT_FORM;
 :SYSTEM.MESSAGE_LEVEL := V_Msg_Level;
 --------------
 IF V_Tab_Page ='Accept_1' THEN
    GO_BLOCK('Accept_1_Block');
 ELSIF V_Tab_Page ='R__ACCEPTANCE' THEN
	  GO_BLOCK('Accept_2_Block');
    CLEAR_BLOCK(NO_VALIDATE);
    EXECUTE_QUERY;
 END IF;
 --------------
END;
~~~
## How to fix ORACLE REPORTS REP-1401 fatal pl/sql error occurred ?
* make sure the field size is the compatible with the DataBase column size
