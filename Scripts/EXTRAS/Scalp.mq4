//+------------------------------------------------------------------+
//|                                             Instant_Execution.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2020, Bileonaire."
//version 1.0

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
};

input e_orderType  orderType = Buy;

extern double Account = 1000.0;
extern double Percentage_Risk = 1.0;

extern double  totalLot = 0.0;

extern int numOfOrders = 1;
extern string comment = "";

extern double PendingOrderPrice = 0.00;
extern double PendingOrderPips = 0.00;

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

double lot;

double stoploss;
double takeprofit;

double stoploss_Price;
double takeprofit_Price;

double Poin;
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
//+------------------------------------------------------------------+

   if (Sl_Tp_Type == 1) {
      ModifyPips();
   }
   if (Sl_Tp_Type == 2) {
      ModifyPrice();
   }
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

int ModifyPips() {
//----
   int ordertotal = OrdersTotal();
   for (int i=0; i<ordertotal; i++)
   {
      int order = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol())
         if (OrderComment() == comment && (OrderType()==OP_BUY || OrderType()==OP_BUYSTOP))
         {
            if (sl==0.0 || Set_SL == 2) stoploss = 0.0;
            else stoploss = OrderOpenPrice()-sl*Poin;

            if (tp==0.0) takeprofit = 0.0;
            else takeprofit = OrderOpenPrice()+tp*Poin;

            int ticket = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss, takeprofit, 0);
         }

         if (OrderComment() == comment && (OrderType()==OP_SELL || OrderType()==OP_SELLSTOP))
         {
            if (sl==0.0 || Set_SL == 2) stoploss = 0.0;
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
            int ticket3 = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss_Price, takeprofit_Price, 0);
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

   if (orderType==BuyStop) {
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

   if (orderType==SellStop) {
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
