//+------------------------------------------------------------------+
//|                                                   Tick-Value.mq4 |
//|                                          Copyright © 2007, Willf |
//|                                                   willf@willf.net|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Willf"
#property link      "willf@willf.net"

#property indicator_chart_window


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
   return(0);
   }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    
   string notify;
   string notified;

    double orderplaced = 1;
    double trading_time = 1;

    double h4_20 = iMA(NULL,240,20,0,MODE_SMA,PRICE_CLOSE,0);
    double h1_20 = iMA(NULL,60,20,0,MODE_SMA,PRICE_CLOSE,0);
    double m15_20 = iMA(NULL,15,20,0,MODE_SMA,PRICE_CLOSE,0);
    double m15_200 = iMA(NULL,15,200,0,MODE_SMA,PRICE_CLOSE,0);
    double choppy_15 = NormalizeDouble(iCustom(Symbol(), 15, "Custom\\choppiness-index", 0, 0), 2);
    double choppy_60 = NormalizeDouble(iCustom(Symbol(), 60, "Custom\\choppiness-index", 0, 0), 2);

    double buying_pressure = 0;
    double selling_pressure = 0;

    for(int i=0;i<OrdersTotal();i++) {
     int order = OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
      if (OrderSymbol() == Symbol()) orderplaced = 0;
    }

    if (Hour()<4 || Hour()>20) {
      trading_time = 0;
    }

    if (Close[1] > h1_20 && Close[1] > Close[2] && Close[1] > Close[3]){
      buying_pressure = 1;
    }

    if (Close[1] < h1_20 && Close[1] < Close[2] && Close[1] < Close[3]){
      selling_pressure = 1;
    }

    if (orderplaced && trading_time && choppy_15 < 61.8 && choppy_60 < 61.8) {
//+------------------------------------------------------------------+
//BUY
      if (Close[1] > m15_200 && Close[1] > h4_20 && Close[1] > m15_20 && Close[1] > Open[1] && buying_pressure) {
        notify = "Possible BUY setup on: " + Symbol();
        notified = notify;
        }
      }
//+------------------------------------------------------------------+
// Sell
      if (Close[1] < m15_200 && Close[1] < h4_20 && Close[1] < m15_20 && Close[1] < Open[1] && selling_pressure) {
        notify = "Possible SELL setup on: " + Symbol();
        notified = notify;
        }

   double choppy = NormalizeDouble(iCustom(Symbol(), 0, "Custom\\choppiness-index", 0, 0), 2);
   string   Text="";
   


   Text =   "\n"+
            "\n"+
            "Tick Value = " + DoubleToStr(MarketInfo(Symbol(), MODE_TICKVALUE), 4) +
    	      "\n"+
    	      "\n"+
 	         "Spread = " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 0) +
 	         "\n"+
 	         "\n"+
 	         "Choppiness = "  + DoubleToStr(choppy, 2)+
 	         "\n"+
 	         "\n"+
 	         notified;

   Comment(Text);

   return(0);
  }
//+------------------------------------------------------------------+







