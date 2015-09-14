//+------------------------------------------------------------------+
//|                                           BollingerBands.mqh.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library

#include "..\_Include\Define.mqh"


// Bollinger_Bands
int BandsExValue(int deviation = 2)
{
   if (iBands(NULL, 0, 20, deviation, 0, PRICE_LOW, MODE_LOWER, 0) > Low[0]){
      return (GOBUY);
   }
   if (iBands(NULL, 0, 20, deviation, 0, PRICE_HIGH, MODE_UPPER, 0) > High[0]){
      return (GOSELL);
   }
}







