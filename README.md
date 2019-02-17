# oracle-tips
Here's multiple Oracle tips and tricks can enhance working with oracle Forms & Database.

## Run Oracle Forms 12c Without Browser
In the URL of forms , add webstart instaed of config name <br />
if your application URL is : http://localhost:9001/forms/frmservlet?config=myapp <br />
then edit it to : http://localhost:9001/forms/frmservlet?config=webstart <br />
this will download exe file in JNLP format, when you double click it, it will lauch your application browserless , no need to any browser yet.
