//+------------------------------------------------------------------+
//|                                             Instant_Execution.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2020, FX Masterminds."
#property link      "https://lennykioko.github.io/"

//version 1.0


#include <stderror.mqh>
#include <stdlib.mqh>

//external parameters to be provided

int numOfOrders = 5;
string comment = "b";
double  totalLot = 1;

double sl = 0;
double tp = 0;

double lot = totalLot / numOfOrders;

double stoploss;
double takeprofit;

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
   return(0);
}
//+------------------------------------------------------------------+
//                                                                   +
//+------------------------------------------------------------------+

int start() {
    ExecuteBuy();
    ModifyPips();
    ProfitableSL();
   return(0);
}


int ExecuteBuy() {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   while( numOfOrders > 0) {
       int ticket = OrderSend(Symbol(), OP_BUY, lot, Ask, 3, 0.000, 0.000, comment, 11, 0, CLR_NONE);
       int stop = OrderSend(Symbol(), OP_BUYSTOP, lot, Ask+10*Poin, 3, 0.000, 0.000, comment, 55, 0, CLR_NONE);
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
         if (OrderComment() == comment && OrderType()==OP_BUYSTOP)
         {
            int ticket = OrderModify(OrderTicket(), OrderOpenPrice(), 0.00, OrderOpenPrice()+5*Poin, 0);
         }

         if (OrderComment() == comment && OrderType()==OP_SELLSTOP)
         {
            int ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), 0.00, OrderOpenPrice()-tp*Poin, 0);
         }
      }
//----
return(0);
}

int ProfitableSL() {
//----
   int ordertotal = OrdersTotal();

   while( ordertotal > 0) {
       for (int i=0; i<ordertotal; i++)
        {
            int order = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
            if (OrderComment() == comment && OrderType()==OP_BUY)
            {
                if ((Ask-OrderOpenPrice()) < 20*Poin) stoploss = OrderStopLoss();
                else stoploss = OrderOpenPrice()+4*Poin;

                int ticket = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss,  OrderTakeProfit(), 0);
            }

            if (OrderComment() == comment && OrderType()==OP_SELL)
            {
                if (OrderOpenPrice()-Ask < 20*Poin) stoploss = OrderStopLoss();
                else stoploss = OrderOpenPrice()-4*Poin;

                int ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss,  OrderTakeProfit(), 0);
            }
        }
   }
//----
return(0);
}
