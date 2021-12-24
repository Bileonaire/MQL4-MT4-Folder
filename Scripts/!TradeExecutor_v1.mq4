//+------------------------------------------------------------------+
//|                                             Instant_Execution.mq4|
//+------------------------------------------------------------------+
#property copyright "Copyright � 2020, Bileonaire"
//version 10/JUNE/2020

//show input parameter
#property show_inputs

#include <stderror.mqh>
#include <stdlib.mqh>

//external parameters to be provided

enum e_orderType{
 Buy=1,
 Sell=2,
 BuyStop = 3,
 SellStop = 4,
 BuyLimit = 6,
 SellLimit = 5,
};

input e_orderType  orderType = Buy;

extern double Account = 11.11;
extern double Percentage_Risk = 100;

extern double  totalLot = 0.0;

enum e_print_lot{
 ndio=1,
 la=0,
};

input e_print_lot  print_lot = ndio;

extern int numOfOrders = 1;
extern string comment = "";


extern double PendingOrderPrice = 0.00;
double PendingOrderPips = 0.00;

enum e_Sl_Tp_Type{
 Pips=1,
 Price=2
};

input e_Sl_Tp_Type  Sl_Tp_Type = Price;

enum e_Set_SL{
 Yes=1,
 No=2,
};

input e_Set_SL Set_SL = Yes;

extern double sl = 0.0;
extern double tp = 0.0;

enum e_execute_trade{
 Yess=1,
 Noo=0,
};

input e_execute_trade execute_trade = Yess;

//Send signal to telegram
enum e_send_signal{
 Yeah=1,
 Nah=0,
};

input e_send_signal send_signal = Yeah;

extern string consider= "Hey!!! I am considering this setup --- ";
extern double ratio = 3.0;
extern string link = "";
string chatId = "-1001278337047";
string chatId2 = "-1001237306634";  // bileonaire_fx_community
string chatId3 = "-1001366966111";  // bileonaire_fx -- Small group with Tom

string chatId4 = "-1001662752776"; // Leon Private group

//+------------------------------------------------------------------+

double lot;

double stoploss;
double takeprofit;

double stoploss_Price = 0.0;
double takeprofit_Price = 0.0;

double Poin;

int ticketNum;
double commission;
double lotSize;
bool success = false;

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

   if (Sl_Tp_Type==Price) {
      CalculatePips();
   }

   if (totalLot==0.00) {
      if (Account==0.00) Account = AccountBalance();
      double Risk = (Account*Percentage_Risk*0.01 / sl) / ((MarketInfo(Symbol(), MODE_TICKVALUE))*10);
      Risk = NormalizeDouble(Risk,2);

      lot = Risk / numOfOrders;
    } else lot = totalLot / numOfOrders;

   if (comment=="") comment = StringConcatenate(Symbol() + MarketInfo(0,MODE_ASK));
   if (print_lot) MessageBox(lot);
   return(0);
}
//+------------------------------------------------------------------+
//                                                                   +
//+------------------------------------------------------------------+

int start() {
   if (orderType == 1) {
      ExecuteBuy();
   }
   if (orderType == 2) {
      ExecuteSell();
   }
   if (orderType == 3) {
      if ((PendingOrderPips != 0.00) && (Sl_Tp_Type == Pips)) PendingBuyPips();
      else PendingBuyPrice();
   }
   if (orderType == 4) {
      if ((PendingOrderPips != 0.00) && (Sl_Tp_Type == Pips)) PendingSellPips();
      else PendingSellPrice();
   }

   if (orderType == 5) {
      SellLimitPrice();
   }
   if (orderType == 6) {
      BuyLimitPrice();
   }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

   if (Sl_Tp_Type == 1) {
      ModifyPips();
   }
   if (Sl_Tp_Type == 2) {
      ModifyPrice();
   }
   // SendSignal();
   if (success) SendJournal();
   return(0);
}


int ExecuteBuy() {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   while( numOfOrders > 0) {
       int ticket = OrderSend(Symbol(), OP_BUY, lot, Ask, 3, 0.000, 0.000, comment, 11, 0, CLR_NONE);
       numOfOrders-=1;
   }
   if (ticket != numOfOrders) {
      int error = GetLastError();
      Print("Error = ", ErrorDescription(error));
      return ticket - numOfOrders;
   }
//----
   OrderPrint();
   return(0);
}

int ExecuteSell() {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   while( numOfOrders > 0) {
       int ticket = OrderSend(Symbol(), OP_SELL, lot, Ask, 3, 0.000, 0.000, comment, 22, 0, CLR_NONE);
       numOfOrders-=1;
   }
   if (ticket != numOfOrders) {
      int error = GetLastError();
      Print("Error = ", ErrorDescription(error));
      return ticket - numOfOrders;
   }
//----
   OrderPrint();
   return(0);
}

int PendingBuyPrice() {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   while( numOfOrders > 0) {
       int ticket = OrderSend(Symbol(), OP_BUYSTOP, lot, PendingOrderPrice, 3, 0.000, 0.000, comment, 55, 0, CLR_NONE);
       numOfOrders-=1;
   }
   if (ticket != numOfOrders) {
      int error = GetLastError();
      Print("Error = ", ErrorDescription(error));
      return ticket - numOfOrders;
   }

//----
   OrderPrint();
   return(0);
}


int PendingBuyPips() {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   while( numOfOrders > 0) {
       int ticket = OrderSend(Symbol(), OP_BUYSTOP, lot, Ask+PendingOrderPips*Poin, 3, 0.000, 0.000, comment, 55, 0, CLR_NONE);
       numOfOrders-=1;
   }
   if (ticket != numOfOrders) {
      int error = GetLastError();
      Print("Error = ", ErrorDescription(error));
      return ticket - numOfOrders;
   }

//----
   OrderPrint();
   return(0);
}

int PendingSellPrice() {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   while( numOfOrders > 0) {
       int ticket = OrderSend(Symbol(), OP_SELLSTOP, lot, PendingOrderPrice, 3, 0.000, 0.000, comment, 66, 0, CLR_NONE);
       numOfOrders-=1;
   }
   if (ticket != numOfOrders) {
      int error = GetLastError();
      Print("Error = ", ErrorDescription(error));
      return ticket - numOfOrders;
   }

//----
   OrderPrint();
   return(0);
}


int PendingSellPips() {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   while( numOfOrders > 0) {
       int ticket = OrderSend(Symbol(), OP_SELLSTOP, lot, Bid-PendingOrderPips*Poin, 3, 0.000, 0.000, comment, 66, 0, CLR_NONE);
       numOfOrders-=1;
   }
   if (ticket != numOfOrders) {
      int error = GetLastError();
      Print("Error = ", ErrorDescription(error));
      return ticket - numOfOrders;
   }

//----
   OrderPrint();
   return(0);
}

int SellLimitPrice() {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   while( numOfOrders > 0) {
       int ticket = OrderSend(Symbol(), OP_SELLLIMIT, lot, PendingOrderPrice, 3, 0.000, 0.000, comment, 66, 0, CLR_NONE);
       numOfOrders-=1;
   }
   if (ticket != numOfOrders) {
      int error = GetLastError();
      Print("Error = ", ErrorDescription(error));
      return ticket - numOfOrders;
   }

//----
   OrderPrint();
   return(0);
}

int BuyLimitPrice() {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   while( numOfOrders > 0) {
       int ticket = OrderSend(Symbol(), OP_BUYLIMIT, lot, PendingOrderPrice, 3, 0.000, 0.000, comment, 66, 0, CLR_NONE);
       numOfOrders-=1;
   }
   if (ticket != numOfOrders) {
      int error = GetLastError();
      Print("Error = ", ErrorDescription(error));
      return ticket - numOfOrders;
   }

//----
   OrderPrint();
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
            if (sl==0.0 || Set_SL == 2) stoploss_Price = 0.0;
            else stoploss_Price = OrderOpenPrice()-sl*Poin;

            if (tp==0.0) takeprofit_Price = 0.0;
            else takeprofit_Price = OrderOpenPrice()+tp*Poin;


            int ticket = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss_Price, takeprofit_Price, 0);
            //trade details
            ticketNum = OrderTicket();
            commission = OrderCommission();
            lotSize = OrderLots();
            success = true;
         }

         if (OrderComment() == comment && (OrderType()==OP_SELL || OrderType()==OP_SELLSTOP))
         {
            if (sl==0.0 || Set_SL == 2) stoploss_Price = 0.0;
            else stoploss_Price = OrderOpenPrice()+sl*Poin;

            if (tp==0.0) takeprofit_Price = 0.0;
            else takeprofit_Price = OrderOpenPrice()-tp*Poin;

            int ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss_Price, takeprofit_Price, 0);
            //trade details
            ticketNum = OrderTicket();
            commission = OrderCommission();
            lotSize = OrderLots();
            success = true;
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
            ticketNum = OrderTicket();
            int ticket3 = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss_Price, takeprofit_Price, 0);

            //trade details
            ticketNum = OrderTicket();
            commission = OrderCommission();
            lotSize = OrderLots();
            success = true;
         }
      }
//----
return(0);
}

int CalculatePips() {
   RefreshRates();
   takeprofit_Price = tp;
   stoploss_Price = sl;
//---
   if (orderType==Buy)
   {
      if (sl!=0.0) sl = (MarketInfo(0,MODE_ASK)-sl)/Poin;

      if (tp!=0.0) tp = (tp-MarketInfo(0,MODE_ASK))/Poin;
   }

   if (orderType==BuyStop || orderType==BuyLimit) {
      if (PendingOrderPrice==0.00) {
         PendingOrderPrice = MarketInfo(0,MODE_ASK)+(PendingOrderPips*Poin);
         if (sl!=0.0) sl = (PendingOrderPrice-sl)/Poin;

         if (tp!=0.0) tp = (tp-PendingOrderPrice)/Poin;
      } else {
         if (sl!=0.0) sl = (PendingOrderPrice-sl)/Poin;

         if (tp!=0.0) tp = (tp-PendingOrderPrice)/Poin;
      }
   }

   if (orderType==Sell)
   {
      if (sl!=0.0) sl = (sl-MarketInfo(0,MODE_ASK))/Poin;

      if (tp!=0.0) tp = (MarketInfo(0,MODE_ASK)-tp)/Poin;
   }

   if (orderType==SellStop || orderType==SellLimit) {
      if (PendingOrderPrice == 0.00){
         PendingOrderPrice = (MarketInfo(0,MODE_BID))+(PendingOrderPips*Poin);
         if (sl!=0.0) sl = (sl-PendingOrderPrice)/Poin;

         if (tp!=0.0) tp = (PendingOrderPrice-tp)/Poin;
      } else {
         if (sl!=0.0) sl = (sl-PendingOrderPrice)/Poin;

         if (tp!=0.0) tp = (PendingOrderPrice-tp)/Poin;
      }
   }
//----
return(0);
}

int SendSignal() {
//----
   if (orderType == 1 || orderType == 2) {
      PendingOrderPrice = MarketInfo(0,MODE_ASK);
   }

   if (takeprofit_Price == 0.0 && totalLot == 0) {
      tp = sl*ratio;
      if (orderType==Sell || orderType==SellStop || orderType==SellLimit) takeprofit_Price = OrderOpenPrice()-tp*Poin;
      if (orderType==Buy || orderType==BuyStop || orderType==BuyLimit) takeprofit_Price = OrderOpenPrice()+tp*Poin;
   }

   string   Trade="";
   // Trade = consider + StringConcatenate(EnumToString(orderType)+ " " + Symbol() + " @ " + PendingOrderPrice + "  | ");
   Trade = consider + StringConcatenate(EnumToString(orderType)+ " " + Symbol() + " @ " + PendingOrderPrice + "  |  " +  "SL <b> " + stoploss_Price + " ( " + sl + "pips )"+ "</b>  |  TP <b> " + takeprofit_Price + " ( " + tp + "pips )"+"</b> | (RR = " + NormalizeDouble((tp/sl),2)+")");
   string cookie=NULL,headers;
   char post[],result[];

   Trade += link;
   string journal = StringConcatenate(EnumToString(orderType)+ " " + Symbol() + " --- " );
   journal += curDetails(Symbol());

   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection

   string bileonaire_fx_free=StringConcatenate("https://api.telegram.org/bot1283891993:AAGa9NV3ntsmIRj89yHSGCb-znW5WUhpJio/sendMessage?chat_id="+chatId3+"&text="+Trade+"&parse_mode=html");
   string Leon_journal=StringConcatenate("https://api.telegram.org/bot1283891993:AAGa9NV3ntsmIRj89yHSGCb-znW5WUhpJio/sendMessage?chat_id="+chatId4+"&text="+journal+"&parse_mode=html");
   string Leon_private_trade=StringConcatenate("https://api.telegram.org/bot1283891993:AAGa9NV3ntsmIRj89yHSGCb-znW5WUhpJio/sendMessage?chat_id="+chatId4+"&text="+Trade+"&parse_mode=html");

   ResetLastError();

   if (send_signal) int free=WebRequest("POST",bileonaire_fx_free,cookie,NULL,timeout,post,0,result,headers);
   if (!send_signal) int private_trade=WebRequest("POST",Leon_private_trade,cookie,NULL,timeout,post,0,result,headers);
   int leon=WebRequest("POST",Leon_journal,cookie,NULL,timeout,post,0,result,headers);

return(0);
}

int SendJournal() {
   string cookie=NULL,headers;
   char post[],result[];
   int timeout=5000;
   string instrument = Symbol();

   string data = StringConcatenate(
      "&accumulate=" + addPoints(instrument) +"&"+

      "D1CLOSE=" + PriceAboveBelowClose(instrument, 1440, 1) +"&"+
      "H4CLOSE=" + PriceAboveBelowClose(instrument, 240, 1) +"&"+
      "H1CLOSE=" + PriceAboveBelowClose(instrument, 60, 1) +"&"+
      "M15CLOSE=" + PriceAboveBelowClose(instrument, 15, 1) +"&"+

      "D1PREV=" + check_prev_candle(instrument, 1440, 1) +"&"+
      "H4PREV=" + check_prev_candle(instrument, 240, 1) +"&"+
      "H1PREV=" +  check_prev_candle(instrument, 60, 1) +"&"+
      "M15PREV=" + check_prev_candle(instrument, 15, 1) +"&"+

      "D1200EMA=" + closeAboveBelowEMA(instrument, 1440, 200) +"&"+
      "H4200EMA=" + closeAboveBelowEMA(instrument, 240, 200) +"&"+
      "H1200EMA=" + closeAboveBelowEMA(instrument, 60, 200) +"&"+
      "M15200EMA=" + closeAboveBelowEMA(instrument, 15, 200) +"&"+

      "D150SMA=" + closeAboveBelowSMA(instrument, 1440, 50) +"&"+
      "H450SMA=" + closeAboveBelowSMA(instrument, 240, 50) +"&"+
      "H150SMA=" + closeAboveBelowSMA(instrument, 60, 50) +"&"+
      "M1550SMA=" + closeAboveBelowSMA(instrument, 15, 50) +"&"+

      "D18EMA=" + PriceAboveBelowEMA(instrument, 1440, 8) +"&"+
      "H48EMA=" + PriceAboveBelowEMA(instrument, 240, 8) +"&"+
      "H18EMA=" + PriceAboveBelowEMA(instrument, 60, 8) +"&"+
      "M158EMA=" + PriceAboveBelowEMA(instrument, 15, 8) +"&"+

      "D120EMA=" +closeAboveBelowEMA(instrument, 1440, 20) +"&"+
      "H420EMA=" +closeAboveBelowEMA(instrument, 240, 20) +"&"+
      "H120EMA=" +closeAboveBelowEMA(instrument, 60, 20) +"&"+
      "M1520SMA=" + closeAboveBelowSMA(instrument, 15, 20) +"&"+

      "D1ENV=" + environment(instrument,1440) +"&"+
      "H4ENV=" + environment(instrument,240) +"&"+
      "H1ENV=" + environment(instrument,60) +"&"+
      "M15ENV=" + environment(instrument,15) +"&"+
      "image1=" + link +"&"+
      "ticketNum=" + ticketNum +"&"+
      "commission=" + commission+"&"+
      "lotSize=" + NormalizeDouble(lotSize, 2)
   );

   string journalAPI=StringConcatenate("https://2ce2-41-212-47-64.ngrok.io/api/newtrade?traderId=1&currency=" + instrument + "&direction="+EnumToString(orderType)+"&slPrice=" + stoploss_Price + "&tpPrice=" + takeprofit_Price + "&slPips=" + sl + "&tpPips=" + tp + "&RR=" + NormalizeDouble((tp/sl),2) + data);
   ResetLastError();
   int journal=WebRequest("GET",journalAPI,cookie,NULL,timeout,post,0,result,headers);
   if (journal != 201) MessageBox(journal);
return(0);
}

string curDetails (string cur) {

  double accumulate = addPoints(cur);
  string accPoints = DoubleToStr(accumulate, 2);
  string text = "";
  double buyPercent = (accumulate/20)*100;
  string percent = DoubleToStr(buyPercent, 2);

  text +=   " { ACCUMULATE : " + accPoints + "( " + percent + "% )," +
            " D1_PREV : " + check_prev_candle(cur, 1440, 1) + ", " +
 	         " D1_8ema : " + PriceAboveBelowEMA(cur, 1440, 8) + ", " +
            " D1_PREV_CLOSE: " + PriceAboveBelowClose(cur, 1440, 1) + "," +
            " H4_PREV_CANDLE : " + check_prev_candle(cur, 240, 1) + "," +
            " H4_50SMA : " + closeAboveBelowSMA(cur, 240, 50) + "," +
            " H4_20EMA : " + closeAboveBelowEMA(cur, 240, 20) + "," +
            " H1_PREV_CANDLE : " + check_prev_candle(cur, 60, 1) + "," +
            " M15_PREV_CANDLE : " + environment(cur, 15) + "," +
            " M15_200_EMA : " + closeAboveBelowEMA(cur, 15, 200) + "," +
            " M15_50_SMA : " + closeAboveBelowSMA(cur, 15, 50) + "," +
            " M15_20_SMA : " + closeAboveBelowSMA(cur, 15, 20) + "," +
            " Env_15 : " + environment(cur,15) + "," +
            " Env_1H : " + environment(cur,60) + "," +
            " Env_4H : " + environment(cur,240) +
            "}";
  return text;
}

//+------------------------------------------------------------------+
string closeAboveBelowSMA(string currency, int timef, int movingAVG)
{
   string status = "";
   double closePrice = close(currency, timef, 1);

   if (closePrice > iMA(currency,timef,movingAVG,0,MODE_SMA,PRICE_CLOSE,0)) {
     status = "buy";
   } else {
     status = "sell";
   }
   return status;
}

string PriceAboveBelowEMA(string currency, int timef, int movingAVG)
{
   string status = "";
   double PriceAsk = MarketInfo(currency, MODE_ASK);

   if (PriceAsk > iMA(currency,timef,movingAVG,0,MODE_EMA,PRICE_CLOSE,0)) {
     status = "buy";
   } else {
     status = "sell";
   }
   return status;
}

string closeAboveBelowEMA (string cur, int timef, int movingAVG) {
  double close = close(cur, timef, 1);

  double ema = iMA(cur,timef,movingAVG,0,MODE_EMA,PRICE_CLOSE,0);
  string situation = "";
  if (close > ema) situation = "buy";
  if (close < ema) situation = "sell";
  return situation;
}

string check_prev_candle(string currency, int timef, int shift)
{
   string status = "";
   if (iOpen(currency,timef,shift) > iClose(currency,timef,shift)) {
     status = "sell";
   } else {
     status = "buy";
   }
   return status;
}

string PriceAboveBelowClose(string currency, int timef, int shift)
{
   double PriceAsk = MarketInfo(currency, MODE_ASK);
  //  double PriceBid = MarketInfo(currency, MODE_BID);

   string status = "";
   if (PriceAsk > iClose(currency,timef,shift)) {
     status = "buy";
   } else {
     status = "sell";
   }
   return status;
}

double close(string currency, int timef, int shift)
{
   double val=iClose(currency,timef,shift);
   return val;
}

string environment (string currency, int timef)
{
  double MacdCurrent = iMACD(currency,timef,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
  double twenty_ema = iMA(currency,timef,20,0,MODE_EMA,PRICE_CLOSE,0);
  double ten_ema = iMA(currency,timef,10,0,MODE_EMA,PRICE_CLOSE,0);
  // double price = MarketInfo(currency,MODE_ASK);
  string buy_or_sell = " ";

// BUY env
  if (MacdCurrent > 0 && ten_ema > twenty_ema) buy_or_sell = "buy";
// Sell env
  if (MacdCurrent < 0 && ten_ema < twenty_ema) buy_or_sell = "sell";
  return buy_or_sell;
}

double addPoints(string cur) {
  double accumulate = 0;
  if (check_prev_candle(cur, 1440, 1) == "buy") accumulate += 3;
  if (PriceAboveBelowEMA(cur, 1440, 8) ==  "buy") accumulate += 3;
  if (PriceAboveBelowClose(cur, 1440, 1) == "buy") accumulate += 1;

  // h4
  if (check_prev_candle(cur, 240, 1) == "buy") accumulate += 2.5;
  if (environment(cur, 240) == "buy") accumulate += 2.5;
  if (closeAboveBelowEMA(cur, 240, 20) == "buy") accumulate += 1.5;

  // h1
  if (check_prev_candle(cur, 60, 1) == "buy") accumulate += 1.5;
  if (environment(cur, 60) == "buy") accumulate += 1.5;

  // m15
  if (check_prev_candle(cur, 15, 1) == "buy") accumulate += 1;
  if (environment(cur, 15) == "buy") accumulate += 1;
  if (closeAboveBelowEMA(cur, 15, 200) == "buy") accumulate += 1.5;
  return accumulate;
}