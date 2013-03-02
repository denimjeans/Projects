'Mikrocontroller
$regfile = "m32def.dat"
$crystal = 16000000

'Stacks
$hwstack = 250
$swstack = 250
$framesize = 500

'UART konfigurieren
$baud = 9600

'SPI konfigurieren
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Noss = 1 , Clockrate = 16

'TWI konfigurieren
Config Sda = Portc.1
Config Scl = Portc.0
Config Twi = 100000                                         'TWI Frequenz

'Unterprogramme
Declare Function Devicemode() As String
Declare Function Read_rx_status As Byte
Declare Function Read_register(byval Adresse As Byte) As Byte
Declare Sub Hilfe
Declare Sub Recieve_can
Declare Sub Mcp2515_init
Declare Sub Startbildschirm
Declare Sub Uart_auswertung
Declare Sub Mcp2515_interrupt
Declare Sub Changemode(byval Modus As String)
Declare Sub Config_filter(byval Filter_wert As Byte , Byval Buffer As Byte , Byval Filter As Byte)
Declare Sub Send_can(byval Tx_identifier As Integer , Byval Datalenght As Byte , Daten(8) As Byte )
Declare Sub Bitmodify(byval Reg_add As Byte , Byval Reg_mask As Byte , Byval Reg_val As Byte)
Declare Sub Send_remote(byval Tx_identifier As Integer , Byval Datalenght As Byte)
Declare Sub Write_register(byval Adresse As Byte , Byval Daten As Byte)

'Befehle
Const Spi_read = &H03
Const Spi_write = &H02
Const Spi_reset = &HC0
Const Spi_rts0 = &H81
Const Spi_bitmodify = &H05
Const Spi_rx_status = &HB0
Const Spi_read_rx0 = &H90
Const Spi_read_rx1 = &H96

'Registeradressen
'Controlregister
Const Cnf1 = &H2A
Const Cnf2 = &H29
Const Cnf3 = &H28
Const Canstat = &H0E                                        'Control Statusregister vom MCP2515
Const Canctrl = &H0F                                        'Control Register vom MCP2515
Const Caninte = &H2B                                        'Interrupt Enable vom MCP2515
Const Canintf = &H2C                                        'Interrupfflags vom MCP2515

'Transmit Buffer
Const Txb0ctrl = &H30                                       'Transmit Buffer 0 Control Register
Const Txb0dlc = &H35                                        'Transmit Buffer 0 Data Length Code
Const Txb0sidh = &H31                                       'Transmit Buffer 0 Std Identifier High
Const Txb0sidl = &H32                                       'Transmit Buffer 0 Std Identifier Low
Const Txb0eid8 = &H33                                       'Transmit Buffer 0 Ext Identifier High
Const Txb0eid0 = &H34                                       'Transmit Buffer 0 Ext Identifier Low
Const Txb0d0 = &H36                                         'Transmit Buffer 0 Data Byte 0
Const Txb0d1 = &H37                                         'Transmit Buffer 0 Data Byte 1
Const Txb0d2 = &H38                                         'Transmit Buffer 0 Data Byte 2
Const Txb0d3 = &H39                                         'Transmit Buffer 0 Data Byte 3
Const Txb0d4 = &H3A                                         'Transmit Buffer 0 Data Byte 4
Const Txb0d5 = &H3B                                         'Transmit Buffer 0 Data Byte 5
Const Txb0d6 = &H3C                                         'Transmit Buffer 0 Data Byte 6
Const Txb0d7 = &H3D                                         'Transmit Buffer 0 Data Byte 7

'Recieve Buffer
Const Rxb0ctrl = &H60                                       'Recieve Buffer 0 Control Register
Const Rxb1ctrl = &H70                                       'Recieve Buffer 1 Control Register
Const Rxb0d0 = &H66                                         'Revieve Buffer 0 Data Byte 0
Const Rxb0d1 = &H67                                         'Revieve Buffer 0 Data Byte 1
Const Rxb0d2 = &H68                                         'Revieve Buffer 0 Data Byte 2
Const Rxb0d3 = &H69                                         'Revieve Buffer 0 Data Byte 3
Const Rxb0d4 = &H60                                         'Revieve Buffer 0 Data Byte 4
Const Rxb0d5 = &H6A                                         'Revieve Buffer 0 Data Byte 5
Const Rxb0d6 = &H6B                                         'Revieve Buffer 0 Data Byte 6
Const Rxb0d7 = &H6C                                         'Revieve Buffer 0 Data Byte 7

'Error
Const Eflg = &H2D                                           'Errorflags
Const Tec = &H1C                                            'Tx Error Counter
Const Rec = &H1D                                            'Rx Error Counter

'Mask Register
'RXM0
'Standard Identifier
Const Rxm0sidh = &H20
Const Rxm0sidl = &H21

'Extended Identifier
Const Rxm0eidh = &H22
Const Rxm0eidl = &H23

'RXM1
'Standard Identifier
Const Rxm1sidh = &H24
Const Rxm1sidl = &H25

'Extended Identifier
Const Rxm1eidh = &H26
Const Rxm1eidl = &H27

'Acceptance Filter
'RXF0
'Standard Identifier
Const Rxf0sidh = &H00
Const Rxf0sidl = &H01

'Extended Identifier
Const Rxf0eidh = &H02
Const Rxf0eidl = &H03

'RXF1
'Standard Identifier
Const Rxf1sidh = &H04
Const Rxf1sidl = &H05

'Extended Identifier
Const Rxf1eidh = &H06
Const Rxf1eidl = &H07

'RXF2
'Standard Identifier
Const Rxf2sidh = &H08
Const Rxf2sidl = &H09

'Extended Identifier
Const Rxf2eidh = &H0A
Const Rxf2eidl = &H0B

'RXF3
'Standard Identifier
Const Rxf3sidh = &H10
Const Rxf3sidl = &H11

'Extended Identifier
Const Rxf3eidh = &H12
Const Rxf3eidl = &H13

'RXF4
'Standard Identifier
Const Rxf4sidh = &H14
Const Rxf4sidl = &H15

'Extended Identifier
Const Rxf4eidh = &H16
Const Rxf4eidl = &H17

'RXF5
'Standard Identifier
Const Rxf5sidh = &H18
Const Rxf5sidl = &H19

'Extended Identifier
Const Rxf5eidh = &H1A
Const Rxf5eidl = &H1B

'I/O Einstellungen
Config Portb.4 = Output
Config Pind.2 = Input

'Namen vergeben
Cs Alias Portb.4

'SPI initialisieren
Spiinit

'I²C initialisieren
I2cinit

'Globale Variablen
Dim Modus As String * 10
Dim Sendcounter As Byte                                     'Counter um die als Parameter übergebenen Daten im Array "Daten" zu speichern
Dim Curr_vers As String * 30                                'Versionsinfo

'CAN
Dim Status As Byte
Dim Statusflag As Byte
Dim Can_message(10) As Integer
Dim Message_id As Integer
Dim Daten(8) As Byte

'UART
Dim Enable_uart As Bit                                      'Flag um die UART Ausgabe der Registerinformationen                                                          'zu aktivieren
Dim Eingabe As String * 50                                  'Eingabestring
Dim Eingabe_overlay(50) As Byte At Eingabe Overlay          'Overlay zum String löschen
Dim Befehl(11) As String * 10
Dim Parameter(12) As Byte
Dim Count As Byte
Dim Zeichen As Byte
Dim Buffer_laenge As Byte

'Variablen setzen
Enable_uart = 1
Buffer_laenge = 1

'Interrupts einstellen
Enable Interrupts                                           'Interrupts aktivieren                                        '
Config Int0 = Falling                                       'INT0 auf fallende Flanke einstellen
On Int0 Mcp2515_int                                         'Sprungmarke für INT0
On Urxc Uart_recieved
Enable Urxc
Enable Int0                                                 'INT0 aktivieren

'Chipselect auf High setzen
Set Cs
Wait 1

'Version
'$version 1 , 0 , 0

'MCP2515 initialisieren
Mcp2515_init

'Startbildschirm ausgeben
Startbildschirm

'Filter einstellen
Config_filter 8 , 0 , 0                                     'Filter einstellen (1. Zahl = Filterwert, 2. Zahl = Buffer

'Hauptprogramm
Do

'Empfangene Nachricht auswerten
If Statusflag = 1 Then

   Print "MCP Interrupt!"
   Statusflag = 0
   Mcp2515_interrupt                                        'Interruptquelle auslesen

End If

Loop
End



'Unterprogramme
'-------------------------------------------------------------------------------------------------------------------

Function Read_rx_status() As Byte

Reset Cs                                                    'CS auf Low ziehen

Spdr = Spi_rx_status                                        'Befehl zum auslesen des Rx Status Register ins Datenregister schreiben
Spiout Spdr , 1                                             'Inhalt des Datenregisters über SPI senden
Waitus 1                                                    'Kurze Zeit warten
Spiin Read_rx_status , 1                                    'Antwort des MCP2515 unter "Status" speichern

Set Cs

End Function

'-------------------------------------------------------------------------------------------------------------------

Function Read_register(byval Adresse As Byte ) As Byte

Reset Cs                                                    'Chipselect auf Low ziehen
Spdr = Spi_read                                             'Inhalt von "SPI_Read" im Datenregister speichern
Spiout Spdr , 1
Spiout Adresse , 1
Waitus 1
Spiin Read_register , 1                                     'Registerinhalt einlesen
Set Cs                                                      'Chipselect auf High ziehen

End Function

'-------------------------------------------------------------------------------------------------------------------

Function Devicemode() As String

Local Statusregister As Byte
Statusregister = Read_register(canstat)
Shift Statusregister , Right , 5

Select Case Statusregister

   Case 0 : Devicemode = "Normal Mode"
   Case 1 : Devicemode = "Sleep Mode"
   Case 2 : Devicemode = "Loopback Mode"
   Case 3 : Devicemode = "Listen-only Mode"
   Case 4 : Devicemode = "Configuration Mode"

End Select

End Function

'-------------------------------------------------------------------------------------------------------------------

Sub Changemode(byval Modus As String)

Local Read_mode As Byte

   Select Case Modus

      Case "Normal" : Bitmodify Canctrl , &HE0 , &H0

                        'CAN Control Register auslesen und REQOP Bits ausfiltern
                       Read_mode = Read_register(canctrl)
                       Shift Read_mode , Right , 5

                       'Prüfen ob Modus gewechselt wurde
                       If Read_mode <> 0 Then
                         Print "Fehler beim Moduswechsel!"
                       Else
                         Print "Return Device into Normal Mode"
                       End If

                       Read_mode = 0

      Case "Sleep" : Bitmodify Canctrl , &HE0 , &H20

                        'CAN Control Register auslesen und REQOP Bits ausfiltern
                        Read_mode = Read_register(canctrl)
                        Read_mode = Read_mode And &H20
                        Print "Read_mode: " ; Bin(read_mode)

                       'Prüfen ob Modus gewechselt wurde
                       If Read_mode = &H20 Then
                        Print "Device is going to sleep now. Wakeup Interrupt will be enabled."
                       Else
                        Print "Fehler beim Moduswechsel!"
                       End If

                       Read_mode = 0

      Case "Loopback" : Bitmodify Canctrl , &HE0 , &H40

                        'CAN Control Register auslesen und REQOP Bits ausfiltern
                        Read_mode = Read_register(canctrl)
                        Read_mode = Read_mode And &H40
                        Print "Read_mod: " ; Bin(read_mode)

                       'Prüfen ob Modus gewechselt wurde
                       If Read_mode = &H40 Then
                         Print "Device is going to Loopback Mode now."
                       Else
                        Print "Fehler beim Moduswechsel!"
                       End If

                       Read_mode = 0

      Case "Listen" : Bitmodify Canctrl , &HE0 , &H60

                        'CAN Control Register auslesen und REQOP Bits ausfiltern
                        Read_mode = Read_register(canctrl)
                        Read_mode = Read_mode And &H60
                        Print "Read_mod: " ; Bin(read_mode)

                       'Prüfen ob Modus gewechselt wurde
                       If Read_mode = &H60 Then
                        Print "Device is going to Listen-only Mode now."
                       Else
                        Print "Fehler beim Moduswechsel!"
                       End If

                       Read_mode = 0

      Case "Quit" : Return
      Case Else : Print "Ungueltige Eingabe!"

   End Select

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Mcp2515_init

Reset Cs

Spdr = Spi_reset                                            'MCP2515 reseten
Do
Loop Until Spsr.spif = 1
Set Cs
Waitus 50                                                   'Warten bis CS High ist

'Control Register beschreiben
Write_register Canctrl , &H88                               'Device in Configuration Mode versetzen, Nachrichten nur 1x versenden

'Interrupts einstellen
Write_register Caninte , &H41                               'Recieve Buffer 0, Wakeup Interrupt aktivieren

'Tx-Konfiguration
Write_register Txb0ctrl , &H03                              'Priorität der Nachrichten auf "Highest" stellen

'Bittiming einstellen
Write_register Cnf1 , &H03                                  'Baudrate einstellen
Write_register Cnf2 , &HA0                                  'Phasensegmenteinstellungen
Write_register Cnf3 , &H02

'Rx Buffer einstellen
Write_register Rxb0ctrl , &H20                              'Standard Identifier erlauben
Write_register Rxb1ctrl , &H20

Bitmodify Canctrl , &HE0 , &H0                              'CAN-Controller in den "Normal Mode" versetzen

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Write_register(byval Adresse As Byte , Byval Daten As Byte)

Reset Cs                                                    'Chipselect auf Low ziehen
Spdr = Spi_write                                            'Inhalt von "SPI-Write" ins SPI_Data_Register schieben
Do                                                          'Schleife bis SPI Interrupt Flag gesetzt wurde, also bis
Loop Until Spsr.spif = 1                                    'die Übertragung abgeschlossen ist

Spdr = Adresse
Do
Loop Until Spsr.spif = 1

Spdr = Daten
Do
Loop Until Spsr.spif = 1
Set Cs                                                      'Chipselect auf High ziehen
Waitus 50                                                   'Kurz warten bis CS High ist

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Bitmodify(reg_add , Reg_mask , Reg_val)

Reset Cs
Spdr = Spi_bitmodify
Do
Loop Until Spsr.spif = 1
Spdr = Reg_add
Do
Loop Until Spsr.spif = 1
Spdr = Reg_mask
Do
Loop Until Spsr.spif = 1
Spdr = Reg_val
Do
Loop Until Spsr.spif = 1
Set Cs
Waitus 50

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Startbildschirm

Print "+-------------------------------------+"
Print "|                                     |"
Print "|    Device:       CAN-Knoten         |"
Print "|    Releasedatum: 11.11.2012         |"
Print "|                                     |"
Print "+-------------------------------------+"
Print ""
Print "Type '?' for more Informations."

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Hilfe

Print ""
Print "Hilfe:"
Print "+-----------------------------------------------------------------------+"
Print "- Remote,P1,P2"
Print "     P1 - Message ID"
Print "     P2 - Datalength"
Print "  Description:"
Print "     Send a Remoteframe with P1 as ID and P2 as Datalength."
Print "- Data,P1,P2,P3-P8"
Print "     P1 - Message ID"
Print "     P2 - Datalength"
Print "     P3... - Databyte"
Print "  Description:"
Print "     Send a Message with the Length P2 and the Identifier P1. P1 - P8"
Print "     contains the Data (8-Bit)."
Print "     Note: The Number of Data must be the same as you specify with P2."
Print "- Filter,P1,P2,P3,P4"
Print "     P1 - Filtervalue"
Print "     P2 - Buffer"
Print "     P3 - Filter"
Print "  Description:"
Print "     Set Filter P3 of Buffer P2 to Value P1."
Print "- Mode"
Print "  Descritption:"
Print "     Return the Device Mode."
Print "- Change"
Print "  Description:"
Print "     Change the Device Mode."
Print "        -> Normal"
Print "           Description:"
Print "              Set Device into Normal Mode."
Print "        -> Sleep"
Print "           Descritption:"
Print "              Set the Device into Sleep Mode."
Print "        -> Loopback"
Print "           Descritption:"
Print "              Set the Device into Loopback Mode."
Print "        -> Listen"
Print "           Descritption:"
Print "              Set the Device into Listen-only Mode."
Print "        -> Quit"
Print "           Description:"
Print "              Quit this Mode."
Print "- Wake"
Print "  Description:"
Print "     Wakeup Device."
Print "- Output"
Print "  Description:"
Print "     Enable/Disable UART Feedback."
Print "- Read,A1"
Print "     A1 - Registername"
Print "  Description:"
Print "     Reads out a Register with Adress A1."
Print "- About"
Print "  Description:"
Print "     Show Softwareinformation."
Print "- Reset"
Print "  Description:"
Print "     Reset the MCP2515."
Print "- Version"
Print "  Description:"
Print "     Show the Softwareversion."
Print ""

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Uart_auswertung

Local Laenge As Byte                                        'Stringlänge
Local Count As Byte                                         'Zähler

Print "Eingabe: " ; Eingabe

Laenge = Len(eingabe)                                       'Stringlänge bestimmen
Count = Split(eingabe , Befehl(1) , ",")                    'Eingegebenen Befehl aufteilen und im Array "Befehl" speichern

Select Case Befehl(1)

   Case "Remote" : Message_id = Val(befehl(2))

                     'Speichern der Datenlänge
                     Parameter(1) = Val(befehl(3))

                     'Remoteframe senden
                     Send_remote , Message_id , Parameter(1)

   Case "Data" : Message_id = Val(befehl(2))

                  'Speichern der Datenlänge
                  Parameter(1) = Val(befehl(3))

                  'Speichern der Daten
                  For Sendcounter = 1 To Parameter(1)
                     Parameter(sendcounter + 1) = Val(befehl(sendcounter + 3))
                     Daten(sendcounter) = Parameter(sendcounter + 1)
                  Next Sendecounter

                  'Prüfen ob die Anzahl der übergebenen Daten mit der übergebenen Länge überein stimmt
                  Count = Count - 3
                  If Parameter(1) = Count Then
                     'Datenframe senden
                     Send_can Message_id , Parameter(1) , Daten(1)
                  Else
                     Print "Fehler! Uebergebene Daten stimmen nicht mit der Laenge ueberein!"
                  End If

   Case "Filter" : Parameter(1) = Val(befehl(2))
                     Parameter(2) = Val(befehl(3))
                     Parameter(3) = Val(befehl(4))
                     Config_filter Parameter(1) , Parameter(2) , Parameter(3)
   Case "?" : Hilfe
   Case "Mode" : Print "Devicemode: " ; Devicemode()
   Case "Wake" : Print "Device will be wake now.
                     Bitmodify Canintf , &H40 , &H40
   Case "Output" : Toggle Enable_uart
                     Print "UART Feedback Enable: " ; Enable_uart
   Case "Change" : Input Modus Noecho
                   Print "Eingabe: " ; Modus
                   Changemode Modus
   Case "Read" : Parameter(1) = Hexval(befehl(2))           'String in eine Hex-Zahl umwandeln
                  Parameter(2) = Read_register(parameter(1))       'Adressiertes Register auslesen
                  Befehl(3) = Bin(parameter(2))             'Registerwert in einen Binärstring umwandeln
                  Print "Inhalt von Adresse " ; Befehl(2) ; ": " ; Befehl(3) ; " = " ; Parameter(2)
   Case "Write":
   Case "About" : Startbildschirm
   Case "Version" : Print "Version: " ; Version(2)          'Versionsnummer ausgeben
   Case "Reset" : Mcp2515_init
                   Print "MCP Reset."
   Case Else : Print "Unbekannte Eingabe!"

End Select

Print "+-----------------------------------------------------------------------+"

'String löschen
Befehl(1) = ""
For Count = 0 To Laenge
   Eingabe_overlay(count) = 0
Next

Buffer_laenge = 1

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Mcp2515_interrupt

'Statusregister
Local Interrupt As Byte
Local Rx0if As Byte
Local Rx1if As Byte
Local Tx0if As Byte
Local Tx1if As Byte
Local Tx2if As Byte
Local Errif As Byte
Local Wakif As Byte
Local Merrf As Byte

'Errorflag
Local Errorflag As Byte
Local Ewarn As Byte
Local Rxwar As Byte
Local Txwar As Byte
Local Rxep As Byte
Local Txep As Byte
Local Txbo As Byte
Local Rx0ovr As Byte
Local Rx1ovr As Byte

'Interrupt Flag Register auslesen
Interrupt = Read_register(canintf)

'Message Error Interrupt Flag ausfiltern
Merrf = Interrupt
Shift Merrf , Right , 7

'Wakeup Interrupt Flag ausfiltern
Wakif = Interrupt
Shift Wakif , Right , 6
Wakif = Wakif And &H01

'Error Interrupt Flag auslesen
Errif = Interrupt
Shift Errif , Right , 5
Errif = Errif And &H01

'Transmit Buffer 2 Flag ausfiltern
Tx2if = Interrupt
Shift Tx2if , Right , 4
Tx2if = Tx2if And &H01

'Transmit Buffer 1 Flag ausfiltern
Tx1if = Interrupt
Shift Tx1if , Right , 3
Tx1if = Tx1if And &H01

'Transmit Buffer 0 Flag ausfiltern
Tx0if = Interrupt
Shift Tx0if , Right , 2
Tx0if = Tx0if And &H01

'Recieve Buffer 1 Flag ausfiltern
Rx1if = Interrupt
Shift Rx1if , Right , 1
Rx1if = Rx1if And &H01

'Recieve Buffer 0 Flag ausfiltern
Rx0if = Interrupt
Shift Rx0if , Left , 7
Shift Rx0if , Right , 7

If Enable_uart = 1 Then

   Print "---Statusregister---"
   Print "Interrupt Flag: " ; Read_register(canintf)
   Print "Message Error Interrupt Flag: " ; Merrf
   Print "Wakeup Interrupt Flag: " ; Wakif
   Print "Error Interrupt Flag: " ; Errif
   Print "Transmit Buffer 2 Empty Interrupt Flag: " ; Tx2if
   Print "Transmit Buffer 1 Empty Interrupt Flag: " ; Tx1if
   Print "Transmit Buffer 0 Empty Interrupt Flag: " ; Tx0if
   Print "Recievebuffer 1 Full Interrupt Flag: " ; Rx1if
   Print "Recievebuffer 0 Full Interrupt Flag: " ; Rx0if
   Print "+------------------------------------------------------------------------+"

End If

'Message Error Interrupt Flag löschen
If Merrf = 1 Then

      Bitmodify Canintf , &H80 , &H0

End If

'Wakeup Interrupt Flag löschen
If Wakif = 1 Then

   Bitmodify Canintf , &H40 , &H0

End If

'Error Flag auslesen
If Errif = 1 Then

   Errorflag = Read_register(eflg)

   'Recieve Buffer 1 Overflow Flag ausfiltern
   Rx1ovr = Errorflag
   Shift Rx1ovr , Right , 7

   'Recieve Buffer 0 Overflow Flag ausfiltern
   Rx0ovr = Errorflag
   Shift Rx0ovr , Right , 6
   Rx0ovr = Rx0ovr And &H01

   'Bus-Off Error Flag ausfiltern
   Txbo = Errorflag
   Shift Txbo , Right , 5
   Txbo = Txbo And &H01

   'Transmit Error-Passive Flag
   Txep = Errorflag
   Shift Txep , Right , 4
   Txep = Txep And &H01

   'Recieve Error-Passive Flag
   Rxep = Errorflag
   Shift Rxep , Right , 3
   Rxep = Rxep And &H01

   'Transmit Error Warning Flag
   Txwar = Errorflag
   Shift Txwar , Right , 2
   Txwar = Txwar And &H01

   'Recieve Error Warning Flag
   Rxwar = Errorflag
   Shift Rxwar , Right , 1
   Rxwar = Rxwar And &H01

   'Error Warning Flag
   Ewarn = Errorflag
   Shift Ewarn , Left , 7
   Shift Ewarn , Right , 7

   If Enable_uart = 1 Then

      Print "---Error Flag---"
      Print "Error Flag: " ; Read_register(eflg)
      Print "Recieve Buffer 1 Overflow: " ; Rx1ovr
      Print "Recieve Buffer 0 Overflow: " ; Rx0ovr
      Print "Bus-Off Error Flag: " ; Txbo
      Print "Transmit Error-Passive Flag: " ; Txep
      Print "Recieve Error-Passive Flag: " ; Rxep
      Print "Transmit Error Warning Flag: " ; Txwar
      Print "Recieve Error Warning Flag: " ; Rxwar
      Print "Error Warning Flag: " ; Ewarn
      Print "+------------------------------------------------------------------------+"

   End If

End If

Recieve_can

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Config_filter(byval Filter_wert As Byte , Byval Buffer As Byte , Byval Filter As Byte)

Local Filter_low As Integer
Local Filter_high As Integer
Local Id_high As Byte
Local Id_low As Byte

Bitmodify Canctrl , &HE0 , &H80,                            'CAN-Controller in den "Configuration Mode" versetzen

   'Standardidentifier einstellen
   Filter_low = Filter_wert                                 'Speichert den Identifier in zwei Variablen und schiebt
   Filter_high = Filter_wert                                'den Wert um 5 Stellen nach rechts um die drei
   Shift Filter_low , Left , 5                              ' niedrigsten Bits zu gewinnen. Dasselbe passiert für
   Shift Filter_high , Right , 3                            'die acht höchsten Bits. Anschließend werden die Werte
                                                             'in die passenden Register geschrieben.
   If Buffer = 0 Then

      Select Case Filter
        Case 0 : Id_high = Filter_high
                     Id_low = Filter_low
                     Write_register , Rxf0sidh , Id_high
                     Write_register , Rxf0sidl , Id_low

         Case 1 : Id_high = Filter_high
                     Id_low = Filter_low
                     Write_register , Rxf1sidh , Id_high
                     Write_register , Rxf1sidl , Id_low
      End Select

   Elseif Buffer = 1 Then

      Select Case Filter
        Case 5 : Id_high = Filter_high
                     Id_low = Filter_low
                     Write_register , Rxf0sidh , Id_high
                     Write_register , Rxf0sidl , Id_low
      End Select

   Else

      Print "Unbekannter Buffer"

   End If

Bitmodify Canctrl , &HE0 , &H0                              'CAN-Controller in den "Normal Mode" versetzen

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Send_remote(byval Tx_identifier As Integer , Byval Datalenght As Byte)

Local Tx_low As Integer
Local Tx_high As Integer
Local Id_high As Byte
Local Id_low As Byte

'Prüfen ob die Länge kleiner als 8 ist
If Datalenght > 8 Then

   Print "Ungültige Länge!"
   Return

End If

'Prüfen ob der Identifier die richtige Länge hat
If Tx_identifier > 2047 Then

   Print "Identifier beträgt " ; Tx_identifier ; " und ist damit zu groß. Maximaler Wert ist 2047!"

Else

  'Identifier einstellen
   Tx_low = Tx_identifier                                   'Speichert den Identifier in zwei Variablen und schiebt
   Tx_high = Tx_identifier                                  'den Wert um 5 Stellen nach rechts um die drei
   Shift Tx_low , Left , 5                                  ' niedrigsten Bits zu gewinnen. Dasselbe passiert für
   Shift Tx_high , Right , 3                                'die acht höchsten Bits. Anschließend werden die Werte
                                                           'in die passenden Register geschrieben.
   Id_high = Tx_high
   Id_low = Tx_low

  'ID in die ID-Register schreiben
   Write_register Txb0sidh , Id_high
   Write_register Txb0sidl , Id_low

  'Renotebit setzen
   Datalenght = Datalenght + &H40                           'Remotebit zu der Datenlänge hinzufügen
   Write_register Txb0dlc , Datalenght

   Reset Cs
   Spdr = Spi_rts0                                          'Übertragung auslösen
   Do
   Loop Until Spsr.spif = 1
   Set Cs

End If

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Send_can(byval Tx_identifier As Integer , Byval Datalenght As Byte , Daten(8) As Byte)

Local Tx_low As Integer
Local Tx_high As Integer
Local Id_high As Byte
Local Id_low As Byte
Local Transmitcounter As Byte                               'Zähler für die For-Schleife der Datenpakete
Local Transmitadress As Byte                                'Buffer für die Startadresse

'Prüfen ob die Länge mehr als 8 Byte beträgt
If Datalenght > 8 Then

   Print "Ungültige Länge der Nachricht!"
   Return

End If

'Prüfen ob der Identifier die richtige Länge hat
If Tx_identifier > 2047 Then

   Print "Identifier beträgt " ; Tx_identifier ; " und ist damit zu groß. Maximaler Wert ist 2047!"
   Return

Else

   'Identifier einstellen
   Tx_low = Tx_identifier                                   'Speichert den Filter in zwei Variablen und schiebt
   Tx_high = Tx_identifier                                  'den Wert um 5 Stellen nach rechts um die drei
   Shift Tx_low , Left , 5                                  ' niedrigsten Bits zu gewinnen. Dasselbe passiert für
   Shift Tx_high , Right , 3                                'die acht höchsten Bits. Anschließend werden die Werte
                                                             'in die passenden Register geschrieben.
   Id_high = Tx_high
   Id_low = Tx_low

   'ID in die ID-register Schreiben
   Write_register Txb0sidh , Id_high
   Write_register Txb0sidl , Id_low

   'Länge in das Datalength Register schreiben
   Write_register Txb0dlc , Datalenght

   'Daten in die Datenregister schreiben
   Transmitadress = Txb0d0
   For Transmitcounter = 1 To Datalenght
      Write_register Transmitadress , Daten(transmitcounter)
      Incr Transmitadress
   Next Transmitcounter

   Reset Cs
   Spdr = Spi_rts0                                          'Übertragung auslösen
   Do
   Loop Until Spsr.spif = 1
   Set Cs

End If

End Sub

'-------------------------------------------------------------------------------------------------------------------

Sub Recieve_can

'Variablen für die Empfangsroutine
Local Id_low As Integer                                     'Buffer für die drei niedrigsten ID-Bits
Local Id_high As Integer                                    'Buffer für die acht höchsten ID-Bits
Local Laenge As Byte                                        'Buffer für die vier Längen-Bits
Local Daten As Byte
Local Dummy As Byte
Local Buffer As Byte
Local Frame As Byte
Local Filter As Byte
Local Daten_laenge As Byte
Local Remote_lenght As Byte
Local Zaehler_laenge As Byte
Local Id As Long
Local Printcounter As Byte                                  'Variable für den Ausgabecounter

'Variablen löschen
Id_high = 0
Id_low = 0
Laenge = 0

'Status auslesen und analysieren
Status = Read_rx_status()

'Buffer ausfiltern
Buffer = Status
Shift Buffer , Right , 6

'Frame ausfiltern
Frame = Status
Frame = Frame And &H18
Shift Frame , Right , 3

'Filter ausfiltern
Filter = Status
Filter = Filter And &H07

If Enable_uart = 1 Then

   Print "---Recieve---"
   Print "Buffer: " ; Buffer
   Print "Frame: " ; Frame
   Print "Filter: " ; Filter

End If

If Buffer = 2 Then                                          'Nachricht in Rx-Buffer 1

   Print "Nachricht in Buffer 1"


Elseif Buffer = 1 Then                                      'Nachricht in Rx-Buffer 0

   Print "Nachricht in Buffer 0"

      If Frame = 0 Then

         Print "Standard Data Frame"

        'Lesen vom Buffer auslösen
         Reset Cs
         Spdr = Spi_read_rx0
         Spiout Spdr , 1
         Waitus 1

         'CAN-Nachricht nach und nach empfangen
         'ID auslesen
         Spiin Id_high , 1
         Spiin Id_low , 1

         Spiin Dummy , 1                                    'Beiden Bytes des Extended Identifiers einlesen
         Spiin Dummy , 1

         'Länge auslesen
         Spiin Laenge , 1
         Zaehler_laenge = Laenge + 2
         Laenge = Laenge And &H0F

         'Daten auslesen
         For Daten_laenge = 3 To Zaehler_laenge
            Spiin Can_message(daten_laenge) , 1
         Next

         'CAN-Nachricht bearbeiten
         'Standard Identifier auslesen
         Shift Id_high , Left , 3                           'Verschiebung beim Senden rückgängig machen
         Shift Id_low , Right , 5
         Can_message(1) = Id_high                           'und Werte logisch miteiander verknüpfen um daraus
         Can_message(1) = Can_message(1) Or Id_low          'die komplette ID zu gewinnen
         Can_message(2) = Laenge

         'Ausgabe
         Print "Status: " ; Status
         Print "ID Nachricht: " ; Can_message(1)
         Print "Länge Nachricht: " ; Can_message(2)

         For Printcounter = 1 To Can_message(2)
            Print "Daten " ; Printcounter ; ": " ; Can_message(printcounter + 2)
         Next Printcounter
         Print "+------------------------------------------------------------------------+"

      Elseif Frame = 1 Then

         Print "Standard Remote Frame"

         'Lesen vom Buffer auslösen
         Reset Cs
         Spdr = Spi_read_rx0
         Spiout Spdr , 1
         Waitus 1

         'CAN-Nachricht nach und nach empfangen
         'ID auslesen
         Spiin Id_high , 1
         Spiin Id_low , 1

         Spiin Dummy , 1                                    'Beide Bytes des Extended Identifiers einlesen
         Spiin Dummy , 1                                    'und in einem Dummy speichern
         Spiin Remote_lenght , 1

         'CAN-Nachricht bearbeiten
         'Standard Identifier auslesen
         Shift Id_high , Left , 3                           'Verschiebung beim Senden rückgängig machen
         Shift Id_low , Right , 5

         Can_message(1) = Id_high                           'und Werte logisch miteiander verknüpfen um daraus
         Can_message(1) = Can_message(1) Or Id_low          'die komplette ID zu gewinnen

         'Länge auslesen
         Remote_lenght = Remote_lenght - 64                 'Remotebit entfernen
         Can_message(2) = Remote_lenght

         'Ausgabe
         Print "Status: " ; Status
         Print "ID Nachricht: " ; Can_message(1)
         Print "Laenge: " ; Can_message(2)
         Print "+------------------------------------------------------------------------+"

         '+---------------------------Knotenspezifischer Code-----------------------------------+'
         '|                                                                                     |'
         '|                    Hier kommt ein knotenspezifischer Code rein,                     |'
         '|  der bestimmt wie sich der Knoten beim empfangen eines Remoteframes verhalten soll. |'
         '|                                                                                     |'
         '+-------------------------------------------------------------------------------------+'

      End If

Else

   Print "Keine neue Nachricht vorhanden!"

End If

Set Cs

End Sub

'-------------------------------------------------------------------------------------------------------------------

'ISRs
'-------------------------------------------------------------------------------------------------------------------

'ISR von INT0
Mcp2515_int:

Statusflag = 1                                              'Interrupt ausgelöst

Return

'-------------------------------------------------------------------------------------------------------------------

'ISR vom UART
Uart_recieved:

   Zeichen = Udr

   If Zeichen = 13 Then                                     'CR gesendet?

      Eingabe_overlay(buffer_laenge + 1) = 0                'Stringende
      Uart_auswertung                                       'String auswerten

   Elseif Zeichen = 8 Then                                  'Backspace gesendet?

        Eingabe_overlay(buffer_laenge - 1) = 0              'Das letzte Zeichen überschreiben

   Elseif Zeichen > 13 Then

      Eingabe_overlay(buffer_laenge) = Zeichen              'Zeichen zu String hinzugügen
      Incr Buffer_laenge                                    'Zähler für Strinlänge erhöhen

      If Buffer_laenge > 49 Then                            'String länger als 50 Zeichen?
         Eingabe_overlay(buffer_laenge + 1) = 0             'Stringende
         Uart_auswertung
      End If

   End If

Return

'-------------------------------------------------------------------------------------------------------------------