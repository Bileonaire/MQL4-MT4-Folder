//+------------------------------------------------------------------+
//|                                                   Tick-Value.mq4 |
//|                                          Copyright © 2007, Willf |
//|                                                   willf@willf.net|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Bileonaire"
#property link      "bileonairefx.com"

#property indicator_chart_window

string   Text="";

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  Text="";
   //----
  //  double choppy = NormalizeDouble(iCustom(Symbol(), 0, "Custom\\choppiness-index", 0, 0), 2);
   buyStrengthPercent (Symbol());
   Text +=   "\n"+
            "\n"+
            "Tick Value = " + DoubleToStr(MarketInfo(Symbol(), MODE_TICKVALUE), 4) +
    	      "\n"+
    	      "\n"+
 	         "Spread = " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 0) +
 	         "\n"+
 	         "\n"+
 	         "\n"+
            "env 15 = " + environment(Symbol(),15) +
 	         "\n"+
 	         "\n"+
            "env 1H = " + environment(Symbol(),60) +
 	         "\n"+
 	         "\n"+
            "env 4H = " + environment(Symbol(),240) +
 	         "\n"+
 	         "\n"+
 	         "\n";
 	        //  "Choppiness = "  + DoubleToStr(choppy, 2);

    Comment(Text);

  return(0);
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
  if (PriceAboveBelowEMA(cur, 1440, 8) ==  "above") accumulate += 3;
  if (PriceAboveBelowClose(cur, 1440, 1) == "above") accumulate += 1;

  // h4
  if (check_prev_candle(cur, 240, 1) == "buy") accumulate += 2.5;
  if (environment(cur, 240) == "buy") accumulate += 2.5;
  if (closeAboveBelowEMA(cur, 240, 20) == "above") accumulate += 1.5;

  // h1
  if (check_prev_candle(cur, 60, 1) == "buy") accumulate += 1.5;
  if (environment(cur, 60) == "buy") accumulate += 1.5;

  // m15
  if (check_prev_candle(cur, 15, 1) == "buy") accumulate += 1;
  if (environment(cur, 15) == "buy") accumulate += 1;
  if (closeAboveBelowEMA(cur, 15, 200) == "above") accumulate += 1.5;
  return accumulate;

}

double buyStrengthPercent (string cur) {
  double accumulate = addPoints(cur);
  string accPoints = DoubleToStr(accumulate, 2);
  double buyPercent = (accumulate/20)*100;
  string percent = DoubleToStr(buyPercent, 2);
  Text +=   "\n"+
            "D1 PREV = " + check_prev_candle(cur, 1440, 1) +
    	      "\n"+
    	      "\n"+
 	         "D1 ABOVE 8ema = " + PriceAboveBelowEMA(cur, 1440, 8) +
 	         "\n"+
 	         "\n"+
            "D1 PRICE ABOVE PREV CLOSE= " + PriceAboveBelowClose(cur, 1440, 1) +
 	         "\n"+
 	         "\n"+
            "H4 PREV CANDLE = " + check_prev_candle(cur, 240, 1) +
 	         "\n"+
 	         "\n"+
            "H4 ABOVE_BELOW 20EMA = " + closeAboveBelowEMA(cur, 240, 20) +
 	         "\n"+
 	         "\n"
            "H1 PREV CANDLE = " + check_prev_candle(cur, 60, 1) +
 	         "\n"+
 	         "\n"+
            "M15 PREV CANDLE = " + environment(cur, 15) +
 	         "\n"+
           "\n"+
           "M15 Above Below 200 EMA = " + closeAboveBelowEMA(cur, 15, 200) +
           "\n"+
           "\n"+
           "M15 Above Below 20 SMA = " + closeAboveBelowSMA(cur, 15, 20) +
 	         "\n"
             "\n"+
           "\n"+
            "ACCUMULATE = " + accPoints +
 	         "\n"
            "\n"+
            "BUY PERCENT = " + percent +
 	         "\n";
  return Text;
}
//+------------------------------------------------------------------+

string closeAboveBelowSMA(string currency, int timef, int movingAVG)
{
   string status = "";
   double closePrice = close(currency, timef, 1);

   if (closePrice > iMA(currency,timef,movingAVG,0,MODE_SMA,PRICE_CLOSE,0)) {
     status = "above";
   } else {
     status = "below";
   }
   return status;
}

string PriceAboveBelowEMA(string currency, int timef, int movingAVG)
{
   string status = "";
   double PriceAsk = MarketInfo(currency, MODE_ASK);

   if (PriceAsk > iMA(currency,timef,movingAVG,0,MODE_EMA,PRICE_CLOSE,0)) {
     status = "above";
   } else {
     status = "below";
   }
   return status;
}

string closeAboveBelowEMA (string cur, int timef, int movingAVG) {
  double close = close(cur, timef, 1);

  double ema = iMA(cur,timef,movingAVG,0,MODE_EMA,PRICE_CLOSE,0);
  string situation = "";
  if (close > ema) situation = "above";
  if (close < ema) situation = "below";
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
     status = "above";
   } else {
     status = "below";
   }
   return status;
}

double close(string currency, int timef, int shift)
{
   double val=iClose(currency,timef,shift);
   return val;
}