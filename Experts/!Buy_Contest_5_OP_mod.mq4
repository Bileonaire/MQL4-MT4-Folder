//+------------------------------------------------------------------+
//|                                             Buy_Contest_5_OP.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2010, eninefx."
#property link      "http://www.kaskus.us/showthread.php?t=3967467&page=350"

//versi 2.0 - 25-mei-2010

//munculkan parameter input
#property show_inputs

#include <stderror.mqh>
#include <stdlib.mqh>

//parameternya ini, input-nya ini
extern double  LOT             = 0.75;
// extern double  TP              = 10.0;  // Mute SL&TP
// extern double  SL              = 10.0;  // Mute SL&TP

double Poin;
//+------------------------------------------------------------------+
//| Custom initialization function                                   |
//+------------------------------------------------------------------+
int init(){

   if (Point == 0.00001) Poin = 0.0001;
   else {
      if (Point == 0.001) Poin = 0.01;
      else Poin = Point;
   }
   return(0);
}
//+------------------------------------------------------------------+
//                                                                   +
//+------------------------------------------------------------------+
int start()
  {
   RefreshRates();
   while( IsTradeContextBusy() ) { Sleep(100); }
//----
   int ticket=OrderSend(Symbol(),OP_BUY,LOT,Ask,3,0.000,0.000,"contest",1,0,CLR_NONE);
              OrderSend(Symbol(),OP_BUY,LOT,Ask,3,0.000,0.000,"contest",2,0,CLR_NONE);
              OrderSend(Symbol(),OP_BUY,LOT,Ask,3,0.000,0.000,"contest",3,0,CLR_NONE);
              OrderSend(Symbol(),OP_BUY,LOT,Ask,3,0.000,0.000,"contest",4,0,CLR_NONE);
   if(ticket<1)
     {
      int error=GetLastError();
      Print("Error = ",ErrorDescription(error));
      return;
     }
//----
   OrderPrint();
   return(0);
  }
