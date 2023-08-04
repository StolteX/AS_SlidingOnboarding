B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private AS_SlidingOnboarding1 As AS_SlidingOnboarding
End Sub

Public Sub Initialize
	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("frm_main")
	
	B4XPages.SetTitle(Me,"AS SlidingOnboarding Example")
	
	Sleep(0)
	
	AS_SlidingOnboarding1.AddPage("B4X development tools", "With B4X, anyone who wants to, can develop real-world solutions." & CRLF & "B4X suite supports more platforms than any other tool." & CRLF & "ANDROID | IOS | WINDOWS | MAC | LINUX | ARDUINO | RASPBERRY PI | ESP8266 | AND MORE...",xui.Color_RGB(10, 169, 195),	AS_SlidingOnboarding1.GenerateImageView("1.png"),"")
	AS_SlidingOnboarding1.AddPage("B4A – The simple way to develop native Android apps","B4A includes all the features needed to quickly develop any type of Android app." & CRLF & "B4A is used by tens of thousands of developers from all over the world, including companies such as NASA, HP, IBM and others." & CRLF & "Together with B4i you can now easily develop applications for both Android and iOS.",xui.Color_RGB(13, 205, 198),AS_SlidingOnboarding1.GenerateImageView("basic4android-b4a.png"),"")
	AS_SlidingOnboarding1.AddPage("B4i – The simple way to develop native iOS apps", "B4i is a development tool for native iOS applications." & CRLF & "B4i follows the same concepts as B4A, allowing you to reuse most of the code and build apps for both Android and iOS." & CRLF & "This is the only development tool that allows you to develop 100% native iOS apps without a local Mac computer.",xui.Color_RGB(101, 101, 101),AS_SlidingOnboarding1.GenerateImageView("b4i.jpg"),"")
	AS_SlidingOnboarding1.AddPage("B4J – RAD development tool for cross platform desktop, server and IoT solutions", "B4J is a 100% free development tool for desktop, server and IoT solutions." & CRLF & "With B4J you can easily create desktop applications (UI), console programs (non-UI) and server solutions." & CRLF & "The compiled apps can run on Windows, Mac, Linux and ARM boards (such as Raspberry Pi).",xui.Color_RGB(255, 57, 174),	AS_SlidingOnboarding1.GenerateImageView("b4j.png"),"")
	AS_SlidingOnboarding1.AddPage("Powerfull B4X Forum","If you have any questions, then you can ask this question in the forum and the nicest peoples in the forum answer on them.",xui.Color_RGB(40, 89, 154),AS_SlidingOnboarding1.GenerateImageView("b4x forum.png"),"")

End Sub