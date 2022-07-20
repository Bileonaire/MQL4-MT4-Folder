//+------------------------------------------------------------------+
//|                                                   Tick-Value.mq4 |
//|                                          Copyright © 2007, Willf |
//|                                                   willf@willf.net|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Bileonaire"
#property link      "bileonairefx.com"

#property indicator_chart_window

string Text="";
double Poin;


int index[] = {15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240, 255, 270, 285, 310, 335, 350};

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
int start() {
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

    string D1PREV="D1 PREV : "+ check_prev_candle(Symbol(), 1440, 1) +"  ";;
    ObjectCreate("D1PREV", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("D1PREV",D1PREV, 8, "Tahoma", Gold); //
    ObjectSet("D1PREV", OBJPROP_CORNER, 1);
    ObjectSet("D1PREV", OBJPROP_XDISTANCE, 1);
    ObjectSet("D1PREV", OBJPROP_YDISTANCE, index[0]);

    string D18EMA="D1 8EMA : "+ PriceAboveBelowEMA(Symbol(), 1440, 8) +"  ";;
    ObjectCreate("D18EMA", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("D18EMA",D18EMA, 8, "Tahoma", Gold); //
    ObjectSet("D18EMA", OBJPROP_CORNER, 1);
    ObjectSet("D18EMA", OBJPROP_XDISTANCE, 1);
    ObjectSet("D18EMA", OBJPROP_YDISTANCE, index[1]);

    string D1CLOSE="D1CLOSE : "+ PriceAboveBelowClose(Symbol(), 1440, 1) +"  ";;
    ObjectCreate("D1CLOSE", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("D1CLOSE",D1CLOSE, 8, "Tahoma", Gold); //
    ObjectSet("D1CLOSE", OBJPROP_CORNER, 1);
    ObjectSet("D1CLOSE", OBJPROP_XDISTANCE, 1);
    ObjectSet("D1CLOSE", OBJPROP_YDISTANCE, index[2]);

    string H4PREV="H4 PREV : "+ check_prev_candle(Symbol(), 240, 1) +"  ";;
    ObjectCreate("H4PREV", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("H4PREV",H4PREV, 8, "Tahoma", Gold); //
    ObjectSet("H4PREV", OBJPROP_CORNER, 1);
    ObjectSet("H4PREV", OBJPROP_XDISTANCE, 1);
    ObjectSet("H4PREV", OBJPROP_YDISTANCE, index[3]);

    string H420EMA="H420EMA : "+ closeAboveBelowEMA(Symbol(), 240, 20) +"  ";;
    ObjectCreate("H420EMA", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("H420EMA",H420EMA, 8, "Tahoma", Gold); //
    ObjectSet("H420EMA", OBJPROP_CORNER, 1);
    ObjectSet("H420EMA", OBJPROP_XDISTANCE, 1);
    ObjectSet("H420EMA", OBJPROP_YDISTANCE, index[4]);

    string H1PREV="H1PREV : "+ check_prev_candle(Symbol(), 60, 1) +"  ";;
    ObjectCreate("H1PREV", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("H1PREV",H1PREV, 8, "Tahoma", Gold); //
    ObjectSet("H1PREV", OBJPROP_CORNER, 1);
    ObjectSet("H1PREV", OBJPROP_XDISTANCE, 1);
    ObjectSet("H1PREV", OBJPROP_YDISTANCE, index[5]);

    string M15PREV="M15PREV : "+ check_prev_candle(Symbol(), 15, 1) +"  ";;
    ObjectCreate("M15PREV", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("M15PREV",M15PREV, 8, "Tahoma", Gold); //
    ObjectSet("M15PREV", OBJPROP_CORNER, 1);
    ObjectSet("M15PREV", OBJPROP_XDISTANCE, 1);
    ObjectSet("M15PREV", OBJPROP_YDISTANCE, index[6]);

    string M15200EMA="M15200EMA : "+ closeAboveBelowEMA(Symbol(), 15, 200) +"  ";;
    ObjectCreate("M15200EMA", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("M15200EMA",M15200EMA, 8, "Tahoma", Gold); //
    ObjectSet("M15200EMA", OBJPROP_CORNER, 1);
    ObjectSet("M15200EMA", OBJPROP_XDISTANCE, 1);
    ObjectSet("M15200EMA", OBJPROP_YDISTANCE, index[7]);

    string M1520SMA="M1520SMA : "+ closeAboveBelowSMA(Symbol(), 15, 20) +"  ";;
    ObjectCreate("M1520SMA", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("M1520SMA",M1520SMA, 8, "Tahoma", Gold); //
    ObjectSet("M1520SMA", OBJPROP_CORNER, 1);
    ObjectSet("M1520SMA", OBJPROP_XDISTANCE, 1);
    ObjectSet("M1520SMA", OBJPROP_YDISTANCE, index[8]);

    string ACCUMULATE="ACCUMULATE % : "+ addPoints(Symbol()) +"  ";;
    ObjectCreate("ACCUMULATE", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("ACCUMULATE",ACCUMULATE, 8, "Tahoma", Gold); //
    ObjectSet("ACCUMULATE", OBJPROP_CORNER, 1);
    ObjectSet("ACCUMULATE", OBJPROP_XDISTANCE, 1);
    ObjectSet("ACCUMULATE", OBJPROP_YDISTANCE, index[9]);

    string TrendD1="TrendD1 : "+ DoubleToStr(D1 , 0) +"  ";;
    ObjectCreate("TrendD1", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("TrendD1",TrendD1, 8, "Tahoma", Gold); //
    ObjectSet("TrendD1", OBJPROP_CORNER, 1);
    ObjectSet("TrendD1", OBJPROP_XDISTANCE, 1);
    ObjectSet("TrendD1", OBJPROP_YDISTANCE, index[10]);

    string H4ENV="H4ENV : "+ environment(Symbol(),240) +"  ";;
    ObjectCreate("H4ENV", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("H4ENV",H4ENV, 8, "Tahoma", Gold); //
    ObjectSet("H4ENV", OBJPROP_CORNER, 1);
    ObjectSet("H4ENV", OBJPROP_XDISTANCE, 1);
    ObjectSet("H4ENV", OBJPROP_YDISTANCE, index[11]);

    string TrendH4="TrendH4 : "+ DoubleToStr(H4 , 0) +"  ";;
    ObjectCreate("TrendH4", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("TrendH4",TrendH4, 8, "Tahoma", Gold); //
    ObjectSet("TrendH4", OBJPROP_CORNER, 1);
    ObjectSet("TrendH4", OBJPROP_XDISTANCE, 1);
    ObjectSet("TrendH4", OBJPROP_YDISTANCE, index[12]);

    string H1ENV="H1ENV : "+ environment(Symbol(),60) +"  ";;
    ObjectCreate("H1ENV", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("H1ENV",H1ENV, 8, "Tahoma", Gold); //
    ObjectSet("H1ENV", OBJPROP_CORNER, 1);
    ObjectSet("H1ENV", OBJPROP_XDISTANCE, 1);
    ObjectSet("H1ENV", OBJPROP_YDISTANCE, index[13]);

    string TrendH1="TrendH1 : "+ DoubleToStr(H1 , 0) +"  ";;
    ObjectCreate("TrendH1", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("TrendH1",TrendH1, 8, "Tahoma", Gold); //
    ObjectSet("TrendH1", OBJPROP_CORNER, 1);
    ObjectSet("TrendH1", OBJPROP_XDISTANCE, 1);
    ObjectSet("TrendH1", OBJPROP_YDISTANCE, index[14]);

    string M15ENV="M15ENV : "+ environment(Symbol(),15) +"  ";;
    ObjectCreate("M15ENV", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("M15ENV",M15ENV, 8, "Tahoma", Gold); //
    ObjectSet("M15ENV", OBJPROP_CORNER, 1);
    ObjectSet("M15ENV", OBJPROP_XDISTANCE, 1);
    ObjectSet("M15ENV", OBJPROP_YDISTANCE, index[15]);

    string TRENDM15="TRENDM15 : "+ DoubleToStr(M15 , 0) +"  ";;
    ObjectCreate("TRENDM15", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("TRENDM15",TRENDM15, 8, "Tahoma", Gold); //
    ObjectSet("TRENDM15", OBJPROP_CORNER, 1);
    ObjectSet("TRENDM15", OBJPROP_XDISTANCE, 1);
    ObjectSet("TRENDM15", OBJPROP_YDISTANCE, index[16]);

    string TICKVALUE="TICKVALUE : "+ DoubleToStr(MarketInfo(Symbol(), MODE_TICKVALUE), 4) +"  ";;
    ObjectCreate("TICKVALUE", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("TICKVALUE",TICKVALUE, 8, "Tahoma", Gold); //
    ObjectSet("TICKVALUE", OBJPROP_CORNER, 1);
    ObjectSet("TICKVALUE", OBJPROP_XDISTANCE, 1);
    ObjectSet("TICKVALUE", OBJPROP_YDISTANCE, index[17]);

    string SPREAD="SPREAD : "+ DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 0) +"  ";;
    ObjectCreate("SPREAD", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("SPREAD",SPREAD, 8, "Tahoma", Gold); //
    ObjectSet("SPREAD", OBJPROP_CORNER, 1);
    ObjectSet("SPREAD", OBJPROP_XDISTANCE, 1);
    ObjectSet("SPREAD", OBJPROP_YDISTANCE, index[18]);

    double total = ((D1 + H4 + H1 + M15) / 4 + addPoints(Symbol())) / 2;
    double avg_VALUE = NormalizeDouble(total , 2);

    string AVERAGE="AVERAGE : "+ DoubleToStr(avg_VALUE, 0) +"  ";;
    ObjectCreate("AVERAGE", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("AVERAGE",AVERAGE, 8, "Tahoma", White); //
    ObjectSet("AVERAGE", OBJPROP_CORNER, 1);
    ObjectSet("AVERAGE", OBJPROP_XDISTANCE, 1);
    ObjectSet("AVERAGE", OBJPROP_YDISTANCE, index[19]);

    double leon = candlestick(Symbol(), 60, 1);
    string AVERAGE2="console : "+ DoubleToStr(leon, 4) +"  ";;
    ObjectCreate("AVERAGE2", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("AVERAGE2",AVERAGE2, 8, "Tahoma", White); //
    ObjectSet("AVERAGE2", OBJPROP_CORNER, 1);
    ObjectSet("AVERAGE2", OBJPROP_XDISTANCE, 1);
    ObjectSet("AVERAGE2", OBJPROP_YDISTANCE, index[20]);

    string consoleString_ = analyzePrevCandles(Symbol(), 8, 60);
    string consoleString="H1 - 8hrs : " + consoleString_ +"  ";;
    ObjectCreate("consoleString", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("consoleString",consoleString, 8, "Black", White); //
    ObjectSet("consoleString", OBJPROP_CORNER, 1);
    ObjectSet("consoleString", OBJPROP_XDISTANCE, 1);
    ObjectSet("consoleString", OBJPROP_YDISTANCE, index[21]);
return 0;
}

int EMAtrend(string currency, int timef, int movingAVG, int range) {
    double trend = 0;
    for(int i = range; i > 1; i--) {
        int j = i - 1;
        if (iMA(currency,timef,movingAVG,0,MODE_EMA,PRICE_CLOSE,j) > iMA(currency,timef,movingAVG,0,MODE_EMA,PRICE_CLOSE,i)) {
            trend += 1;
        }
    }

    double percent = (trend/range)*100;
    return percent;
}
int D1 = EMAtrend(Symbol(), 1440, 8, 7);
int H4 = EMAtrend(Symbol(), 240, 8, 9);
int H1 = EMAtrend(Symbol(), 60, 8, 13);
int M15 = EMAtrend(Symbol(), 15, 8, 15);

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

  double percent = (accumulate/20)*100;
  return percent;
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

double candlestick(string currency, int timef, int shift) {
  double openPrice = iOpen(currency,timef,shift);
  double closePrice =  iClose(currency,timef,shift);
  double highPrice =  iHigh(currency,timef,shift);
  double lowPrice =  iLow(currency,timef,shift);

  return priceDifferencePips(openPrice, closePrice);
}

double priceDifferencePips(double price1, double price2) {
  double difference = price1 - price2;
  difference = MathAbs(difference);
  double pips = difference/Poin;
  return pips;
}

string analyzePrevCandles(string currency, int candles, int timef) {
  int buys = 0;
  int sells = 0;
  double pipsUp = 0;
  double pipsDown = 0;

  for (int i=1 ; i <= candles ; i++) {
    double candleBodyPips = priceDifferencePips(iOpen(currency,timef,i), iClose(currency,timef,i));
    if (check_prev_candle(currency, timef, i) == "sell") {
      sells++;
      pipsDown += candleBodyPips;
    }
    if (check_prev_candle(currency, timef, i) == "buy") {
      buys++;
      pipsUp += candleBodyPips;
    }
  }
  return StringConcatenate("buys = " + buys + "| sells = " + sells + "| pipsUp = " + pipsUp + "| pipsDown = " + pipsDown + "    ");
}