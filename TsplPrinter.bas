B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.801
@EndOfDesignText@
#IgnoreWarnings: 1

Sub Class_Globals
	Private Version As Double = 1.0 ' Printer class version
	
	'Type AnImage(Width As Int, Height As Int, Data() As Byte)
	
	Private EventName As String 'ignore
	Private CallBack As Object 'ignore
	
	Private Serial1 As Serial
	Private Astream As AsyncStreams
	Private Connected As Boolean
	Private ConnectedError As String
	Private vbCrLf As String=Chr(13) & Chr(10) '\r\n
	
End Sub

'**********
'PUBLIC API
'**********

'Initialize the object with the parent and event name
Public Sub Initialize(vCallback As Object, vEventName As String)
	EventName = vEventName
	CallBack = vCallback
	Serial1.Initialize("Serial1")
	Connected = False
	ConnectedError = ""
End Sub

' Returns any error raised by the last attempt to connect a printer
Public Sub ConnectedErrorMsg As String
	Return ConnectedError
End Sub

' Returns whether a printer is connected or not
Public Sub IsConnected As Boolean
	Return Connected
End Sub

' Returns whether Bluetooth is on or off
Public Sub IsBluetoothOn As Boolean
	Return Serial1.IsEnabled
End Sub

' Ask the user to connect to a printer and return whether she tried or not
' If True then a subsequent Connected event will indicate success or failure
Public Sub Connect As ResumableSub 
	Dim PairedDevices As Map
	PairedDevices = Serial1.GetPairedDevices
	Dim l As List
	l.Initialize
	For i = 0 To PairedDevices.Size - 1
		l.Add(PairedDevices.GetKeyAt(i))
	Next
	InputListAsync(l, "Choose a printer", 0, False) 'show list with paired devices
	Wait For InputList_Result (Index As Int)
	If Index <> DialogResponse.CANCEL Then
		Log("Selected place: " & l.Get(Index))
		Serial1.Connect(PairedDevices.Get(l.Get(Index))) 'convert the name to mac address
		Return True
	End If
	Return False
End Sub

' Disconnect the printer
Public Sub DisConnect
	Serial1.Disconnect
	Connected = False
End Sub

'设置标签尺寸
Public Sub Size(Width As Double,Height As Double)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("SIZE ")
	sb.Append(Width).Append(" mm,")
	sb.Append(Height).Append(" mm").Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub

'两标签纸中间的垂直距离
Public Sub GAP(Interval As Double,Deviation As Double)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("GAP ")
	sb.Append(Interval).Append(" mm,")
	sb.Append(Deviation).Append(" mm").Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub
'打印浓度
Public Sub DENSITY2(Concentration As Int)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("DENSITY ").Append(Concentration).Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub
'打印方向
Public Sub DIRECTION(mType As Int)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("DIRECTION ").Append(mType).Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub
'设置原点
Public Sub REFERENCE(X As Int,Y As Int)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("REFERENCE ")
	sb.Append(X).Append(",")
	sb.Append(Y).Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub
'返回第一张纸
Public Sub HOME
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("HOME").Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub
'后退一张纸
Public Sub BACKUP(n As Int)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("BACKUP ").Append(n).Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub
'进一张纸
Public Sub FORMFEED
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("FORMFEED").Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
	
End Sub
'清屏
Public Sub CLS
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("CLS").Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub
'打印文本
Public Sub TEXT(X As Int,Y As Int,FontName As String,Rotation As Int,xMultiplication As Double,yMultiplication As Double,mText As String)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("TEXT ")
	sb.Append(X).Append(",")
	sb.Append(Y).Append(",")
	sb.Append("""").Append(FontName).Append(""",")
	sb.Append(Rotation).Append(",")
	sb.Append(xMultiplication).Append(",")
	sb.Append(yMultiplication).Append(",")
	sb.Append("""").Append(mText).Append("""").Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("GBK"))
End Sub
'打印一维条码:X,Y,条码类,高,是否显示条码内容,旋转角度,窄Bar宽度,宽Bar宽度,条码内容
Public Sub BARCODE(X As Int,Y As Int,CodeType As String,Height As Int,ShowTxt As Boolean,rotation As Int,narrow As Int,wide As Int,CodeText As String)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("BARCODE ")
	sb.Append(X).Append(",")
	sb.Append(Y).Append(",")
	sb.Append("""").Append(CodeType).Append(""",")
	sb.Append(Height).Append(",")
	If ShowTxt=True Then
		sb.Append("1").Append(",")
	Else
		sb.Append("0").Append(",")
	End If
	sb.Append(rotation).Append(",")
	sb.Append(narrow).Append(",")
	sb.Append(wide).Append(",")
	sb.Append("""").Append(CodeText).Append("""").Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub
'打印二维条码:X,Y,纠错等级(L/N/Q/H),码宽度,手动/自动编码(A/M),旋转角度,条码内容
Public Sub QRCODE(X As Int,Y As Int,EccLevel As String,CellWidth As Int,mode As String,rotation As Int,CodeText As String)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("QRCODE ")
	sb.Append(X).Append(",")
	sb.Append(Y).Append(",")
	sb.Append(EccLevel).Append(",")
	sb.Append(CellWidth).Append(",")
	sb.Append(mode).Append(",")
	sb.Append(rotation).Append(",")
	sb.Append("""").Append(CodeText).Append("""").Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("utf8"))
End Sub

Public Sub PRINT(m As Int,n As Int)
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("PRINT ")
	If n>0 Then
		sb.Append(m).Append(",").Append(n).Append(vbCrLf)
	Else
		sb.Append(m).Append(vbCrLf)
	End If
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub
Public Sub EOP()
	Dim sb As StringBuilder
	sb.Initialize
	sb.Append("EOP").Append(vbCrLf)
	Astream.Write(sb.ToString.GetBytes("ASCII"))
End Sub

'打印图形文件:X,Y,文件路径
Public Sub PUTBMP(X As Int,Y As Int,FilePath As String,FileName As String)
	Dim sb As StringBuilder
	Dim d() As Byte=Bit.InputStreamToBytes(File.OpenInput(FilePath, FileName))
	Dim Bconv As ByteConverter
	
	sb.Initialize
	'下载图片到打印机
	sb.Append("DOWNLOAD ")
	sb.Append("""PrintImg.BMP""")
	sb.Append(",").Append(d.Length)
	sb.Append(",").Append(Bconv.StringFromBytes(d,"ISO-8859-1")).Append(vbCrLf)

	'打印图片
	sb.Append("PUTBMP ")
	sb.Append(X).Append(",")
	sb.Append(Y).Append(",")
	sb.Append("""PrintImg.BMP""").Append(vbCrLf)
	
	Astream.Write(sb.ToString.GetBytes("ISO-8859-1"))
End Sub
'打印图片信息
Public Sub BITMAP(X As Int,Y As Int,mode As Int,Img As Bitmap)
	Dim a As String
	Dim sb As StringBuilder

	'补足8的倍数
	Dim w As Int=Img.Width
	If (w Mod 8)=0 Then
		w=w/8
	Else
		w=w/8+1
	End If
	
	'处理图像
	a=ImageToStr(Img)
	
	sb.Initialize
	sb.Append("BITMAP ")
	sb.Append(X).Append(",")
	sb.Append(Y).Append(",")
	sb.Append(w).Append(",")
	sb.Append(Img.Height).Append(",")
	sb.Append(mode).Append(",")
	sb.Append(a).Append(vbCrLf)
	
	Astream.Write(sb.ToString.GetBytes("ISO-8859-1"))
End Sub

'图片转为数组
Public Sub ImageToBWIMage(BMP As Bitmap) As Boolean()
	Dim BC As BitmapCreator 'ignore
	Dim W As Int = BMP.Width
	Dim H As Int = BMP.Height
	Dim pixels(W * H) As Boolean
	Dim s As Int
	'Dim r As Double,g As Short,b As Short
	
	For y = 0 To H - 1
		s=y*W
		For x = 0 To W - 1
			Dim j As Int = BMP.GetPixel(x, y)
			' convert color to approximate luminance value
			Dim col As ARGBColor
			BC.ColorToARGB(j, col)
			Dim lum As Int = col.r * 0.11 + col.g*0.59 + col.b*0.3

			'r=Bit.And(j,0xFF)
			'g=Bit.And((j / 0x100),0xFF)
			'b=Bit.And((j / 0x10000),0xFF)
			'转为灰度
			'Dim lum As Int = r * 0.11 + g*0.59 + b*0.3
			If lum> 255 Then lum = 255
			' save the pixel luminance
			pixels(s + x) = lum<127
		Next
	Next
	Return pixels
End Sub
'将Byte转为文本
Private Sub ImageToStr(BMP As Bitmap) As String
	Dim b() As Boolean
	Dim W As Int,H As Int
	Dim x As Int,y As Int
	
	b=ImageToBWIMage(BMP)
	W=BMP.Width
	H=BMP.Height

	Dim masks(8) As Short
	masks(0) = 0x80
	masks(1) = 0x40
	masks(2) = 0x20
	masks(3) = 0x10
	masks(4) = 0x08
	masks(5) = 0x04
	masks(6) = 0x02
	masks(7) = 0x01
	Dim sb As StringBuilder
	sb.Initialize
	Dim t As Int,s As Int
	For y=0 To H-1
		s=y*W
		For x=0 To W-1 Step 8
			t=255
			If x+7>W Then
				For j=0 To W-x-1
					If b(s+x+j) Then
						t=t-masks(j)
					End If
				Next
			Else
				For j=0 To 7
					If b(s+x+j) Then
						t=t-masks(j)
					End If
				Next
			End If
			sb.Append(Chr(t))
		Next
	Next
	Return sb.ToString
End Sub

'****************
' PRIVATE METHODS
'****************

'-----------------------
' Internal Serial Events
'-----------------------

Private Sub Serial1_Connected (Success As Boolean)
	If Success Then
		Astream.Initialize(Serial1.InputStream, Serial1.OutputStream, "astream")
		Connected = True
		ConnectedError = ""
		Serial1.Listen
	Else
		Connected = False
		ConnectedError = LastException.Message
	End If
	If SubExists(CallBack, EventName & "_Connected") Then
		CallSub2(CallBack, EventName & "_Connected", Success)
	End If
End Sub

'----------------------------
' Internal AsyncStream Events
'----------------------------

Private Sub AStream_NewData (Buffer() As Byte)
	If SubExists(CallBack, EventName & "_NewData") Then
		CallSub2(CallBack, EventName & "_NewData", Buffer)
	End If
	Log("Data " & Buffer(0))
End Sub

Private Sub AStream_Error
	If SubExists(CallBack, EventName & "_Error") Then
		CallSub(CallBack, EventName & "_Error")
	End If
End Sub

Private Sub AStream_Terminated
	Connected = False
	If SubExists(CallBack, EventName & "_Terminated") Then
		CallSub(CallBack, EventName & "_Terminated")
	End If
End Sub

Public Sub FlushClose
	Astream.SendAllAndClose
End Sub