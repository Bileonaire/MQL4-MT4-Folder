//+------------------------------------------------------------------+
//|                                                     Leon Bot.mq4 |
//|                                                       Bileonaire |
//|                                                         leon.com |
//+------------------------------------------------------------------+
#property copyright "Bileonaire"
#property link      "leon.com"
#property version   "1.00"
#property strict

string comment;
double target;

double magicNB = 5744;

string message ="";
int hour;
double latestUpdateMinute;

string analysis = "";
string cookie = NULL, headers;
char post[], result[];
int timeout = 5000;

int ticketNum_;
double commission_;
double lotSize_;

double ND(double val) {
  return(NormalizeDouble(val, Digits));
}

int OnInit() {
  return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  masterTrade(Symbol());
}

int masterTrade(string cur) {
  double m_30_high = iHigh(cur,30,1);
  double m_30_low = iLow(cur,30,1);

  double m_5_close = iClose(cur,5,1);

  if (latestUpdateMinute != Minute() && (Minute() % 5 == 0)) {
  // if (latestUpdateMinute != Minute()) {
    if (checkSpread(cur) < 22) {
      if (check_prev_candle(cur, 30, 1) == "buy" && m_5_close > m_30_high) {
        if (currency_open_orders(cur) == 0 && all_open_orders () < 2) {
          double poin = GetPipValue(cur);
          double entryPrice = MarketInfo(cur, MODE_BID);
          comment = StringConcatenate(Symbol() + DoubleToStr(entryPrice, 4));
          double stop_loss_Price = entryPrice-12*poin;

          executeTrade("buy", cur, 10, 100, 0, stop_loss_Price, 0.000);
          Modify_SL_TP(cur, comment, 12, (12*1.82));
          SendJournal(cur, "buy", ticketNum_, commission_, lotSize_, "", 12, (12*1.82));
        }
      }

      if (check_prev_candle(cur, 30, 1) == "sell" && m_5_close < m_30_low) {
        if (currency_open_orders(cur) == 0 && all_open_orders () < 2) {
          double poin = GetPipValue(cur);
          double entryPrice = MarketInfo(cur, MODE_ASK);
          comment = StringConcatenate(Symbol() + DoubleToStr(entryPrice, 4));
          double stop_loss_Price = entryPrice+12*poin;

          executeTrade("sell", cur, 10, 100, 0, stop_loss_Price, 0.000);
          Modify_SL_TP(cur, comment, 12, (12*1.82));
          SendJournal(cur, "sell", ticketNum_, commission_, lotSize_, "", 12, (12*1.82));
        }
      }
    }
  }


  latestUpdateMinute = Minute();
  return(0);
}


//  Check orders
int currency_open_orders (string currency)
{
  int currency_orders = 0;
  for(int i=0;i<OrdersTotal();i++) {
    int order = OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
    if (OrderComment() == comment && OrderSymbol() == currency) currency_orders++;
  }
  return currency_orders;
}

//  All orders
int all_open_orders ()
{
  int orderplaced = 0;
  for(int i=0;i<OrdersTotal();i++) {
    int order = OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
    if (OrderComment() == comment) orderplaced++;
    }
  return orderplaced;
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
        Alert(lotSize);
        int openOrderID = OrderSend(symbol, OP_SELL, lotSize, entryPrice, 20, 0.000, 0.000, comment, magicNB, 0, 0);
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // sell
    if(orderType == "buy" && pendingOrderPrice == 0.0)
    {
        double entryPrice = MarketInfo(symbol, MODE_BID);
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        Alert(lotSize);
        int openOrderID = OrderSend(symbol, OP_BUY, lotSize, entryPrice, 20, 0.000, 0.000, comment, magicNB, 0, 0);
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // buystop
    if(orderType == "buystop")
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_BUYSTOP, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, comment, magicNB, 0, 0);
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // sellstop
    if(orderType == "sellstop")
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_SELLSTOP, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, comment, magicNB, 0, 0);
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // buylimit
    if(orderType == "buylimit")
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_BUYLIMIT, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, comment, magicNB, 0, 0);
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }

    // selllimit
    if(orderType == "selllimit")
    {
        double entryPrice = pendingOrderPrice;
        double lotSize = CalculateLotSize(symbol, riskPerTradeDollars, entryPrice, stopLossPrice);
        int openOrderID = OrderSend(symbol, OP_SELLLIMIT, lotSize, entryPrice, 20, stopLossPrice, takeProfitPrice, comment, magicNB, 0, 0);
        if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
        return openOrderID;
    }
  }
  return(0);
}

//+------------------------------------------------------------------+

// custom re-usable functions

double GetPipValue(string symbol) {
  double Poin;
  int vdigits = (int)MarketInfo(symbol, MODE_DIGITS);
  if (vdigits >= 4) Poin = 0.0001;
    else {
        if (vdigits == 3) Poin = 0.01;
        else {
          if (vdigits == 2) Poin = 0.1;
          else {
              if (vdigits == 1) Poin = 1;
              else Poin = 0;
          }
        }
    }
  return Poin;
}

double CalculateLotSize(string symbol, double riskDollars, double entryPrice, double slPrice)
{
  Alert( " symbol: " ,symbol , " risk : ", riskDollars,  " entry : ", entryPrice,  " sl : ",slPrice);

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

double stoploss_Price;
double takeprofit_Price;
int Modify_SL_TP(string cur, string comment_, double sl, double tp) {
   double Poin = GetPipValue(cur);
//----
   int ordertotal = OrdersTotal();
   for (int i=0; i<ordertotal; i++)
   {
      int order = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderComment() == comment_ && (OrderType()==OP_BUY || OrderType()==OP_BUYSTOP)) {
        if (sl==0.0) stoploss_Price = 0.0;
        else stoploss_Price = OrderOpenPrice()-sl*Poin;

        if (tp==0.0) takeprofit_Price = 0.0;
        else takeprofit_Price = OrderOpenPrice()+tp*Poin;

        int ticket = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss_Price, takeprofit_Price, 0);
        ticketNum_ = OrderTicket();
        commission_ = OrderCommission();
        lotSize_ = OrderLots();
      }

      if (OrderComment() == comment_ && (OrderType()==OP_SELL || OrderType()==OP_SELLSTOP)) {
        if (sl==0.0) stoploss_Price = 0.0;
        else stoploss_Price = OrderOpenPrice()+sl*Poin;

        if (tp==0.0) takeprofit_Price = 0.0;
        else takeprofit_Price = OrderOpenPrice()-tp*Poin;

        int ticket = OrderModify(OrderTicket(), OrderOpenPrice(), stoploss_Price, takeprofit_Price, 0);
        ticketNum_ = OrderTicket();
        commission_ = OrderCommission();
        lotSize_ = OrderLots();
      }
  }
//----
return(0);
}

// common custom functions
double checkSpread(string currency) {
  double spread_value = NormalizeDouble(MarketInfo(currency, MODE_SPREAD), 2);
  return spread_value;
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
   double closePrice = iClose(currency, timef, 1);

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

string openAboveBelowEMA (string cur, int timef, int movingAVG) {
  double open = iOpen(cur, timef, 1);

  double ema = iMA(cur,timef,movingAVG,0,MODE_EMA,PRICE_CLOSE,0);
  string situation = "";
  if (open > ema) situation = "buy";
  if (open < ema) situation = "sell";
  return situation;
}
string closeAboveBelowEMA (string cur, int timef, int movingAVG) {
  double close = iClose(cur, timef, 1);

  double ema = iMA(cur,timef,movingAVG,0,MODE_EMA,PRICE_CLOSE,0);
  string situation = "";
  if (close > ema) situation = "buy";
  if (close < ema) situation = "sell";
  return situation;
}
// picture of power
string pop(string cur, int timef) {
  string pop_status;

  if (closeAboveBelowEMA(cur, timef, 200) == "buy" && closeAboveBelowEMA(cur, timef, 20) == "buy" && openAboveBelowEMA(cur, timef, 20) == "buy") {
    pop_status = "buy";
  }
  if (closeAboveBelowEMA(cur, timef, 200) == "sell" && closeAboveBelowEMA(cur, timef, 20) == "sell"  && openAboveBelowEMA(cur, timef, 20) == "sell") {
    pop_status = "sell";
  }

  return pop_status;
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
  if (buy_or_sell == " ") return NULL;
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

double candlestick(string currency, int timef, int shift) {
  double openPrice = iOpen(currency,timef,shift);
  double closePrice =  iClose(currency,timef,shift);
  double highPrice =  iHigh(currency,timef,shift);
  double lowPrice =  iLow(currency,timef,shift);

  return priceDifferencePips(openPrice, closePrice, GetPipValue(currency));
}

double priceDifferencePips(double price1, double price2, double Poin) {
  double difference = price1 - price2;
  difference = MathAbs(difference);
  double pips = difference/Poin;
  return pips;
}


/// API CALL
string url = "https://a83a-41-90-187-242.eu.ngrok.io";
int SendJournal(string instrument, string orderType, int ticketNum, double commission, double lotSize, string link, double sl, double tp) {
   int D1 = EMAtrend(instrument, 1440, 8, 7);
   int H4 = EMAtrend(instrument, 240, 8, 9);
   int H1 = EMAtrend(instrument, 60, 8, 13);
   int M15 = EMAtrend(instrument, 15, 8, 15);

   double accumulate = addPoints(instrument);

   double total = ((D1 + H4 + H1 + M15) / 4 + accumulate) / 2;
   double avg = NormalizeDouble(total , 2);

   string data = StringConcatenate(
      "&accumulate=" + accumulate +"&"+

      "d1close=" + PriceAboveBelowClose(instrument, 1440, 1) +"&"+
      "h4close=" + PriceAboveBelowClose(instrument, 240, 1) +"&"+
      "h1close=" + PriceAboveBelowClose(instrument, 60, 1) +"&"+
      "m15close=" + PriceAboveBelowClose(instrument, 15, 1) +"&"+

      "d1prev=" + check_prev_candle(instrument, 1440, 1) +"&"+
      "h4prev=" + check_prev_candle(instrument, 240, 1) +"&"+
      "h1prev=" +  check_prev_candle(instrument, 60, 1) +"&"+
      "m15prev=" + check_prev_candle(instrument, 15, 1) +"&"+

      "d1200ema=" + closeAboveBelowEMA(instrument, 1440, 200) +"&"+
      "h4200ema=" + closeAboveBelowEMA(instrument, 240, 200) +"&"+
      "h1200ema=" + closeAboveBelowEMA(instrument, 60, 200) +"&"+
      "m15200ema=" + closeAboveBelowEMA(instrument, 15, 200) +"&"+

      "d150sma=" + closeAboveBelowSMA(instrument, 1440, 50) +"&"+
      "h450sma=" + closeAboveBelowSMA(instrument, 240, 50) +"&"+
      "h150sma=" + closeAboveBelowSMA(instrument, 60, 50) +"&"+
      "m1550sma=" + closeAboveBelowSMA(instrument, 15, 50) +"&"+

      "d18ema=" + PriceAboveBelowEMA(instrument, 1440, 8) +"&"+
      "h48ema=" + PriceAboveBelowEMA(instrument, 240, 8) +"&"+
      "h18ema=" + PriceAboveBelowEMA(instrument, 60, 8) +"&"+
      "m158ema=" + PriceAboveBelowEMA(instrument, 15, 8) +"&"+

      "d120ema=" +closeAboveBelowEMA(instrument, 1440, 20) +"&"+
      "h420ema=" +closeAboveBelowEMA(instrument, 240, 20) +"&"+
      "h120ema=" +closeAboveBelowEMA(instrument, 60, 20) +"&"+
      "m1520sma=" + closeAboveBelowSMA(instrument, 15, 20) +"&"+

      "d1env=" + environment(instrument,1440) +"&"+
      "h4env=" + environment(instrument,240) +"&"+
      "h1env=" + environment(instrument,60) +"&"+
      "m15env=" + environment(instrument,15) +"&"+
      "image1=" + link +"&"+
      "ticketnum=" + ticketNum +"&"+
      "commission=" + commission +"&"+
      "lotsize=" + NormalizeDouble(lotSize, 2)  +"&"+

      "trendd1=" +  D1 +"&"+
      "trendh4="  + H4 +"&"+
      "trendh1="  + H1 +"&"+
      "trendm15=" + M15 +"&"+
      "avgtrend=" + avg
   );

   string journalAPI=StringConcatenate(url + "/api/v1/trades/users/5fbabe6d-c70a-4ecb-8e7a-de90c5c1a6e0?currency=" + instrument + "&direction="+orderType+"&slprice=" + stoploss_Price + "&tpprice=" + takeprofit_Price + "&slpips=" + sl + "&tppips=" + tp + "&rr=" + NormalizeDouble((tp/sl),2) + data);
   ResetLastError();
   MessageBox(journalAPI);
   int journal=WebRequest("POST",journalAPI,cookie,NULL,timeout,post,0,result,headers);
   if (journal != 201) MessageBox(journal);
return(0);
}