//+------------------------------------------------------------------+
//|                                                   HeikinAshi.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library

#include "..\_Include\Define.mqh"


// Heikin Ashi

double HeikinAshiOpen(int n = 0)
{
   return (iCustom(NULL,0,"Heiken Ashi",2,n));
}

double HeikinAshiClose(int n = 0)
{
   return (iCustom(NULL,0,"Heiken Ashi",3,n));
}

double HeikinAshiDiff(int n = 0)
{
   return (HeikinAshiOpen(n) - HeikinAshiClose(n));
}


