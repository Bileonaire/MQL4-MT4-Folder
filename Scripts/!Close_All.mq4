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

//+------------------------------------------------------------------+
// Set this parameter to the type of closing you want:
// 1- Close all (instant and pending orders) (Default)
// 2- Close all instant orders
// 3- Close all pending orders
// 4- Close by comment
// 5- Close orders in profit
// 6- Close orders in loss
//+------------------------------------------------------------------+

//external parameters to be provided

enum e_To_Close{
 Close_All=1,
 Instant_Orders=2,
 Pending_Orders = 3,
 Comment = 4,
 All_Profitable = 5,
 All_In_Loss = 6,
};

input e_To_Close  To_Close = Close_All;

extern string comment = "";

string Trade="";

int start() {
   if (To_Close == 1) {
      Close_All();
   }
   if (To_Close == 2) {
      Instant_Orders();
   }
   if (To_Close == 3) {
      Pending_Orders();
   }
   if (To_Close == 4) {
      Comment();
   }
   if (To_Close == 5) {
      All_Profitable();
   }
   if (To_Close == 6) {
      All_In_Loss();
   }
   SendSignal();
   return(0);
}

//+------------------------------------------------------------------+

int Close_All()
{
   int ordertotal = OrdersTotal();

   RefreshRates();

   for (int i=0 ; i <= ordertotal; i++)
   {
      RefreshRates();
      int order = OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()==OP_BUY) {
            int buy = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
            Trade =  StringConcatenate(Trade + " || Trade Closed " + OrderSymbol() + " @ " + MarketInfo(OrderSymbol(),MODE_ASK)  +  " Entered - " +  "( " + OrderOpenPrice() + " )");
         }

         if(OrderType()==OP_SELL) {
            int sell = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
            Trade =  StringConcatenate(Trade + " || Trade Closed " + OrderSymbol() + " @ " + MarketInfo(OrderSymbol(),MODE_ASK)  +  " Entered - " +  "( " + OrderOpenPrice() + " )");
         }

         if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT) {
            int stop = OrderDelete(OrderTicket());
            Trade =  StringConcatenate(Trade + " || Pending Order Closed " + OrderSymbol() + " ( " + OrderOpenPrice() + " )");
         }
   }
return(0);
}

int Instant_Orders()
{
   int ordertotal = OrdersTotal();

   for (int i=ordertotal-1 ; i>=0; i--)
   {
      RefreshRates();
      if( ! OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
      if(OrderType()==OP_BUY)
         int buy = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
      if(OrderType()==OP_SELL)
         int sell = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
      Trade =  StringConcatenate(Trade + " || Trade Closed " + OrderSymbol() + " @ " + MarketInfo(OrderSymbol(),MODE_ASK)  +  " Entered - " +  "( " + OrderOpenPrice() + " )");

   }
return(0);
}

int Pending_Orders()
{
   int ordertotal = OrdersTotal();
   for (int i=ordertotal-1 ; i>=0; i--)
   {
      if( ! OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
      if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
         int stop = OrderDelete(OrderTicket());
      Trade =  StringConcatenate(Trade + " || Pending Order Closed " + OrderSymbol() + " ( " + OrderOpenPrice() + " )");

   }
return(0);
}

int Comment()
{
   int ordertotal = OrdersTotal();

   for (int i=ordertotal-1 ; i>=0; i--)
   {
      RefreshRates();
      if( ! OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
      if(OrderComment()==comment && OrderType()==OP_BUY)
         int buy = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
         Trade =  StringConcatenate(Trade + " || Trade Closed " + OrderSymbol() + " @ " + MarketInfo(OrderSymbol(),MODE_ASK)  +  " Entered - " +  "( " + OrderOpenPrice() + " )");

      if(OrderComment()==comment && OrderType()==OP_SELL)
         int sell = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
         Trade =  StringConcatenate(Trade + " || Trade Closed " + OrderSymbol() + " @ " + MarketInfo(OrderSymbol(),MODE_ASK)  +  " Entered - " +  "( " + OrderOpenPrice() + " )");

      if(OrderComment()==comment && (OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT))
         int stop = OrderDelete(OrderTicket());
         Trade =  StringConcatenate(Trade + " || Pending Order Closed " + OrderSymbol() + " ( " + OrderOpenPrice() + " )");
   }
return(0);
}

int All_Profitable()
{
   int ordertotal = OrdersTotal();

   for (int i=ordertotal-1 ; i>=0; i--)
   {
      RefreshRates();
      if( ! OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
      if (OrderProfit() > 0)
      {
         if(OrderType()==OP_BUY)
            int buy = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
         if(OrderType()==OP_SELL)
            int sell = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
         Trade =  StringConcatenate(Trade + " || Trade Closed " + OrderSymbol() + " @ " + MarketInfo(OrderSymbol(),MODE_ASK)  +  " Entered - " +  "( " + OrderOpenPrice() + " )");
      }
   }
return(0);
}

int All_In_Loss()
{
   int ordertotal = OrdersTotal();

   for (int i=ordertotal-1 ; i>=0; i--)
   {
      RefreshRates();
      if( ! OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) continue;
      if (OrderProfit() < 0)
      {
         if(OrderType()==OP_BUY)
            int buy = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
         if(OrderType()==OP_SELL)
            int sell = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
         Trade =  StringConcatenate(Trade + " || Trade Closed " + OrderSymbol() + " @ " + MarketInfo(OrderSymbol(),MODE_ASK)  +  " Entered - " +  "( " + OrderOpenPrice() + " )");
      }
   }
return(0);
}


int SendSignal() {
//----
   string cookie=NULL,headers;
   char post[],result[];

   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection
//--- to enable access to the server, you should add URL "https://www.google.com/finance"
//--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"):
   string certitude_fx_free=StringConcatenate("https://api.telegram.org/bot1006615027:AAHGxcvNkET_rMwfcj3ZQ0Zibg1ACGAtFDY/sendMessage?chat_id=-1001334648463&text="+Trade+"&parse_mode=html");
//--- Reset the last error code
   ResetLastError();
//--- Loading a html page from Google Finance
   int free=WebRequest("POST",certitude_fx_free,cookie,NULL,timeout,post,0,result,headers);
return(0);
}