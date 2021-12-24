//+------------------------------------------------------------------+
//|                                                 Modify SL TP.mq4 |
//|                                 Copyright © 2020, FX Masterminds |
//|                                   https://lennykioko.github.io/" |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2020, FX Masterminds."
#property link      "https://lennykioko.github.io/"
//version 01/JUNE/2020

//show input parameter
#property show_inputs


enum e_type{
 pips=1,
 price=2,
 Profitable_SL=3,
};

input e_type  type = pips;

extern double sl = 0;
extern double tp = 0;
extern string comment = "";

double stoploss;
double takeprofit;

double Poin;

string Trade="";
string Symbol;


//+------------------------------------------------------------------+
//| Custom initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   if (Point == 0.00001) Poin = 0.0001;
   else {
      if (Point == 0.001) Poin = 0.01;
      else {
         if (Point == 0.01) Poin = 0.1;
         else {
            if (Point == 0.1) Poin = 1;
            else Poin = 0;
         }
      }
   }
   return(0);
}

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

int start() {
   if (type == 1) {
      ModifyPips();
   }
   if (type == 2) {
      ModifyPrice();
   }
   if (type == 3) {
      ProfitableSL();
   }
   SendSignal();
   return(0);
}

int ModifyPips() {
//----
   int ordertotal = OrdersTotal();
   for (int i=0; i<ordertotal; i++)
   {
      int order = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol())
         if (OrderComment() == comment && (OrderType()==OP_BUY || OrderType()==OP_BUYSTOP))
         {
            Symbol = OrderSymbol();
            if (sl==0.0) stoploss = 0.0;
            else stoploss = OrderOpenPrice()-sl*Poin;

            if (tp==0.0) takeprofit = 0.0;
            else takeprofit = OrderOpenPrice()+tp*Poin;

            int ticket = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss, takeprofit, 0);
         }

         if (OrderComment() == comment && (OrderType()==OP_SELL || OrderType()==OP_SELLSTOP))
         {
            Symbol = OrderSymbol();
            if (sl==0.0) stoploss = 0.0;
            else stoploss = OrderOpenPrice()+sl*Poin;

            if (tp==0.0) takeprofit = 0.0;
            else takeprofit = OrderOpenPrice()-tp*Poin;

            int ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss, takeprofit, 0);
         }
      }
//----
return(0);
}


int ModifyPrice() {
//----
   int ordertotal = OrdersTotal();
   for (int i=0; i<ordertotal; i++)
   {
      int order = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol())
         if (OrderComment() == comment)
         {
            stoploss = sl;
            takeprofit = tp;
            Symbol = OrderSymbol();
            int ticket3 = OrderModify(OrderTicket(), OrderOpenPrice(), sl, tp, 0);
         }
      }
//----
return(0);
}
//+------------------------------------------------------------------+

int ProfitableSL() {
//----
   int ordertotal = OrdersTotal();
   for (int i=0; i<ordertotal; i++)
   {
      int order = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol())
         if (OrderComment() == comment && (OrderType()==OP_BUY || OrderType()==OP_BUYSTOP))
         {
            if (sl==0.0) stoploss = 0.0;
            else {
               stoploss = OrderOpenPrice()+sl*Poin;
               takeprofit = OrderTakeProfit();
               Symbol = OrderSymbol();
            }

            int ticket = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss,  takeprofit, 0);
         }

         if (OrderComment() == comment && (OrderType()==OP_SELL || OrderType()==OP_SELLSTOP))
         {
            if (sl==0.0) stoploss = 0.0;
            else {
               stoploss = OrderOpenPrice()-sl*Poin;
               takeprofit = OrderTakeProfit();
               Symbol = OrderSymbol();
            }

            int ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss,  takeprofit, 0);
         }
      }
//----
return(0);
}

int SendSignal() {
//----
   string cookie=NULL,headers;
   char post[],result[];

   Trade =  StringConcatenate("Trade Modified " + Symbol + "  |  " +  "SL <b> " + stoploss +  "</b>  |  TP <b> " + takeprofit + "</b>");

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
