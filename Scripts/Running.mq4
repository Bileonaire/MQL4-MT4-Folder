//+------------------------------------------------------------------+
//|                                             Instant_Execution.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2020, Bileonaire."
//version 01/JUNE/2020

//show input parameter
#property show_inputs

#include <json.mqh>
#include <stderror.mqh>
#include <stdlib.mqh>

int start() {
   Running();
}

int Running() {
//----
   string cookie=NULL,headers;
   char post[],result[];
   int res;
   int size;
//--- to enable access to the server, you should add URL "https://www.google.com/finance"
//--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"):
   string google_url="https://api.coindesk.com/v1/bpi/currentprice.json";
//--- Reset the last error code
   ResetLastError();
//--- Loading a html page from Google Finance
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);

   size=ArraySize(result);
   // string resultString=NULL;
   // resultString = CharArrayToString(result);
   JSONParser *parser = new JSONParser();

   JSONValue *jv = parser.parse(result);

   JSONObject *jo = jv;
   JSONArray  *jd =  jo.getArray("result");
   string leon = jd.getObject(0).getString("time");

//jd json array now contains the members of the array , which is one object, so you can access the members of this
// object as follows

//--- Checking errors
   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      MessageBox("Add the address '"+google_url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
        if (size != 0) {
           int ticket = OrderSend(Symbol(), OP_SELL, 0.01, Ask, 3, 0.000, 0.000, "comment", 22, 0, CLR_NONE);
           MessageBox(leon);
           }
     }
//----
return(0);
}