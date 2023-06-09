//+------------------------------------------------------------------+
//|                                                        SMA21.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                    VARIABLES EXTERNAS
//+------------------------------------------------------------------+
input string Valores_Media_Movil = "-------------------- Media_Móvil";
extern ENUM_MA_METHOD Tipo_Media = MODE_SMA;
extern ENUM_APPLIED_PRICE Tipo_Precio = PRICE_CLOSE;
input string Operativa = "-------------------------Operativa";
extern int Periodo_SMA = 21;
extern double Volumen = 0.02,
              Pips_TP = 200;
//+------------------------------------------------------------------+
//|                    VARIABLES GLOBALES
//+------------------------------------------------------------------+
double valor_sma = 0;
bool cruce_alcista = false,
     cruce_bajista = false;
//diapason = false;
int contador_bajista = 0,
    contador_alcista = 0,
    //cantidad_velas = 0,
    velas_confirmacion = 3,
    nuevas_velas = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
//cantidad_velas = iBars(_Symbol, _Period);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   valor_sma = iMA(_Symbol, _Period, Periodo_SMA, 0, Tipo_Media, Tipo_Precio, 1); // COGER EL VALOR DE LA SMA
//--- PARA DETERMINAR EL CRUCE ALCISTA DEL PRECIO Y LA SMA
   if(
      (Close[1] > valor_sma && Open[1] < valor_sma && !cruce_alcista && !cruce_bajista)
      ||
      (Close[1] > valor_sma && !cruce_alcista && cruce_bajista)
   )
   {
      cruce_alcista = true;
      cruce_bajista = false;
   }
//--- PARA DETERMINAR EL CRUCE BAJISTA DEL PRECIO Y LA SMA
   if(
      (Close[1] < valor_sma && Open[1] > valor_sma && !cruce_bajista && !cruce_alcista)
      ||
      (Close[1] < valor_sma && !cruce_bajista && cruce_alcista)
   )
   {
      cruce_bajista = true;
      cruce_alcista = false;
   }
//--- Conteo de velas
   if(cruce_alcista ) // CONTAR LAS VELAS QUE ESTEN POR ENCIMA DE LA MEDIA
   {
      contador_alcista = Contador_Velas( "alza");
      contador_bajista = 0;
   }
   else if(cruce_bajista )// CONTAR LAS VELAS QUE ESTEN POR DEBAJO DE LA MEDIA
   {
      contador_bajista = Contador_Velas( "baja");
      contador_alcista = 0;
   }
//--- Si hay mecha sobre la media movil y cierra la vela segun el color correspondiente
   if( Contador_Velas( "alza") == velas_confirmacion && Low[1] <= valor_sma && Close[1] > valor_sma && Close[1] > Open[1] )
   {
      int ticket_temp = OrderSend(_Symbol, OP_BUY, Volumen, Ask, 0, Low[1], Ask + Pips_TP * Point);
   }
   if(Contador_Velas( "baja") == velas_confirmacion && High[1] >= valor_sma && Close[1] < valor_sma  && Close[1] < Open[1] )
   {
      int ticket_temp = OrderSend(_Symbol, OP_SELL, Volumen, Bid, 0, High[1], Bid - Pips_TP * Point);
   }
//---
   Comment(
      "Cruce Alcista   ",  cruce_alcista,
      "\n",
      "Cruce Bajista   ",  cruce_bajista, "\n",
      "\n",
      "Contador Bajista  ",  contador_bajista, "\n",
      "\n",
      "Contador Alcista  ",  contador_alcista, "\n"
      "  "
   );
}// FIN DEL ONTICK
//+------------------------------------------------------------------+
int Contador_Velas ( string _tipo)
// CONTAR LAS VELAS QUE ESTEN POR ENCIMA O POR DEBAJO DE LA SMA DE 21 DESPUES DE QUE OCURRA UN CRUCE
{
   int cont = 0;
   if(_tipo == "alza")
   {
      for(int i = 2; i <= velas_confirmacion + 1; i++)
      {
         double mm_temp = iMA(_Symbol, _Period, Periodo_SMA, 0, Tipo_Media, Tipo_Precio, i); // COGER EL VALOR DE LA SMA
//---
         if(Low[i] > mm_temp )
         {
            cont ++;
         }
         else
            cont = 0;
      }
   }
   else  if(_tipo == "baja")
   {
      for(int i = 2; i <= velas_confirmacion + 1; i++)
      {
         double mm_temp = iMA(_Symbol, _Period, Periodo_SMA, 0, Tipo_Media, Tipo_Precio, i); // COGER EL VALOR DE LA SMA
//---
         if(High[i] < mm_temp)
         {
            cont ++;
         }
         else
            cont = 0;
      }
   }
   return cont;
}

//+------------------------------------------------------------------+
