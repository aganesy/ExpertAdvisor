//+------------------------------------------------------------------+
//|                                                          CCI.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library

#include "..\_Include\Define.mqh"


// CCI
int IsCCI(int n, int period = 14)
{
   double CCI0 = iCCI(NULL, 0, 14, PRICE_CLOSE, n);
   double CCI1 = iCCI(NULL, 0, 14, PRICE_CLOSE, n + 1);
   
   if (CCI0 >= -100 && CCI1 < -100){
      return (GOBUY);
   }
   if (CCI0 <=  100 && CCI1 >  100){
      return (GOSELL);
   }
}






