//+------------------------------------------------------------------+
//|                                                             Test |
//|                                 Copyright © 2022, FX Masterminds |
//|                                   https://bileonaire.github.io/" |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2020, FX Masterminds."
#property link      "https://bileonaire.github.io/"

//show input parameter
#property show_inputs

double Poin;

//+------------------------------------------------------------------+
//| Custom initialization function                                   |
//+------------------------------------------------------------------+
int init() {
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
   return(0);
}

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

int start() {
   testFunction();
}

int testFunction() {
//----
    int vdigits = (int)MarketInfo(Symbol(), MODE_DIGITS);

    MessageBox(Point);
    MessageBox(vdigits);

    MessageBox(Poin);
//----
return(0);
}