//+------------------------------------------------------------------+
//|                                                 TripleWindow.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library

#include "..\_Include\Define.mqh"


// Triple_Window
int TripleWindow()
{
	int count;

	count = 0;
	for (int i = 0; i < 4; i++){
		if (Open[i] > High[i + 1] || Low[i] > Close[i + 1]){
			count++;
		}
	}
	if (3 <= count){
		return (GOSELL);
	}

	count = 0;
	for (i = 0; i < 4; i++){
		if (Open[i] < Low[i + 1] || High[i] < Close[i + 1]){
			count++;
		}
	}
	if (3 <= count){
		return (GOBUY);
	}
}

