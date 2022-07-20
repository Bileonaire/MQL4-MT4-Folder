//+------------------------------------------------------------------+
//|                                                TargetReacher.mq4 |
//|                                      Copyright 2020, Lenny Kioko |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lenny Kioko"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

extern double targetEquity = 0.0;
extern bool closeAllTrades = true;
extern bool sendNotifications = true;
extern bool openAlertBox = true;

string botToken = "";
string chatId = "";

string msg = "Congratulations! Profit Target Achieved";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  Print("Starting TargetReacher BOT on: " + Symbol());
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  Print("Stopping TargetReacher BOT on: " + Symbol());
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  if(IsTradingAllowed())
  {
    if(AccountEquity() >= targetEquity)
    {
      if(closeAllTrades == true) Close_All();
      if(sendNotifications == true) SendNotification(msg);
      if(sendNotifications == true) sendSignal(msg);
      if(openAlertBox == true) Alert(msg);
    }
  }
}

//+------------------------------------------------------------------+

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

void Close_All()
{
  int ordertotal = OrdersTotal();
  RefreshRates();

  for (int i=0 ; i <= ordertotal; i++)
  {
    RefreshRates();
    int order = OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
    if(OrderType() == OP_BUY)
      int buy = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Violet);
    if(OrderType()==OP_SELL)
      int sell = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Violet);
    if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
      int stop = OrderDelete(OrderTicket());
  }
}

void sendSignal(string message)
{
  string cookie = NULL, headers;
  char post[], result[];

  int timeout = 5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection

  string url = "https://api.telegram.org/bot" + botToken + "/sendMessage?chat_id=" + chatId + "&text=" + message + "&parse_mode=html";
  ResetLastError();
  int send = WebRequest("POST", url, cookie, NULL, timeout, post, 0, result, headers);
}