//+------------------------------------------------------------------+
//|                                             Close_All.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2020, Lenny M Kioko."
#property link      "https://lennykioko.github.io/"

//version 1.0

//show input parameter
#property show_inputs

#include <stderror.mqh>
#include <stdlib.mqh>

extern string From = "2020.2.27 00:00";
extern string To = "2020.2.29 23:00";

datetime From_m;
datetime To_o;

string   Trade="";
//+------------------------------------------------------------------+
//| Custom initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   if (From == "") From_m = TimeCurrent();
   else {
       From_m = StrToTime(From);
   }


   if (To == "") To_o = TimeCurrent();
   else {
       To_o = StrToTime(To);
   }
   return(0);
}



int start() {
    History();
   //  SendHistory();
    return(0);
}



int History()
{
   int vip;
   string cookie=NULL,headers;
   string url=StringConcatenate("http://127.0.0.1:3000/api/quotes");
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection

   int ordertotal = OrdersHistoryTotal();

   char post[]=[ordertotal],result[];
//    datetime start=StrToTime("2003.8.12");
//    datetime end = StrToTime("17:35")
   ResetLastError();
   vip=WebRequest("POST",url,cookie,NULL,timeout,post,0,result,headers);
return(0);
}

//+------------------------------------------------------------------+

// int History()
// {
//    int ordertotal = OrdersHistoryTotal();

// //    datetime start=StrToTime("2003.8.12");
// //    datetime end = StrToTime("17:35")

//    for (int i=0 ; i <= ordertotal; i++)
//    {
//        int order = OrderSelect(0,SELECT_BY_POS,MODE_HISTORY);
//        if(OrderCloseTime() > From_m && OrderCloseTime() < To_o) {
//             Trade = StringConcatenate(Trade + OrderSymbol());
//         }
//    }
// return(0);
// }


// int SendHistory() {
// //----
//    string cookie=NULL,headers;
//    char post[],result[];
//    int res;
//    int vip;
//    int free;
// //--- to enable access to the server, you should add URL "https://www.google.com/finance"
// //--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"):
//    // string fx_mastermind_url=StringConcatenate("https://api.telegram.org/bot1006615027:AAHGxcvNkET_rMwfcj3ZQ0Zibg1ACGAtFDY/sendMessage?chat_id=-377472799&text="+Trade+"&parse_mode=html");
// //--- Reset the last error code
//    ResetLastError();
// //--- Loading a html page from Google Finance
//    int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection
//    res=WebRequest("POST",fx_mastermind_url,cookie,NULL,timeout,post,0,result,headers);

//    ResetLastError();
//    string certitude_fx_vip=StringConcatenate("https://api.telegram.org/bot1006615027:AAHGxcvNkET_rMwfcj3ZQ0Zibg1ACGAtFDY/sendMessage?chat_id=-438987211&text="+Trade+"&parse_mode=html");
//    vip=WebRequest("POST",certitude_fx_vip,cookie,NULL,timeout,post,0,result,headers);

//    ResetLastError();
//    string certitude_fx_vip=StringConcatenate("https://api.telegram.org/bot1006615027:AAHGxcvNkET_rMwfcj3ZQ0Zibg1ACGAtFDY/sendMessage?chat_id=-1001437413038&text="+Trade+"&parse_mode=html");
//    free=WebRequest("POST",certitude_fx_vip,cookie,NULL,timeout,post,0,result,headers);
// return(0);
// }




//  // retrieving info from trade history
//   int i,hstTotal=OrdersHistoryTotal();
//   for(i=0;i<hstTotal;i++)
//     {
//      //---- check selection result
//      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
//        {
//         Print("Access to history failed with error (",GetLastError(),")");
//         break;
//        }
//      // some work with order
//     }

//    int closed_orders=0;
//    datetime today_midnight=TimeCurrent()-(TimeCurrent()%(PERIOD_D1*60));
//    for(int x=OrdersHistoryTotal()-1; x>=0; x--)
//      {
//       if(OrderSelect(x,SELECT_BY_POS,MODE_HISTORY) && OrderCloseTime()>=today_midnight)
//          closed_orders++;
//      }