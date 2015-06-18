//+------------------------------------------------------------------+
//|                                                 ParabolicSAR.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library

#include "..\_Include\Define.mqh"

#import "OrderType.ex4"


// InportFunction
#import "HeikinAshi.ex4"
   double HeikinAshiOpen(int n = 0);
   double HeikinAshiClose(int n = 0);


// Parabolic_SAR
int IsParabolic(double SAR_Maximum=0.2, double SAR_Step=0.02)
{
   double SAR0 = iSAR(NULL, 0, SAR_Step, SAR_Maximum, 0);
   double SAR1 = iSAR(NULL, 0, SAR_Step, SAR_Maximum, 1);
   double SAR2 = iSAR(NULL, 0, SAR_Step, SAR_Maximum, 2);
   //double Close0 = iClose(NULL, 0, 0);
   //double Close1 = iClose(NULL, 0, 1);
   
   if ((SAR0 < Close[0] && SAR1 > Close[1])){
      return (GOBUY);
   }
   if ((SAR0 > Close[0] && SAR1 < Close[1])){
      return (GOSELL);
   }
   return (QUO);
}

int ParabolicTrend(double SAR_Maximum=0.2, double SAR_Step=0.02, int n = 0)
{
   double SAR = iSAR(NULL, 0, SAR_Step, SAR_Maximum, n);
   
   if (SAR < Close[0]){
      return (GOBUY);
   }
   if (SAR > Close[0]){
      return (GOSELL);
   }
   return (QUO);
}

int ParabolicObserverBack(double SAR_Maximum=0.2, double SAR_Step=0.02)
{
   //int type;
   
   double heikinAshiOpen;
   double heikinAshiClose;
   double heikinAshiDiff;
   
   //heikinAshiOpen  = iCustom(NULL,0,"Heiken Ashi",2,0);
   //heikinAshiClose = iCustom(NULL,0,"Heiken Ashi",3,0);
   heikinAshiOpen  = HeikinAshiOpen(0);
   heikinAshiClose = HeikinAshiClose(0);
   heikinAshiDiff = heikinAshiOpen - heikinAshiClose;
   
   if (OrdersTotal() > 0){
      if (OrderSelect(0, SELECT_BY_POS) == true){
         if ((-0.001 < heikinAshiDiff && heikinAshiDiff < 0.001) || ParabolicMomentum(SAR_Maximum, SAR_Step) == BACK){
            return (BACK);
         }
      }   
   }
   
   return (QUO);
}

int ParabolicMomentum(double SAR_Maximum=0.2, double SAR_Step=0.02)
{
   double SAR0 = iSAR(NULL, 0, SAR_Step, SAR_Maximum, 0);
   double SAR1 = iSAR(NULL, 0, SAR_Step, SAR_Maximum, 1);
   double SAR2 = iSAR(NULL, 0, SAR_Step, SAR_Maximum, 2);
   
   if (SAR0 > Close[0] && SAR1 > Close[1] && SAR2 > Close[2]){
      if ((SAR2 - SAR1) > (SAR1 - SAR0)){
         return (BACK);
      }
   }
   if (SAR0 < Close[0] && SAR1 < Close[1] && SAR2 < Close[2]){
      if ((SAR1 - SAR2) > (SAR0 - SAR1)){
         return (BACK);
      }
   }
   
   return (QUO);
}



