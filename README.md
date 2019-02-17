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
DECLARE <BR />
 V_File_Name varchar2(200); <BR />
BEGIN <BR />
V_File_Name := GET_FILE_NAME(File_Filter=> 'EXE Files (*.exe)|*.exe|'); <BR />
:MAIN_BLOCK.Excel_Path := V_File_Name; <BR />
END; <BR />

## Reading Image Files in Forms 6i
* Add Field of type: IMAGE 
* When_Mouse_Double_Click TRIGGER add the following code: <BR />
   DECLARE  <BR />
  V_File_Name VARCHAR2(4000);  <BR />
BEGIN  <BR />
  V_File_Name := GET_FILE_NAME( File_Filter => 'jpg files (*.jpg)|*.jpg|gif files (*.gif)|*.gif|all files (*.*)|*.*|') ; <BR />
  :MAIN_BLOCK.Image_Path := V_File_Name ; <BR />
  READ_IMAGE_FILE(V_File_Name, 'JPG', 'MAIN_BLOCK.Item_Image') ; <BR />
END;  <BR />

