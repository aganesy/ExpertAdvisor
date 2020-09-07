//+------------------------------------------------------------------+
//|                                                   WindowPlum.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


// MyInclude
#include "MyInclude\Define.mqh"


// MyLib
#import "MyLib\MyPosition.ex4"
   void GetPositionBUY(double mLot = 0);
   void GetPositionSELL(double mLot = 0);
   void MyOrderClose();
   int Emergency(int pips = CLOSE_PIPS);
   
#import "MyLib\ParabolicSAR.ex4"
   int ParabolicTrend(double SAR_Maximum=0.2, double SAR_Step=0.02, int n = 0);
   
#import "MYLib\HeikinAshi.ex4"
   double HeikinAshiOpen(int n = 0);
   double HeikinAshiClose(int n = 0);
   
   
#define ON  1
#define OFF 0

#define NONE   3

double compareWindowSize = 9999;
double WindowSize = 9999;
double harfWindowSize = 9999;
double lot = 0;


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if (Symbol() == "USDJPY"){
      compareWindowSize = 0.015;
      lot = 0.2;
   }
   if (Symbol() == "EURJPY"){
      compareWindowSize = 0.020;
      lot = 0.2;
   }
   if (Symbol() == "EURUSD"){
      compareWindowSize = 0.00015;
      lot = 0.2;
   }
   if (Symbol() == "EURGBP"){
      compareWindowSize = 0.00015;
      lot = 0.2;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

int start()
{
   static int mode;
   
   static int windowOpen_flag    = OFF;
   static int windowGo_flag      = OFF;
   
   static int windowClose_flag   = OFF;
   static int heikinashi_flag    = OFF;
   static int parabolic_flag     = OFF;
   
   static int OrderEnd_flag      = OFF;
   
   
   static double Saturday_Close  = 0;
   static double Monday_Open     = 0;
   
//----
   
   WindowSize = iOpen(NULL, PERIOD_D1, 0) - iClose(NULL, PERIOD_D1, 1);
   harfWindowSize = WindowSize / 2;
   
   if (DayOfWeek() != 1){
      OrderEnd_flag = OFF;
   }
      
   windowOpen_flag = OpenFlagDetect(OrderEnd_flag);
   
   if (windowOpen_flag == ON){
      mode = ModeDetect();
      
      if (mode != NONE){
         Saturday_Close = iClose(NULL, PERIOD_D1, 1);
         Monday_Open    = iOpen(NULL, PERIOD_D1, 0);
      }
   }
   
   windowGo_flag = GoFlagDetect(windowOpen_flag, mode, Monday_Open);
   
   if (windowGo_flag == ON){
      switch (mode){
      case GOBUY:
         GetPositionBUY(lot);
         break;
         
      case GOSELL:
         GetPositionSELL(lot);
         break;
      }
   }
   
   //-- Position_Buck
   if (Emergency(-400) == true){
      windowClose_flag  = OFF;
      heikinashi_flag   = OFF;
      parabolic_flag    = OFF;
      OrderEnd_flag     = ON;
   }
   
   if (OrdersTotal() != 0){
      if (OrderSelect(0, SELECT_BY_POS) == true){
         switch (OrderType()){
         case OP_BUY:
            if (Close[1] > Saturday_Close){
               windowClose_flag = ON;
               if (HeikinAshiOpen(1) <= HeikinAshiClose(1) && HeikinAshiOpen(0) >= HeikinAshiClose(0)){
                  heikinashi_flag = ON;
               }
               if (ParabolicTrend(0.2, 0.02, 0) == GOSELL){
                  parabolic_flag = ON;
               }
            }
            
            if (windowClose_flag == ON && heikinashi_flag == ON && parabolic_flag == ON){
               windowClose_flag  = OFF;
               heikinashi_flag   = OFF;
               parabolic_flag    = OFF;
               OrderEnd_flag     = ON;
               MyOrderClose();
            }
            else if (windowClose_flag == ON && Close[1] < Saturday_Close){
               windowClose_flag  = OFF;
               heikinashi_flag   = OFF;
               parabolic_flag    = OFF;
               OrderEnd_flag     = ON;
               MyOrderClose();
            }
            break;
         case OP_SELL:
            if (Close[1] < Saturday_Close){
               windowClose_flag = ON;
               if (HeikinAshiOpen(1) >= HeikinAshiClose(1) && HeikinAshiOpen(0) <= HeikinAshiClose(0)){
                  heikinashi_flag = ON;
               }
               if (ParabolicTrend(0.2, 0.02, 0) == GOBUY){
                  parabolic_flag = ON;
               }
            }
            
            if (windowClose_flag == ON && heikinashi_flag == ON && parabolic_flag == ON){
               windowClose_flag  = OFF;
               heikinashi_flag   = OFF;
               parabolic_flag    = OFF;
               OrderEnd_flag     = ON;
               MyOrderClose();
            }
            else if (windowClose_flag == ON && Close[1] > Saturday_Close){
               windowClose_flag  = OFF;
               heikinashi_flag   = OFF;
               parabolic_flag    = OFF;
               OrderEnd_flag     = ON;
               MyOrderClose();
            }
            break;
         }
      }
   }
   
   
   
   
//----
   return(0);
}
//+------------------------------------------------------------------+

int OpenFlagDetect(int OrderEnd_flag)
{
   if (OrderEnd_flag == ON){
      return (OFF);
   }
   if (DayOfWeek() == 1 && OrdersTotal() == 0){
      if (WindowSize >  compareWindowSize || 
          WindowSize < compareWindowSize * (-1)){
         return (ON);
      }
   }
   
   if (DayOfWeek() != 0){
      return (OFF);
   }
   
   return (NONE);
}

int ModeDetect()
{
   if (WindowSize > compareWindowSize){
      return (GOSELL);
   } 
   if (WindowSize < compareWindowSize * (-1)){
      return (GOBUY);
   }
   
   return (NONE);
}

int GoFlagDetect(int open_flag, int mode, double monday)
{
   if (DayOfWeek() >= 4){
      return (OFF);
   }
   
   if (open_flag == ON){
      switch (mode){
      case GOBUY:
         //if (Close[0] /* + harfWindowSize */ >= monday){
         if (Close[0] <= monday && HeikinAshiOpen(2) >= HeikinAshiClose(2) && 
               HeikinAshiOpen(1) >= HeikinAshiClose(1) && HeikinAshiOpen(0) <= HeikinAshiClose(0)){
            return (ON);
         }
         break;
      case GOSELL:
         //if (Close[0] /* + harfWindowSize */ <= monday){
         if (Close[0] >= monday && HeikinAshiOpen(2) <= HeikinAshiClose(2) && 
               HeikinAshiOpen(1) <= HeikinAshiClose(1) && HeikinAshiOpen(0) >= HeikinAshiClose(0)){
            return (ON);
         }
         break;
      }
   }
   
   return (NONE);
}

