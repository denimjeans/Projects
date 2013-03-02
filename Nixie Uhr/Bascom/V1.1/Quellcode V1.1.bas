'Mikrocontroller
$regfile = "m32def.dat"
$crystal = 8000000

'Stackgröße festlegen
$hwstack = 200
$swstack = 200

'TWI konfigurieren
Config Sda = Portc.1
Config Scl = Portc.0
Config Twi = 100000                                         'TWI Frequenz

'Unterprogramme
Declare Sub Uhrzeit                                         'Uhrzeit auslesen
Declare Sub Showdate                                        'Datum anzeigen
Declare Sub Settime                                         'Zeit setzen
Declare Sub Setdate                                         'Datum setzen
Declare Sub Read_dcf                                        'DCF Modul auslesen
Declare Sub Enable_sqw                                      'SQW der RTC aktivieren

'Ports konfigurieren
Config Porta = Output                                       'Port für die Stunden
Config Portd = Output                                       'Port für die Minuten

'Pull-Up Widerstände aktivieren
Portb.2 = 1                                                 'SQW Pin der RTC

'Variablen
Dim _year As Byte
Dim _month As Byte
Dim _day As Byte
Dim _hour As Byte
Dim _min As Byte
Dim _sec As Byte
Dim Ds1307w As Byte
Dim Ds1307r As Byte
Dim Jahr_tausender As Byte
Dim Jahr As Byte
Dim Monat As Byte
Dim Tag As Byte
Dim Wochentag As Byte
Dim Stunde As Byte
Dim Minute As Byte
Dim Sekunde As Byte
Dim Read_ds1307 As Byte                                     'Interruptflag
Dim Impuls As Byte                                          'Impulszähler

'Adresse der DS1307
Ds1307w = &HD0                                              'Schreibadresse der RTC
Ds1307r = &HD1                                              'Leseadresse der RTC

'Interrupts einstellen
Config Int2 = Rising
Enable Interrupts
Enable Int2
On Int2 Ds1307_int

'Uhrzeit voreinstellen
_hour = 16
_min = 36
_sec = 00
_day = 25
_month = 04
_year = 12
Jahr_tausender = 20



'Call Settime
'Call Setdate
Call Enable_sqw

Do

If Read_ds1307 = 1 Then
   Call Uhrzeit                                             'RTC auslesen
   Read_ds1307 = 0
End If

If Impuls = 45 Then
    Call Showdate
    Impuls = 0
End If

Porta = Stunde
Portd = Minute

Config Powermode = Powerdown                                'Controller schlafen legen

Loop
End

'------------------------------------------------------------------------------

Sub Uhrzeit

  I2cstart
  I2cwbyte Ds1307w                                          ' Schreibadresse senden
  I2cwbyte 0                                                ' Startadresse auf Register 0 setzen

  I2cstart
  I2cwbyte Ds1307r                                          ' Adresse übermitteln
  I2crbyte Sekunde , Ack
  I2crbyte Minute , Ack
  I2crbyte Stunde , Ack
  I2crbyte Wochentag , Ack
  I2crbyte Tag , Ack
  I2crbyte Monat , Ack
  I2crbyte Jahr , Nack
  I2cstop

  Tag = Makedec(tag)                                        'Datum in eine Dezimalzahl umwandeln
  Monat = Makedec(monat)
  Jahr = Makedec(jahr)

End Sub

'------------------------------------------------------------------------------

Sub Read_dcf


End Sub

'------------------------------------------------------------------------------

Sub Enable_sqw

   I2cstart
   I2cwbyte Ds1307w
   I2cwbyte 7
   I2cwbyte &B10010000
   I2cstop

End Sub

'------------------------------------------------------------------------------

Ds1307_int:

   Read_ds1307 = 1
   Incr Impuls

Return

'------------------------------------------------------------------------------

Sub Settime

  _sec = Makebcd(_sec) : _min = Makebcd(_min) : _hour = Makebcd(_hour)
  I2cstart
  I2cwbyte Ds1307w
  I2cwbyte 0
  I2cwbyte _sec
  I2cwbyte _min
  I2cwbyte _hour
  I2cstop

End Sub

'------------------------------------------------------------------------------

Sub Setdate

    _year = Makebcd(_year) : _month = Makebcd(_month) : _day = Makebcd(_day)
  I2cstart
  I2cwbyte Ds1307w
  I2cwbyte 4
  I2cwbyte _day
  I2cwbyte _month
  I2cwbyte _year
  I2cstop

End Sub

'------------------------------------------------------------------------------

Sub Showdate

'Lokale Variablen deklarieren
Local Tag_einser As Byte
Local Tag_zehner As Byte
Local Tag_dummy As Byte
Local Monat_einser As Byte
Local Monat_zehner As Byte
Local Monat_dummy As Byte
Local Jahr_tausender_einser As Byte
Local Jahr_tausender_zehner As Byte
Local Jahr_tausender_dummy As Byte
Local Jahr_einser As Byte
Local Jahr_zehner As Byte
Local Jahr_dummy As Byte
Local Jahre As Byte

'Originaldatum in Dummys speichern
Jahr_dummy = Makebcd(jahr)
Jahr_tausender_dummy = Makebcd(jahr_tausender)
Monat_dummy = Makebcd(monat)
Tag_dummy = Makebcd(tag)

'Tage zerlegen und auf zwei Variablen aufteilen
Tag_einser = Tag_dummy
Shift Tag_einser , Left , 4
Shift Tag_einser , Right , 4
Tag_zehner = Tag_dummy
Shift Tag_zehner , Right , 4

'Monate zerlegen und auf zwei Variablen aufteilen
Monat_einser = Monat_dummy
Shift Monat_einser , Left , 4
Shift Monat_einser , Right , 4
Monat_zehner = Monat_dummy
Shift Monat_zehner , Right , 4

'Tausender von den Jahren zerlegen und auf zwei Variablen aufteilen
Jahr_tausender_einser = Jahr_tausender_dummy
Shift Jahr_tausender_einser , Left , 4
Shift Jahr_tausender_einser , Right , 4
Jahr_tausender_zehner = Jahr_tausender_dummy
Shift Jahr_tausender_zehner , Right , 4

'Zehner von den Jahren zerlegen und auf zwei Variablen aufteilen
Jahr_einser = Jahr_dummy
Shift Jahr_einser , Left , 4
Shift Jahr_einser , Right , 4
Jahr_zehner = Jahr_dummy
Shift Jahr_zehner , Right , 4

'Datum als Laufschrift ausgeben
Porta = 0                                                   'PortA löschen
Portd = 0                                                   'PortD löschen
Portd = Tag_zehner
Waitms 500
Shift Tag_zehner , Left , 4
Portd = Tag_dummy
Waitms 500
Shift Tag_zehner , Right , 4
Shift Tag_einser , Left , 4
Portd = Tag_einser
Porta = Tag_zehner
Waitms 500
Shift Tag_zehner , Left , 4
Portd = Monat_zehner
Porta = Tag_dummy
Waitms 500
Porta = Tag_einser
Portd = Monat_dummy
Waitms 500
Shift Monat_einser , Left , 4
Portd = Monat_einser
Porta = Monat_zehner
Waitms 500
Porta = Monat_dummy
Portd = Jahr_tausender_zehner
Waitms 500
Porta = Monat_einser
Portd = Jahr_tausender_dummy
Waitms 500
Shift Jahr_tausender_einser , Left , 4
Porta = Jahr_tausender_zehner
Jahre = Jahr_tausender_einser + Jahr_zehner
Portd = Jahre
Waitms 500
Porta = Jahr_tausender_dummy
Portd = Jahr_dummy
Waitms 500
Shift Jahr_einser , Left , 4
Porta = Jahre
Portd = Jahr_einser
Waitms 500
Porta = Jahr_dummy
Portd = 0
Waitms 500
Porta = Jahr_einser
Waitms 500
Porta = 0
Waitms 500

'Datum fest auf den Röhren ausgeben
Porta = Tag_dummy
Portd = Monat_dummy
Wait 4
Porta = 0
Portd = 0

End Sub

'------------------------------------------------------------------------------