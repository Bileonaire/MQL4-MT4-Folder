//+------------------------------------------------------------------+
//|                                           Environment Switch.mq4 |
//|                                                       Bileonaire |
//|                                                         leon.com |
//+------------------------------------------------------------------+
#property copyright "Bileonaire"
#property link      "leon.com"
#property version   "1.00"
#property strict


enum e_switch_to{
 Buy_Environment=1,
 Sell_Environment=2,
};

enum e_timeframe{
 M15=15,
 H1=60,
 H4=240,
};

enum e_switch_first{
 Yes=0,
 No=3,
};

input e_switch_to switch_to = Buy_Environment;
input e_timeframe timeframe = M15;
extern string Note = "If switch_first to opposite approach needed - ensure you are in specified timeframe";
input e_switch_first switch_first = No;

//Switch to what environment

int switchie;
double close = 0.0;
int sent = 1;
int OnInit() {
  switchie = switch_first;
  return 0;
}

void OnDeinit(const int reason) {}

void OnTick()
  {
    if (switch_to == Buy_Environment && sent && switched_first(Symbol(),timeframe)) {
      if (environment(Symbol(),timeframe) == "buy") {
        string buy_message = Symbol() + " is now in a buy environment on " + EnumToString(timeframe);
        SendSignal(buy_message);
        MessageBox(buy_message);
      }
    }

    if (switch_to == Sell_Environment && sent && switched_first(Symbol(),timeframe)) {
      if (environment(Symbol(),timeframe) == "sell") {
        string sell_message = Symbol() + " is now in a sell environment on " + EnumToString(timeframe);
        SendSignal(sell_message);
        MessageBox(sell_message);
      }
    }
  }
//+------------------------------------------------------------------+

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
//+------------------------------------------------------------------+

int switched_first (string currency, int timef)
{
  int good = 0;
  if (switchie == 3) good = 1;
  if (switchie == 0 && close != Close[1]) {
    close = Close[1];
    double MacdCurrent = iMACD(currency,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
    double twenty_ema = iMA(currency,0,20,0,MODE_EMA,PRICE_CLOSE,0);
    double ten_ema = iMA(currency,0,10,0,MODE_EMA,PRICE_CLOSE,0);
    // double price = MarketInfo(currency,MODE_ASK);

  // sell env switch to BUY env first
    if (switch_to == Sell_Environment) {
      if (MacdCurrent > 0 || ten_ema > twenty_ema) {
        good = 1;
        switchie = 3;
      }
    }
  // buy env switch to Sell env
    if (switch_to == Buy_Environment) {
      if (MacdCurrent < 0 || ten_ema < twenty_ema) {
        good = 1;
        switchie = 3;
      }
    }
  }
  return good;
}



int SendSignal(string message) {
//----
   string chatId = "-1001366966111";  // bileonaire_fx
   string cookie=NULL,headers;
   char post[],result[];
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection

   string bileonaire_fx_free=StringConcatenate("https://api.telegram.org/bot1283891993:AAGa9NV3ntsmIRj89yHSGCb-znW5WUhpJio/sendMessage?chat_id="+chatId+"&text="+message+"&parse_mode=html");
   ResetLastError();
   int free=WebRequest("POST",bileonaire_fx_free,cookie,NULL,timeout,post,0,result,headers);
   if (free == 200) sent = 0;
return(0);
}
