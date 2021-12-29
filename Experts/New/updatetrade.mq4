//+------------------------------------------------------------------+
//|                                                 TradeManager.mq4 |
//|                                             Copyright 2021, Leon |
//|                  https://github.com/Bileonaire/RemoteMT4Executor |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2021, Bileonaire"
#property link      "https://github.com/Bileonaire/"
#property description "Manage Trade"
#property version   "1.00"
#property strict
#property show_inputs

#include <stderror.mqh>
#include <stdlib.mqh>

extern double RR_Ratio = 1.5;
extern double newSLPips = 2;

extern string url = "https://8188-41-212-47-64.ngrok.io";

int openTrades;
int ordertotal;
int trades[15] = {};

double latestUpdateMinute;

string chatId3 = "-1001366966111";  // bileonaire_fx -- Small group with Tom
string chatId4 = "-1001662752776"; // Leon Private group
//+------------------------------------------------------------------+sd
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick() {
    // if (latestUpdateMinute != Minute() && updateTime(Minute())) {
        manageTrades();
    // }
    // latestUpdateMinute = Minute();
    // return;
}

bool updateTime (int minute) {
    if (minute % 1 == 0) return true;
    else return false;
}

int manageTrades() {
    ordertotal = OrdersTotal();

    for (int i=0 ; i <ordertotal; i++) {
        int order = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            int ticket = checkTradesArray(OrderTicket());
            if (!ticket) addToTradesArray(OrderTicket());
    }

    // check if trade exited
    checkClosed();
return(0);
}

int checkTradesArray (int ticket) {
    for(int i = 0; i < ArraySize(trades); i++) {
      if (trades[i] == ticket)
        {
         return trades[i];
        }
    }
    return 0;
}

int addToTradesArray (int ticket) {
    for(int i = 0; i < ArraySize(trades); i++) {
      if (trades[i] == 0)
        {
            trades[i] = ticket;
            return 1;
        }
    }
    return 0;
}

int checkClosed () {
    for(int i = 0; i < ArraySize(trades); i++) {
        if(trades[i] != 0) {
            if(OrderSelect(trades[i], SELECT_BY_TICKET)==true) {
                if(OrderType()!=OP_SELLLIMIT || OrderType()!=OP_SELLSTOP || OrderType()!=OP_BUYSTOP || OrderType()!=OP_BUYLIMIT ) {
                    if (OrderCloseTime() != 0) {
                        int journalClose = SendJournal(OrderTicket(), OrderCommission(), OrderSwap(), TimeGMT(), OrderClosePrice(), OrderProfit());
                        //if ( journalClose != 200 ) MessageBox(journalClose);
                        trades[i] = 0;
                    }
                }
            }
        }
    }
    return 0;
}

int SendJournal(int ticket, double commission, double swap, datetime  closeTime, double closePrice, double profit) {
    string cookie=NULL,headers;
    char post[],result[];
    int timeout=5000;
    double comm = commission + swap;

    string data = StringConcatenate(
        "closePrice=" + closePrice +"&"+
        "commission=" + comm +"&"+
        "closedAt=" + closeTime +"&"+
        "profit=" + profit
    );

    string journalAPI=StringConcatenate(url + "/api/updatetrade/" + ticket + "?" + data);
    ResetLastError();
    int journal=WebRequest("GET",journalAPI,cookie,NULL,timeout,post,0,result,headers);
    return journal;
}

double CalculateRR(string symbol, double entryPrice, double slPrice, double currentPrice)
{
  double pipsToSL = MathAbs(entryPrice - slPrice) / GetPipValue(symbol);
  double pipsToCurrent = MathAbs(entryPrice - currentPrice) / GetPipValue(symbol);

  double RiskReward = pipsToCurrent/pipsToSL;

  return RiskReward;
}

//+------------------------------------------------------------------+

// custom re-usable functions

// works for fx pairs, may not work for indices
double GetPipValue(string symbol)
{
  int vdigits = (int)MarketInfo( symbol, MODE_DIGITS);
  if(vdigits >= 4)
  {
    return 0.0001;
  }
  else
  {
    return 0.01;
  }
}

int SendSignal(string message) {
   string cookie=NULL,headers;
   char post[],result[];
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection
   string bileonaire_fx_free=StringConcatenate("https://api.telegram.org/bot1283891993:AAGa9NV3ntsmIRj89yHSGCb-znW5WUhpJio/sendMessage?chat_id="+chatId3+"&text="+message+"&parse_mode=html");
   ResetLastError();
   int free=WebRequest("POST",bileonaire_fx_free,cookie,NULL,timeout,post,0,result,headers);
return(0);
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

  double buyPercent = (accumulate/20)*100;
  string percent = DoubleToStr(buyPercent, 2);
  return percent;
}