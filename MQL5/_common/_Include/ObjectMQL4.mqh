//+------------------------------------------------------------------+
//|                                                       Define.mqh |
//|                                   Copyright 2013, SENAGA Yusuke. |
//|                                               mi081321@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, SENAGA Yusuke."
#property link      "mi081321@gmail.com"

#include "initMQL4.mqh"

#define OBJPROP_TIME1       (10000 + 0)
#define OBJPROP_PRICE1      (10000 + 1)
#define OBJPROP_TIME2       (10000 + 2)
#define OBJPROP_PRICE2      (10000 + 3)
#define OBJPROP_TIME3       (10000 + 4)
#define OBJPROP_PRICE3      (10000 + 5)
#define OBJPROP_FIBOLEVELS  (10000 + 200)

bool ObjectCreate(string name,
                      ENUM_OBJECT type,
                      int window,
                      datetime time1,
                      double price1,
                      datetime time2=0,
                      double price2=0,
                      datetime time3=0,
                      double price3=0)
{
    return(ObjectCreate(0,name,type,window,
           time1,price1,time2,price2,time3,price3));
}

bool ObjectDelete(string name)
{
    return(ObjectDelete(0,name));
}

string ObjectDescription(string name)
{
    return(ObjectGetString(0,name,OBJPROP_TEXT));
}

int ObjectFind(string name)
{
    return(ObjectFind(0,name));
}
  
double ObjectGet(string name,
                     int index)
{
    switch(index)
    {
        case OBJPROP_TIME1:
        return((double)ObjectGetInteger(0,name,OBJPROP_TIME));
        case OBJPROP_PRICE1:
        return(ObjectGetDouble(0,name,OBJPROP_PRICE));
        case OBJPROP_TIME2:
        return((double)ObjectGetInteger(0,name,OBJPROP_TIME,1));
        case OBJPROP_PRICE2:
        return(ObjectGetDouble(0,name,OBJPROP_PRICE,1));
        case OBJPROP_TIME3:
        return((double)ObjectGetInteger(0,name,OBJPROP_TIME,2));
        case OBJPROP_PRICE3:
        return(ObjectGetDouble(0,name,OBJPROP_PRICE,2));
        case OBJPROP_COLOR:
        return((double)ObjectGetInteger(0,name,OBJPROP_COLOR));
        case OBJPROP_STYLE:
        return((double)ObjectGetInteger(0,name,OBJPROP_STYLE));
        case OBJPROP_WIDTH:
        return((double)ObjectGetInteger(0,name,OBJPROP_WIDTH));
        case OBJPROP_BACK:
        return((double)ObjectGetInteger(0,name,OBJPROP_WIDTH));
        case OBJPROP_RAY:
        return((double)ObjectGetInteger(0,name,OBJPROP_RAY_RIGHT));
        case OBJPROP_ELLIPSE:
        return((double)ObjectGetInteger(0,name,OBJPROP_ELLIPSE));
        case OBJPROP_SCALE:
        return(ObjectGetDouble(0,name,OBJPROP_SCALE));
        case OBJPROP_ANGLE:
        return(ObjectGetDouble(0,name,OBJPROP_ANGLE));
        case OBJPROP_ARROWCODE:
        return((double)ObjectGetInteger(0,name,OBJPROP_ARROWCODE));
        case OBJPROP_TIMEFRAMES:
        return((double)ObjectGetInteger(0,name,OBJPROP_TIMEFRAMES));
        case OBJPROP_DEVIATION:
        return(ObjectGetDouble(0,name,OBJPROP_DEVIATION));
        case OBJPROP_FONTSIZE:
        return((double)ObjectGetInteger(0,name,OBJPROP_FONTSIZE));
        case OBJPROP_CORNER:
        return((double)ObjectGetInteger(0,name,OBJPROP_CORNER));
        case OBJPROP_XDISTANCE:
        return((double)ObjectGetInteger(0,name,OBJPROP_XDISTANCE));
        case OBJPROP_YDISTANCE:
        return((double)ObjectGetInteger(0,name,OBJPROP_YDISTANCE));
        case OBJPROP_FIBOLEVELS:
        return((double)ObjectGetInteger(0,name,OBJPROP_LEVELS));
        case OBJPROP_LEVELCOLOR:
        return((double)ObjectGetInteger(0,name,OBJPROP_LEVELCOLOR));
        case OBJPROP_LEVELSTYLE:
        return((double)ObjectGetInteger(0,name,OBJPROP_LEVELSTYLE));
        case OBJPROP_LEVELWIDTH:
        return((double)ObjectGetInteger(0,name,OBJPROP_LEVELWIDTH));
    }
    
    return 0;
}

string ObjectGetFiboDescription(string name,
                                    int index)
{
    return(ObjectGetString(0,name,OBJPROP_LEVELTEXT,index));
}

int ObjectGetShiftByValue(string name,
                              double value)
{
    ENUM_TIMEFRAMES timeframe=TFMigrate(PERIOD_CURRENT);
    datetime Arr[];
    MqlRates mql4[];
    if(ObjectGetTimeByValue(0,name,value)<0) return(-1);
    CopyRates(NULL,timeframe,0,1,mql4);
    if(CopyTime(NULL,timeframe,mql4[0].time,
       ObjectGetTimeByValue(0,name,value),Arr)>0)
       return(ArraySize(Arr)-1);
    else return(-1);
}

double ObjectGetValueByShift(string name,
                                 int shift)
{
    ENUM_TIMEFRAMES timeframe=TFMigrate(PERIOD_CURRENT);
    MqlRates mql4[];
    CopyRates(NULL,timeframe,shift,1,mql4);
    return(ObjectGetValueByTime(0,name,mql4[0].time,0));
}

bool ObjectMove(string name,
                    int point,
                    datetime time1,
                    double price1)
{
    return(ObjectMove(0,name,point,time1,price1));
}

string ObjectName(int index)
{
    return(ObjectName(0,index));
}

int ObjectsDeleteAll(int window=EMPTY,
                         int type=EMPTY)
{
    return(ObjectsDeleteAll(0,window,type));
}

bool ObjectSet(string name,
                   int index,
                   double value)
{
    switch(index)
    {
        case OBJPROP_TIME1:
        ObjectSetInteger(0,name,OBJPROP_TIME,(int)value);return(true);
        case OBJPROP_PRICE1:
        ObjectSetDouble(0,name,OBJPROP_PRICE,value);return(true);
        case OBJPROP_TIME2:
        ObjectSetInteger(0,name,OBJPROP_TIME,1,(int)value);return(true);
        case OBJPROP_PRICE2:
        ObjectSetDouble(0,name,OBJPROP_PRICE,1,value);return(true);
        case OBJPROP_TIME3:
        ObjectSetInteger(0,name,OBJPROP_TIME,2,(int)value);return(true);
        case OBJPROP_PRICE3:
        ObjectSetDouble(0,name,OBJPROP_PRICE,2,value);return(true);
        case OBJPROP_COLOR:
        ObjectSetInteger(0,name,OBJPROP_COLOR,(int)value);return(true);
        case OBJPROP_STYLE:
        ObjectSetInteger(0,name,OBJPROP_STYLE,(int)value);return(true);
        case OBJPROP_WIDTH:
        ObjectSetInteger(0,name,OBJPROP_WIDTH,(int)value);return(true);
        case OBJPROP_BACK:
        ObjectSetInteger(0,name,OBJPROP_BACK,(int)value);return(true);
        case OBJPROP_RAY:
        ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,(int)value);return(true);
        case OBJPROP_ELLIPSE:
        ObjectSetInteger(0,name,OBJPROP_ELLIPSE,(int)value);return(true);
        case OBJPROP_SCALE:
        ObjectSetDouble(0,name,OBJPROP_SCALE,value);return(true);
        case OBJPROP_ANGLE:
        ObjectSetDouble(0,name,OBJPROP_ANGLE,value);return(true);
        case OBJPROP_ARROWCODE:
        ObjectSetInteger(0,name,OBJPROP_ARROWCODE,(int)value);return(true);
        case OBJPROP_TIMEFRAMES:
        ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,(int)value);return(true);
        case OBJPROP_DEVIATION:
        ObjectSetDouble(0,name,OBJPROP_DEVIATION,value);return(true);
        case OBJPROP_FONTSIZE:
        ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(int)value);return(true);
        case OBJPROP_CORNER:
        ObjectSetInteger(0,name,OBJPROP_CORNER,(int)value);return(true);
        case OBJPROP_XDISTANCE:
        ObjectSetInteger(0,name,OBJPROP_XDISTANCE,(int)value);return(true);
        case OBJPROP_YDISTANCE:
        ObjectSetInteger(0,name,OBJPROP_YDISTANCE,(int)value);return(true);
        case OBJPROP_FIBOLEVELS:
        ObjectSetInteger(0,name,OBJPROP_LEVELS,(int)value);return(true);
        case OBJPROP_LEVELCOLOR:
        ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,(int)value);return(true);
        case OBJPROP_LEVELSTYLE:
        ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,(int)value);return(true);
        case OBJPROP_LEVELWIDTH:
        ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,(int)value);return(true);
        
        default: return(false);
    }
    return(false);
}

bool ObjectSetFiboDescription(string name,
                                  int index,
                                  string text)
{
    return(ObjectSetString(0,name,OBJPROP_LEVELTEXT,index,text));
}

bool ObjectSetText(string name,
                       string text,
                       int font_size,
                       string font="",
                       color text_color=CLR_NONE)
{
    int tmpObjType=(int)ObjectGetInteger(0,name,OBJPROP_TYPE);
    if(tmpObjType!=OBJ_LABEL && tmpObjType!=OBJ_TEXT) return(false);
    if(StringLen(text)>0 && font_size>0)
    {
        if(ObjectSetString(0,name,OBJPROP_TEXT,text)==true
            && ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size)==true)
        {
            if((StringLen(font)>0)
                && ObjectSetString(0,name,OBJPROP_FONT,font)==false)
                return(false);
            if(text_color!=CLR_NONE
                && ObjectSetInteger(0,name,OBJPROP_COLOR,text_color)==false)
                return(false);
            return(true);
        }
        return(false);
    }
    return(false);
}

int ObjectsTotal(int type=EMPTY,
                     int window=-1)
{
    return(ObjectsTotal(0,window,type));
}

int ObjectType(string name)
{
    return((int)ObjectGetInteger(0,name,OBJPROP_TYPE));
}
  