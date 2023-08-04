B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
'Author: Alexander Stolte
'Version: 1.02
#If Documentation
Versions:
V1.00
	-Release
V1.01
	-Add BaseResize Event
V1.02
	-Add SkipButtonClicked Event
	-Add SkipButtonMode
		-SkipButtonMode_SKIP
		-SkipButtonMode_CLOSE
V1.03
	-BugFix
V1.04
	-Add compatibility for AS_ViewPager Version 2.0
V1.05
	-BugFix
V2.00
	-Complete lib. rewrite with new name
#End If

#DesignerProperty: Key: NextButton, DisplayName: Next Button Text, FieldType: String, DefaultValue: Next , Description: Text on Next Button
#DesignerProperty: Key: BackButton, DisplayName: Back Button Text, FieldType: String, DefaultValue: Back , Description: Text on Back Button
#DesignerProperty: Key: SkipButton, DisplayName: Skip Button Text, FieldType: String, DefaultValue: Skip , Description: Text on Skip Button
#DesignerProperty: Key: FinishButtonText, DisplayName: Finish Button Text, FieldType: String, DefaultValue: Get Started , Description: Text on Finish Button
#DesignerProperty: Key: ShowSkipButton, DisplayName: Show Skip Button, FieldType: Boolean, DefaultValue: True, Description: Enable Skip Button , Description: Enable Skip Button
#DesignerProperty: Key: ShowFinishButton, DisplayName: Show Finish Button, FieldType: Boolean, DefaultValue: True, Description: Enable Finish Button
#DesignerProperty: Key: ShowNextBackButton, DisplayName: Show Next and Back Buttons, FieldType: Boolean, DefaultValue: True

#DesignerProperty: Key: HeaderSize, DisplayName: Header Size in Percent, FieldType: Int, DefaultValue: 50,  MinRange: 25, MaxRange: 75, Description: Set the height percentage of the upper Header View 
#DesignerProperty: Key: IndicatorActiveColor, DisplayName: Indicator Active Color, FieldType: Color, DefaultValue: 0xFFFFFFFF, Description: The Color of the Indicators they are active
#DesignerProperty: Key: IndicatorInactiveColor, DisplayName: Indicator Inactive Color, FieldType: Color, DefaultValue: 0x98FFFFFF, Description: The Color of the Indicators they are inactive
#DesignerProperty: Key: TextColor, DisplayName: TextColor, FieldType: Color, DefaultValue: 0xFFFFFFFF, Description: Default Text Color
#DesignerProperty: Key: LoadingPanelColor, DisplayName: LoadingPanelColor, FieldType: Color, DefaultValue: 0xFFFFFFFF


#DesignerProperty: Key: SafeArea, DisplayName: SafeArea, FieldType: Boolean, DefaultValue: True, Description: B4I Only. If true then the safe area is observed at the bottom and the buttons are placed a bit higher up

#Event: PageChange(Index as int)
#Event: GetStartedButtonClick
#Event: BaseResize(Width As Double, Height As Double)
#Event: SkipButtonClicked(Mode as string)

Sub Class_Globals
	
	Type AS_SlidingOnboarding_BottomProperties(NextButtonText As String,BackButtonText As String,SkipButtonText As String,FinishButtonText As String,ShowSkipButton As Boolean,ShowFinishButton As Boolean,ShowNextBackButton As Boolean,xFont As B4XFont)
	Type AS_SlidingOnboarding_BottomButtons(SkipButton As B4XView, NextButton As B4XView,BackButton As B4XView,FinishButton As B4XView)
	
	Type AS_SlidingOnboarding_HeaderProperties(xFont As B4XFont,TextColor As Int)
	Type AS_SlidingOnboarding_DescriptionProperties(xFont As B4XFont,TextColor As Int)
	
	Type AS_SlidingOnboarding_Page(HeaderText As String,Description As String,BackgroundColor As Int,HeaderLayout As B4XView,Value As Object)
	
	Private g_BottomProperties As AS_SlidingOnboarding_BottomProperties
	Private g_BottomButtons As AS_SlidingOnboarding_BottomButtons
	Private g_HeaderProperties As AS_SlidingOnboarding_HeaderProperties
	Private g_DescriptionProperties As AS_SlidingOnboarding_DescriptionProperties
	
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private mBase As B4XView 'ignore
	Private xui As XUI 'ignore
	Public Tag As Object
	
	'Views
	Private xasvp_Main As ASViewPager	
	Private xpnl_CircleBackground As B4XView
	Private xlbl_SkipButton,xlbl_NextButton,xlbl_BackButton,xlbl_FinishButton As B4XView		
	Private IndicatorsCVS As B4XCanvas
		
	'Properties
	Private m_TextColor As Int
	Private m_SafeArea As Boolean 'Ignore
	Private m_LoadingPanelColor As Int
	Private g_IndicatorActiveColor,g_IndicatorInactiveColor As Int
	Private g_HeaderSize As Float
	Private g_skipbuttonmode As String = "Skip"
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
	Tag = mBase.Tag
	mBase.Tag = Me
  	
	If xasvp_Main.IsInitialized = False Then
		ini_props(Props)
		ini_views
	End If
	
	#If B4A
	Base_Resize(mBase.Width,mBase.Height)
	#End If
	
End Sub

Public Sub Base_Resize (Width As Double, Height As Double)
	
	xasvp_Main.Base_Resize(Width,Height)
	
	xpnl_CircleBackground.SetLayoutAnimated(0,0,Height - 30dip,Max(2dip,Width),20dip)
	
	IndicatorsCVS.Resize(Max(2dip,xpnl_CircleBackground.Width), Max(2dip,xpnl_CircleBackground.Height))
	DrawIndicators(xpnl_CircleBackground.Height,xasvp_Main.CurrentIndex)
	
	xlbl_BackButton.SetLayoutAnimated(0,0dip,Height - 40dip - 40dip,100dip,40dip)
	xlbl_NextButton.SetLayoutAnimated(0,Width - 100dip,Height - 40dip - 40dip,100dip,40dip)
	xlbl_SkipButton.SetLayoutAnimated(0,Width/2 - (Width - xlbl_BackButton.Width - xlbl_NextButton.Width)/2,Height - xpnl_CircleBackground.Height - 40dip,Width - xlbl_BackButton.Width - xlbl_NextButton.Width,40dip)
	xlbl_FinishButton.SetLayoutAnimated(0,Width/2 - (Width - xlbl_BackButton.Width - xlbl_NextButton.Width)/2,Height - 40dip - 40dip,Width - xlbl_BackButton.Width - xlbl_NextButton.Width,40dip)
	
	For i = 0 To xasvp_Main.Size -1
		
		Dim xpnl_page As B4XView = xasvp_Main.GetPanel(i)
		Dim xpnl_headerarea As B4XView = xpnl_page.GetView(0)
		Dim xpnl_bottomarea As B4XView = xpnl_page.GetView(1)
		
		Dim xlbl_HeaderText As B4XView = xpnl_bottomarea.GetView(0)
		Dim xlbl_DescriptionText As B4XView = xpnl_bottomarea.GetView(1)
		
		xpnl_headerarea.SetLayoutAnimated(0,0,0,Width,getHeaderHeight)
		xpnl_bottomarea.SetLayoutAnimated(0,0,Height * g_HeaderSize,Width,Height * (1 - g_HeaderSize))
		xlbl_HeaderText.SetLayoutAnimated(0,5dip,5dip,Width - 10dip,50dip)
		xlbl_DescriptionText.SetLayoutAnimated(0,5dip,xlbl_HeaderText.Height +5dip,Width - 10dip,(35 * xpnl_bottomarea.Height)/100)'xlbl_HeaderText.Top + xlbl_HeaderText.Height
	
	Next

	#If B4I
	If m_SafeArea Then
	
		xpnl_CircleBackground.Top = Height - xpnl_CircleBackground.Height - B4XPages.GetNativeParent(B4XPages.GetManager.GetTopPage.B4XPage).SafeAreaInsets.Height
		xlbl_BackButton.Top = xlbl_BackButton.Top - B4XPages.GetNativeParent(B4XPages.GetManager.GetTopPage.B4XPage).SafeAreaInsets.Height
		xlbl_NextButton.Top = xlbl_NextButton.Top - B4XPages.GetNativeParent(B4XPages.GetManager.GetTopPage.B4XPage).SafeAreaInsets.Height
		xlbl_SkipButton.Top = xlbl_SkipButton.Top - B4XPages.GetNativeParent(B4XPages.GetManager.GetTopPage.B4XPage).SafeAreaInsets.Height
		xlbl_FinishButton.Top = xlbl_FinishButton.Top - B4XPages.GetNativeParent(B4XPages.GetManager.GetTopPage.B4XPage).SafeAreaInsets.Height
	
	End If
	#End If

	If xui.SubExists(mCallBack, mEventName & "_BaseResize",2) Then
		CallSub3(mCallBack, mEventName & "_BaseResize",Width,Height)
	End If

End Sub

Private Sub ini_props(Props As Map)
	
	g_BottomProperties = CreateAS_SlidingOnboarding_BottomProperties(Props.Get("NextButton"),Props.Get("BackButton"),Props.Get("SkipButton"),Props.Get("FinishButtonText"),Props.Get("ShowSkipButton"),Props.Get("ShowFinishButton"),Props.Get("ShowNextBackButton"),xui.CreateDefaultBoldFont(15))
	g_BottomButtons = CreateAS_SlidingOnboarding_BottomButtons(xlbl_SkipButton,xlbl_NextButton,xlbl_BackButton,xlbl_FinishButton)
	
	g_HeaderProperties = CreateAS_SlidingOnboarding_HeaderProperties(xui.CreateDefaultBoldFont(20),xui.PaintOrColorToColor(Props.Get("TextColor")))
	g_DescriptionProperties = CreateAS_SlidingOnboarding_DescriptionProperties(xui.CreateDefaultBoldFont(15),xui.PaintOrColorToColor(Props.Get("TextColor")))
	
	g_HeaderSize = Props.Get("HeaderSize")  /100
	g_IndicatorActiveColor = xui.PaintOrColorToColor(Props.Get("IndicatorActiveColor"))
	g_IndicatorInactiveColor = xui.PaintOrColorToColor(Props.Get("IndicatorInactiveColor"))
	m_SafeArea = Props.Get("SafeArea")
	m_TextColor = xui.PaintOrColorToColor(Props.Get("TextColor"))
	m_LoadingPanelColor = xui.PaintOrColorToColor(Props.Get("LoadingPanelColor"))
	
End Sub

Private Sub ini_views
	
	xasvp_Main.Initialize(Me,"xasvp_main")
	xasvp_Main.DesignerCreateView(mBase,CreateLabel("",False),CreateMap("Orientation":"Horizontal","LoadingPanelColor":m_LoadingPanelColor))
	
	xpnl_CircleBackground = xui.CreatePanel("")
	xlbl_BackButton = CreateLabel("xlbl_BackButton",False)
	xlbl_NextButton = CreateLabel("xlbl_NextButton",False)
	xlbl_SkipButton = CreateLabel("xlbl_SkipButton",False)
	xlbl_FinishButton = CreateLabel("xlbl_FinishButton",False)
	
	mBase.AddView(xpnl_CircleBackground,0,0,2dip,2dip)
	mBase.AddView(xlbl_BackButton,0,0,0,0)
	mBase.AddView(xlbl_NextButton,0,0,0,0)
	mBase.AddView(xlbl_SkipButton,0,0,0,0)
	mBase.AddView(xlbl_FinishButton,0,0,0,0)
	
	ViewDefaultValues(xlbl_BackButton,g_BottomProperties.xFont,g_BottomProperties.BackButtonText,False)
	ViewDefaultValues(xlbl_NextButton,g_BottomProperties.xFont,g_BottomProperties.NextButtonText,g_BottomProperties.ShowNextBackButton)
	ViewDefaultValues(xlbl_SkipButton,g_BottomProperties.xFont,g_BottomProperties.SkipButtonText,g_BottomProperties.ShowSkipButton)
	ViewDefaultValues(xlbl_FinishButton,g_BottomProperties.xFont,g_BottomProperties.FinishButtonText,False)
	
	IndicatorsCVS.Initialize(xpnl_CircleBackground)
	
End Sub

Public Sub AddPage(HeaderText As String,Description As String,BackgroundColor As Int,HeaderLayout As B4XView,Value As Object)
	
	Dim Page As AS_SlidingOnboarding_Page
	Page.Initialize
	Page.HeaderText = HeaderText
	Page.Description = Description
	Page.BackgroundColor = BackgroundColor
	Page.HeaderLayout = HeaderLayout
	Page.Value = Value
	
	Dim xpnl_Page As B4XView = xui.CreatePanel("")
	xpnl_Page.SetLayoutAnimated(0,0,0,mBase.Width,mBase.Height)
	xpnl_Page.Color = BackgroundColor
	
	Dim xpnl_HeaderArea As B4XView = xui.CreatePanel("")
	Dim xpnl_BottomArea As B4XView = xui.CreatePanel("")
	
	xpnl_HeaderArea = HeaderLayout
	
	xpnl_Page.AddView(xpnl_HeaderArea,0,0,mBase.Width,getHeaderHeight)
	xpnl_Page.AddView(xpnl_BottomArea,0,0,mBase.Width,mBase.Height * (1 - g_HeaderSize))
	
	Dim xlbl_HeaderText As B4XView = CreateLabel("",False)
	Dim xlbl_DescriptionText As B4XView = CreateLabel("",True)
	
	xlbl_HeaderText.Text = HeaderText
	xlbl_DescriptionText.Text = Description
	
	xpnl_BottomArea.AddView(xlbl_HeaderText,0,0,0,0)
	xpnl_BottomArea.AddView(xlbl_DescriptionText,0,0,0,0)
	
	xasvp_Main.AddPage(xpnl_Page,Page)
	DrawIndicators(xpnl_CircleBackground.Height,xasvp_Main.CurrentIndex)
	
	xlbl_HeaderText.TextColor = g_HeaderProperties.TextColor
	xlbl_HeaderText.SetTextAlignment("CENTER","CENTER")
	xlbl_HeaderText.Font = g_HeaderProperties.xFont
	xlbl_DescriptionText.TextColor = g_DescriptionProperties.TextColor
	xlbl_DescriptionText.SetTextAlignment("TOP","CENTER")
	#IF B4J
	Dim jo As JavaObject = xlbl_DescriptionText
	jo.RunMethod("setTextAlignment", Array("CENTER"))
	#End IF
	xlbl_DescriptionText.Font = g_DescriptionProperties.xFont
	
	xpnl_HeaderArea.SetLayoutAnimated(0,0,0,mBase.Width,getHeaderHeight)
	xpnl_BottomArea.SetLayoutAnimated(0,0,mBase.Height * g_HeaderSize,mBase.Width,mBase.Height * (1 - g_HeaderSize))
	xlbl_HeaderText.SetLayoutAnimated(0,5dip,5dip,mBase.Width - 10dip,50dip)
	xlbl_DescriptionText.SetLayoutAnimated(0,5dip,xlbl_HeaderText.Height +5dip,mBase.Width - 10dip,(35 * xpnl_BottomArea.Height)/100)'xlbl_HeaderText.Top + xlbl_HeaderText.Height
	ShowOrHide(getCurrentIndex)
End Sub

Public Sub Clear
	xasvp_Main.Clear
End Sub

Public Sub getSize As Int
	Return xasvp_Main.Size
End Sub

Public Sub RemovePage(Index As Int)	
	xasvp_Main.RemovePage(Index)	
	DrawIndicators(xpnl_CircleBackground.Height,Index)
End Sub

Private Sub xasvp_main_PageChange(Index As Int)	
	DrawIndicators(xpnl_CircleBackground.Height,Index)
	PageChangeHandler(Index)
	ShowOrHide(Index)
End Sub

Private Sub ShowOrHide(index As Int)
	If index = 0 Then xlbl_BackButton.Visible = False Else xlbl_BackButton.Visible = g_BottomProperties.ShowNextBackButton
	If index = xasvp_Main.Size -1 Then xlbl_NextButton.Visible = False Else xlbl_NextButton.Visible = g_BottomProperties.ShowNextBackButton
	If index = xasvp_Main.Size -1 Then	xlbl_FinishButton.Visible = g_BottomProperties.ShowFinishButton Else xlbl_FinishButton.Visible = False
	If index < xasvp_Main.Size -1 Then	xlbl_SkipButton.Visible = g_BottomProperties.ShowSkipButton Else xlbl_SkipButton.Visible = False
End Sub

Private Sub b4x_backbtnClick	
	If xasvp_Main.Size > 0 And xasvp_Main.CurrentIndex > 0 Then		
		If xasvp_Main.CurrentIndex = 0 Then xlbl_BackButton.Visible = False
		xasvp_Main.PreviousPage
	End If	
End Sub

#If B4J

Private Sub xlbl_BackButton_MouseClicked (EventData As MouseEvent)	
	b4x_backbtnClick	
End Sub

#Else

Private Sub xlbl_BackButton_Click	
	b4x_backbtnClick	
End Sub

#End If

Private Sub b4x_nextbtnClick	
	If xasvp_Main.Size > 0 And xasvp_Main.CurrentIndex < xasvp_Main.Size -1 Then
		xlbl_BackButton.Visible = True
		xasvp_Main.NextPage
	End If	
End Sub

#If B4J
Private Sub xlbl_NextButton_MouseClicked (EventData As MouseEvent)
	b4x_nextbtnClick
End Sub
#Else
Private Sub xlbl_NextButton_Click	
	b4x_nextbtnClick
End Sub
#End If

#If B4J
Private Sub xlbl_SkipButton_MouseClicked (EventData As MouseEvent)	
	SkipButtonClickHandler	
End Sub
#Else
Private Sub xlbl_SkipButton_Click	
	SkipButtonClickHandler
End Sub
#End If

Private Sub SkipButtonClickHandler
	If g_skipbuttonmode = SkipButtonMode_CLOSE Then
		If xui.SubExists(mCallBack, mEventName & "_SkipButtonClicked",1) Then
			CallSub2(mCallBack, mEventName & "_SkipButtonClicked",g_skipbuttonmode)
		End If		
		Else
		xasvp_Main.CurrentIndex = xasvp_Main.Size -1
		If xui.SubExists(mCallBack, mEventName & "_SkipButtonClicked",1) Then
			CallSub2(mCallBack, mEventName & "_SkipButtonClicked",g_skipbuttonmode)
		End If
	End If
End Sub

#If B4J
Private Sub xlbl_FinishButton_MouseClicked (EventData As MouseEvent)	
	GetStartedButtonClickHandler	
End Sub
#Else
Private Sub xlbl_FinishButton_Click	
	GetStartedButtonClickHandler	
End Sub
#End If

Public Sub RefreshBottom
	xlbl_BackButton.Text = g_BottomProperties.BackButtonText
	xlbl_FinishButton.Text = g_BottomProperties.FinishButtonText
	xlbl_NextButton.Text = g_BottomProperties.NextButtonText
	xlbl_SkipButton.Text = g_BottomProperties.SkipButtonText
	
	ShowOrHide(getCurrentIndex)
	
End Sub

Public Sub GenerateImageView(ImageName As String) As B4XView
	Dim scale As Float = 1
	#If B4I
	scale = GetDeviceLayoutValues.NonnormalizedScale
	#End If
	Private ImageView1 As ImageView
	ImageView1.Initialize("")
	ImageView1.As(B4XView).SetLayoutAnimated(0,0,0,mBase.Width,getHeaderHeight)
	ImageView1.As(B4XView).SetBitmap(xui.LoadBitmapResize(File.DirAssets,ImageName,mBase.Width  * scale,getHeaderHeight  * scale,True))
	Return ImageView1
End Sub

#Region Enums
Public Sub SkipButtonMode_SKIP As String
	Return "Skip"
End Sub
Public Sub SkipButtonMode_CLOSE As String
	Return "Close"
End Sub
#End Region

#Region Properties

Public Sub setLoadingPanelColor(Color As Int)
	m_LoadingPanelColor = Color
	xasvp_Main.LoadingPanelColor = Color
End Sub

Public Sub getLoadingPanelColor As Int
	Return m_LoadingPanelColor
End Sub

Public Sub getHeaderProperties As AS_SlidingOnboarding_HeaderProperties
	Return g_HeaderProperties
End Sub

Public Sub getDescriptionProperties As AS_SlidingOnboarding_DescriptionProperties
	Return g_DescriptionProperties
End Sub

Public Sub getBottomButtons As AS_SlidingOnboarding_BottomButtons
	Return g_BottomButtons
End Sub

'Call RefreshBottom if you change something
Public Sub getBottomProperties As AS_SlidingOnboarding_BottomProperties
	Return g_BottomProperties
End Sub

Public Sub setSkipButtonMode(mode As String)
	If mode = SkipButtonMode_CLOSE Then
		g_skipbuttonmode = SkipButtonMode_CLOSE
		Else
		g_skipbuttonmode = SkipButtonMode_SKIP
	End If
End Sub
Public Sub getSkipButtonMode As String
	Return g_skipbuttonmode
End Sub
'gets the Bottom Panel
Public Sub BottomPanel(Index As Int) As B4XView
	Return xasvp_Main.GetPanel(Index).GetView(1)
End Sub
'gets the Header Area Panel to change the Header Layout
Public Sub HeaderPanel(Index As Int) As B4XView
	Return xasvp_Main.GetPanel(Index).GetView(0)
End Sub
'If you want to change the background color of a page or you want to add your own views on the full page instead just on the header
Public Sub PageBackgroundPanel(Index As Int) As B4XView
	Return xasvp_Main.GetPanel(Index)
End Sub
'This View is based on the ASViewPager
Public Sub getViewPager As ASViewPager
	Return xasvp_Main
End Sub
#If B4A or B4I
'The View is based of the ASViewPager and this Pager is based on the xCustomListView
Public Sub getCustomListView As CustomListView
	Return xasvp_Main.CustomListView
End Sub
#Else
'The View is based of the ASViewPager and this Pager is based on the xCustomListView
Public Sub getCustomListView As jPager
	Return xasvp_main.jPager
End Sub
#End If

'sets or gets the current index
Public Sub setCurrentIndex(index As Int)
	xasvp_Main.CurrentIndex = index
End Sub

Public Sub getCurrentIndex As Int
	Return xasvp_Main.CurrentIndex
End Sub
'gets or sets the inactive indicator color
Public Sub setIndicatorInactiveColor(clr As Int)
	g_IndicatorInactiveColor = clr
	DrawIndicators(xpnl_CircleBackground.Height,xasvp_Main.CurrentIndex)
End Sub
Public Sub getIndicatorInactiveColor As Int
	Return g_IndicatorInactiveColor
End Sub
'gets or sets the active indicator color
Public Sub setIndicatorActiveColor(clr As Int)
	 g_IndicatorActiveColor = clr
	DrawIndicators(xpnl_CircleBackground.Height,xasvp_Main.CurrentIndex)
End Sub

Public Sub getIndicatorActiveColor As Int
	Return g_IndicatorActiveColor
End Sub


Public Sub setShowIndicator(visible As Boolean)
	xpnl_CircleBackground.Visible = visible
End Sub

'The header size must be between 25 and 75 if not the value is set to 50
Public Sub setHeaderSize(header_size As Float)
	If header_size >= 25 Or header_size <= 75 Then g_HeaderSize = header_size/100 Else g_HeaderSize = 50/100
	Base_Resize(mBase.Width,mBase.Height)
End Sub

'gets the Header Height
Public Sub getHeaderHeight As Float
	Return mBase.Height * g_HeaderSize
End Sub

#End Region

#Region Events

Private Sub PageChangeHandler(Page As Int)	
	If xui.SubExists(mCallBack, mEventName & "_PageChange",0) Then
		CallSub2(mCallBack, mEventName & "_PageChange",Page)
	End If
End Sub

Private Sub GetStartedButtonClickHandler	
	If xui.SubExists(mCallBack, mEventName & "_GetStartedButtonClick",0) Then
		CallSub(mCallBack, mEventName & "_GetStartedButtonClick")
	End If	
End Sub

#End Region

#Region Functions

'https://www.b4x.com/android/forum/threads/b4x-xui-imageslider.87128/
Private Sub DrawIndicators(Height As Float,Index As Int)
	'If pagelist.Size < Then Return
	IndicatorsCVS.ClearRect(IndicatorsCVS.TargetRect)
	Dim clr As Int
	For i = 0 To xasvp_Main.Size - 1
		If Index = i Then clr = g_IndicatorActiveColor Else clr =  g_IndicatorInactiveColor
		IndicatorsCVS.DrawCircle(IndicatorsCVS.TargetRect.CenterX + (-(xasvp_Main.Size - 1) / 2 + i) * 18dip, Height/2, 4dip, clr, True, 0)
		'Sleep(0)
	Next
	IndicatorsCVS.Invalidate
End Sub

Private Sub CreateLabel(EventName As String,Multiline As Boolean) As B4XView	'Ignore
	Dim tmp_lbl As Label
	tmp_lbl.Initialize(EventName)
	#IF B4J
	tmp_lbl.WrapText = Multiline
	#Else If B4I
	tmp_lbl.Multiline = Multiline
	#End IF
	Return tmp_lbl
End Sub

'Just to safe codelines :P
Private Sub ViewDefaultValues(View As B4XView,xFont As B4XFont,Text As String,Visible As Boolean)	
	View.TextColor = m_TextColor
	View.SetTextAlignment("CENTER","CENTER")
	View.Font = xFont
	View.Text = Text
	View.Visible = Visible
End Sub

#End Region

Private Sub CreateAS_SlidingOnboarding_Page (HeaderText As String, Description As String, BackgroundColor As Int, HeaderLayout As B4XView, Value As Object) As AS_SlidingOnboarding_Page
	Dim t1 As AS_SlidingOnboarding_Page
	t1.Initialize
	t1.HeaderText = HeaderText
	t1.Description = Description
	t1.BackgroundColor = BackgroundColor
	t1.HeaderLayout = HeaderLayout
	t1.Value = Value
	Return t1
End Sub

Private Sub CreateAS_SlidingOnboarding_BottomButtons (SkipButton As B4XView, NextButton As B4XView, BackButton As B4XView, FinishButton As B4XView) As AS_SlidingOnboarding_BottomButtons
	Dim t1 As AS_SlidingOnboarding_BottomButtons
	t1.Initialize
	t1.SkipButton = SkipButton
	t1.NextButton = NextButton
	t1.BackButton = BackButton
	t1.FinishButton = FinishButton
	Return t1
End Sub

Private Sub CreateAS_SlidingOnboarding_BottomProperties (NextButtonText As String, BackButtonText As String, SkipButtonText As String, FinishButtonText As String, ShowSkipButton As Boolean, ShowFinishButton As Boolean, ShowNextBackButton As Boolean, xFont As B4XFont) As AS_SlidingOnboarding_BottomProperties
	Dim t1 As AS_SlidingOnboarding_BottomProperties
	t1.Initialize
	t1.NextButtonText = NextButtonText
	t1.BackButtonText = BackButtonText
	t1.SkipButtonText = SkipButtonText
	t1.FinishButtonText = FinishButtonText
	t1.ShowSkipButton = ShowSkipButton
	t1.ShowFinishButton = ShowFinishButton
	t1.ShowNextBackButton = ShowNextBackButton
	t1.xFont = xFont
	Return t1
End Sub

Private Sub CreateAS_SlidingOnboarding_HeaderProperties (xFont As B4XFont, TextColor As Int) As AS_SlidingOnboarding_HeaderProperties
	Dim t1 As AS_SlidingOnboarding_HeaderProperties
	t1.Initialize
	t1.xFont = xFont
	t1.TextColor = TextColor
	Return t1
End Sub

Private Sub CreateAS_SlidingOnboarding_DescriptionProperties (xFont As B4XFont, TextColor As Int) As AS_SlidingOnboarding_DescriptionProperties
	Dim t1 As AS_SlidingOnboarding_DescriptionProperties
	t1.Initialize
	t1.xFont = xFont
	t1.TextColor = TextColor
	Return t1
End Sub