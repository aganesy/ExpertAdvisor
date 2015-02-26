//+------------------------------------------------------------------+
//|                                                          RSI.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library

#include "..\_Include\Define.mqh"



// RSI
// ReturnValue >=  20 : Bid!
// ReturnValue <= -20 : Ask!
int RSIExValue(int n = 0)
{
   return (iRSI(NULL, 0, 14, PRICE_CLOSE, n) - 50);
}








