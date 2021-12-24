//+------------------------------------------------------------------+
//|                                                     Leon Bot.mq4 |
//|                                                       Bileonaire |
//|                                                         leon.com |
//+------------------------------------------------------------------+
#property copyright "Bileonaire"
#property link      "leon.com"
#property version   "1.00"
#property strict

string comment = "killer";
double Percentage_Risk = 1;
double Poin;
double target;

double magicNB = 5744;

string message ="";
double Balance;

double ND(double val)
{
return(NormalizeDouble(val, Digits));
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  string pairs[];
  int length = getAvailableCurrencyPairs(pairs);
  for(int i=0; i < length; i++)
  {
    string curr_env = all_time_environment(pairs[i]);
    if (curr_env == "buy" || curr_env == "sell") {
      Alert(curr_env, ": ", pairs[i]);
    }
  }
}

//+------------------------------------------------------------------+
int getAvailableCurrencyPairs(string& availableCurrencyPairs[])
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

//+------------------------------------------------------------------+

double high(string currency, int timef, int shift)
{
   double val=iHigh(currency,timef,shift);
   return val;
}

double low(string currency, int timef, int shift)
{
   double val;
   val=iLow(currency,timef,shift);
   return val;
}

// Lowest in the past ___ bars
double lowest(string currency, double bars)
{
   double val;
   int val_index;
   val_index=iLowest(currency,0,MODE_LOW,bars,0);
   if(val_index!=-1) val=High[val_index];
   else val=0;

   return val;
}

// Highest in the past ___ bars
double highest(string currency, double bars)
{
   double val;
   int  val_index=iHighest(currency,60,MODE_HIGH,bars,1);
   if(val_index!=-1) val=High[val_index];
   else val=0;

   Alert("leon");
   return val;
// else PrintFormat("Error in call iHighest. Error code=%d",GetLastError());
}

//  Check orders
string currency_open_orders (string currency)
{
  double currency_orders;
  for(int i=0;i<OrdersTotal();i++) {
    int order = OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
    if (OrderComment() == comment && OrderSymbol() == currency) currency_orders++;
  }
  return currency_orders;
}

//  All orders
string all_open_orders ()
{
  double orderplaced;
  for(int i=0;i<OrdersTotal();i++) {
    int order = OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
    if (OrderComment() == comment) orderplaced++;
    }
    return orderplaced;
}

// Environment_Check
// Call the function: environment(Symbol(),15)
string environment (string currency, int timef)
{
  double MacdCurrent = iMACD(currency,timef,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
  double twenty_ema = iMA(currency,timef,20,0,MODE_EMA,PRICE_CLOSE,0);
  double ten_ema = iMA(currency,timef,10,0,MODE_EMA,PRICE_CLOSE,0);
  string buy_or_sell = " ";

// BUY env
  if (MacdCurrent > 0 && ten_ema > twenty_ema) buy_or_sell = "buy";
// Sell env
  if (MacdCurrent < 0 && ten_ema < twenty_ema) buy_or_sell = "sell";
  return buy_or_sell;
}

string all_time_environment (string currency)
{
  double price = MarketInfo(currency,MODE_ASK);
  double ten_ema = iMA(currency,240,10,0,MODE_EMA,PRICE_CLOSE,0);

  string env_ = " ";
// BUY env
  if (environment(currency, 240) == "buy" && environment(currency, 60) == "buy" && environment(currency, 15) == "buy" && choppines(currency, 15) < 52 && price > ten_ema) env_ = "buy";
// Sell env
  if (environment(currency, 240) == "sell" && environment(currency, 60) == "sell" && environment(currency, 15) == "sell" && choppines(currency, 15) < 52 && price < ten_ema) env_ = "sell";
  return env_;
}

double choppines(string currency, int timeframe)
{
  int choppy_value = NormalizeDouble(iCustom(currency, timeframe, "Custom\\choppiness-index", 0, 0), 2);
  return choppy_value;
}

double checkSpread(string currency)
{
  double spread_value = NormalizeDouble(MarketInfo(currency, MODE_SPREAD), 2);
  return spread_value;
}

//+------------------------------------------------------------------+

double executeTrade(string orderType, string symbol, double accountSize, double percentageRisk, double pendingOrderPrice, double stopLossPrice, double takeProfitPrice)
{
  if(IsTradingAllowed())
  {
    double riskPerTradeDollars = (accountSize * (percentageRisk / 100));
    // buy
    if(orderType == "sell" && pendingOrderPrice == 0.0)
    {
        double entryPrice = MarketInfo(symbol, MODE_ASK);
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_BUY, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // sell
    if(orderType == "buy" && pendingOrderPrice == 0.0)
    {
        double entryPrice = MarketInfo(symbol, MODE_BID);
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_SELL, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // buystop
    if(orderType == "buystop")
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_BUYSTOP, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // sellstop
    if(orderType == "sellstop")
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_SELLSTOP, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // buylimit
    if(orderType == "buylimit")
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_BUYLIMIT, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // selllimit
    if(orderType == "selllimit")
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_SELLLIMIT, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, IntegerToString(magicNB), magicNB, 0, 0); // magic number as comment
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }
  }
  return(0);
}

//+------------------------------------------------------------------+

// custom re-usable functions

// works for fx pairs, may not work for indices
double GetPipValue(string symbol)
{
  int vdigits = (int)MarketInfo(symbol, MODE_DIGITS);

  if(vdigits >= 4)
  {
    return 0.0001;
  }
  else
  {
    return 0.01;
  }
}

double CalculateLotSize(string symbol, double riskDollars, double entryPrice, double slPrice)
{
  double pipValue = MarketInfo(symbol, MODE_TICKVALUE) * 10;
  double pips = MathAbs(entryPrice - slPrice) / GetPipValue(symbol);
  double div = pips * pipValue;
  double lot = NormalizeDouble(riskDollars / div, 2);

  return lot;
}

bool IsTradingAllowed()
{
  if(!IsTradeAllowed())
  {
    Alert("Expert Advisor is NOT Allowed to Trade. Check AutoTrading.");
    return false;
  }

  if(!IsTradeAllowed(Symbol(), TimeCurrent()))
  {
    Alert("Trading NOT Allowed for specific Symbol and Time");
    return false;
  }
  return true;
}

int closeAll()
{
  int ticket;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
        if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES) == true)
          {
            if (OrderType() == 0 && OrderComment() == comment)
              {
              ticket = OrderClose (OrderTicket(), OrderLots(), MarketInfo (OrderSymbol(), MODE_BID), 3, CLR_NONE);
              if (ticket == -1) Print ("Error: ", GetLastError());
              if (ticket >   0) Print ("Position ", OrderTicket() ," closed");
              }
            if (OrderType() == 1 && OrderComment() == comment)
              {
              ticket = OrderClose (OrderTicket(), OrderLots(), MarketInfo (OrderSymbol(), MODE_ASK), 3, CLR_NONE);
              if (ticket == -1) Print ("Error: ",  GetLastError());
              if (ticket >   0) Print ("Position ", OrderTicket() ," closed");
              }
          }
        }
        return ticket;
}

int sendTelegram(string message, string chat_id)
{
   string cookie=NULL,headers;
   char post[],result[];

   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection

   string sending=StringConcatenate("https://api.telegram.org/bot1283891993:AAGa9NV3ntsmIRj89yHSGCb-znW5WUhpJio/sendMessage?chat_id="+chat_id+"&text="+message+"&parse_mode=html");
   ResetLastError();
   int free=WebRequest("POST",sending,cookie,NULL,timeout,post,0,result,headers);
return(0);

// string chatId = "-1001278337047";
// string chatId2 = "-1001237306634";  // bileonaire_fx_community
// string chatId3 = "-1001366966111";
}
