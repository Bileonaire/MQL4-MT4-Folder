//+------------------------------------------------------------------+
//|                                                    BEManager.mq4 |
//|                                      Copyright 2020, Lenny Kioko |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lenny Kioko"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

//external parameters to be provided

extern double targetPrice = 0.0;
int bePips = 1.0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  Print("Starting BEManager BOT on: " + Symbol());
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  Print("Stopping BEManager BOT on: " + Symbol());
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  if(IsTradingAllowed() && CheckIfOpenOrdersBySymbol(Symbol()) && OrderType() == OP_BUY && Close[1] >= targetPrice)
  {
    ProfitableSL();
  }

  if(IsTradingAllowed() && CheckIfOpenOrdersBySymbol(Symbol()) && OrderType() == OP_SELL && Close[1] <= targetPrice)
  {
    ProfitableSL();
  }


}
//+------------------------------------------------------------------+

double GetPipValue()
{
  if(_Digits >= 4)
  {
    return 0.0001;
  }
  else
  {
    return 0.01;
  }
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

bool CheckIfOpenOrdersBySymbol(string symbol)
{
  int openOrders = OrdersTotal();

  for(int i=0; i < openOrders; i++)
  {
    if(OrderSelect(i, SELECT_BY_POS) == true)
    {
      if(Symbol() == symbol)
      {
        return true;
      }
    }
  }
  return false;
}

void ProfitableSL()
{
  int orderTotal = OrdersTotal();
  for (int i=0; i<orderTotal; i++)
  {
    int order = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    if(OrderSymbol() == Symbol())
    {
      if(OrderType() == OP_BUY)
      {
        double beSlPrice =  NormalizeDouble(OrderOpenPrice() + (bePips * GetPipValue()), _Digits);
        if(OrderStopLoss() != beSlPrice)
        {
          int ticket = OrderModify(OrderTicket(), OrderOpenPrice(), beSlPrice, OrderTakeProfit(), 0);
          if(ticket < 0) Alert("orderModify rejected. Order error: " + GetLastError());

        }
      }

      if(OrderType() == OP_SELL)
      {
        double beSlPrice =  NormalizeDouble(OrderOpenPrice() - (bePips * GetPipValue()), _Digits);
        if(OrderStopLoss() != beSlPrice)
        {
          int ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), beSlPrice, OrderTakeProfit(), 0);
          if(ticket2 < 0) Alert("orderModify rejected. Order error: " + GetLastError());
        }
      }
    }
  }
}