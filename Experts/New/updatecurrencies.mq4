//+------------------------------------------------------------------+
//|                                                     Leon Bot.mq4 |
//|                                                       Bileonaire |
//|                                                         leon.com |
//+------------------------------------------------------------------+
#property copyright "Bileonaire"
#property link      "leon.com"
#property version   "1.00"
#property strict

extern string url= "https://8188-41-212-47-64.ngrok.io";
double latestUpdateMinute;


string pairs[] = {"USDJPY", "AUDUSD", "NZDUSD", "EURUSD", "GBPUSD", "USDCHF", "USDCAD", // majors
  "EURJPY", "EURAUD", "EURNZD", "EURGBP", "EURCHF", "EURCAD", // EUR pairs
  "GBPJPY", "GBPAUD", "GBPNZD", "GBPCHF", "GBPCAD", // GBP pairs
  "AUDJPY", "NZDJPY", "CHFJPY", "CADJPY", // JPY pairs
  "AUDNZD", "AUDCHF", "AUDCAD", "CADCHF", "NZDCHF", "NZDCAD", "USDCNH", // others
  "XAUUSD", "XAGUSD", // Gold
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  latestUpdateMinute = 0;
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick() {
    if (latestUpdateMinute != Minute() && updateTime(Minute())) {
        //string pairs[];
        //int length = getAvailableCurrencyPairs(pairs);

        for(int i=0; i < ArraySize(pairs); i++) {
            if (MarketInfo(pairs[i], MODE_SPREAD) < 20  && IsTradeAllowed(pairs[i], TimeCurrent()) &&  MarketInfo(pairs[i], MODE_ASK) > 0 ) {
                int D1 = EMAtrend(pairs[i], 1440, 8, 7);
                int H4 = EMAtrend(pairs[i], 240, 8, 9);
                int H1 = EMAtrend(pairs[i], 60, 8, 13);
                int M15 = EMAtrend(pairs[i], 15, 8, 15);
                int updateCurrency = SendJournal(pairs[i], addPoints(pairs[i]), MarketInfo(pairs[i], MODE_SPREAD), D1, H4, H1, M15);
            }
        }
    }

    latestUpdateMinute = Minute();
    return;
}

bool updateTime (int minute) {
    if (minute % 5 == 0 ) return true;
    // if (minute % 14 == 0 || minute % 29 == 0 || minute % 44 == 0 || minute % 59 == 0) return true;
    else return false;
}

//+------------------------------------------------------------------+
int getAvailableCurrencyPairs(string & availableCurrencyPairs[])
{
//---
   bool selected = false;
   const int symbolsCount = SymbolsTotal(selected);
   int currencypairsCount;
   ArrayResize(availableCurrencyPairs, symbolsCount);
   int idxCurrencyPair = 0;
   for(int idxSymbol = 0; idxSymbol < symbolsCount; idxSymbol++)
     {
         string symbol = SymbolName(idxSymbol, selected);
         string firstChar = StringSubstr(symbol, 0, 1);
         if(firstChar != "#" && StringLen(symbol) == 6)
           {
               availableCurrencyPairs[idxCurrencyPair++] = symbol;
           }
     }
     currencypairsCount = idxCurrencyPair;
     ArrayResize(availableCurrencyPairs, currencypairsCount);
     return currencypairsCount;
}
//+------------------------------------------------------------------+
class CFix { } ExtFix; // Force expressions evaluation while debugging


int SendJournal(string cur, double accumulate, int spread, double TrendD1 ,double TrendH4, double TrendH1, double TrendM15) {
    string cookie=NULL,headers;
    char post[],result[];
    int timeout=5000;
    double total = ((TrendD1 + TrendH4 + TrendH1 + TrendM15) / 4 + accumulate) / 2;
    double avg = NormalizeDouble(total , 2);
    double acc = NormalizeDouble(accumulate,2);

    string data = StringConcatenate(
        "name=" + cur +"&"+
        "accumulate=" + acc +"&"+
        "spread=" + spread +"&"+
        "TrendD1=" + TrendD1 +"&"+
        "TrendH4=" + TrendH4 +"&"+
        "TrendH1=" + TrendH1 +"&"+
        "TrendM15=" + TrendM15  +"&"+
        "AvgTrend=" + avg
    );

    string currencyAPI=StringConcatenate(url +"/api/currency?" + data);
    ResetLastError();
    int currencyData=WebRequest("GET",currencyAPI,cookie,NULL,timeout,post,0,result,headers);
    return(currencyData);
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

  double percent = (accumulate/20)*100;
  return percent;
}