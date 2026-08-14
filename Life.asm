
//
//Conventions:
//

	@SCREEN		//SP=SCREEN-1
	D=A-1
	@SP
	M=D

//Initialize(INI)willloadsometablesintoRAMfromROM

	@INI.Ret		//D=INIreturnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Initialize	//Initialize()
	0;JMP

(INI.Ret)			//ReturnfromInitializehere

//InitialLogoLoad(ILL)willsetuptheboard

	@ILL.Ret		//D=ILLreturnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Logo.Board	//D=Test.Board(addressofCODEtoruntoimporttheboarddatafromrom)
	D=A

	@Load_Board	//Load_Board()
	0;JMP

(ILL.Ret)			//ReturnfromLoad_Boardhere

//Initializecursorlocationandstate

	@32			//Life.x=32(xpositionofcursor)
	D=A
	@Life.x
	M=D

	@16			//Life.y=16(ypositionofcursor)
	D=A
	@Life.y
	M=D

	@Life.key.repeat	//autorepeatflag
	M=0

	@Life.blink	//Life.blink=1(cursorblinkcounter)
	M=1

	@32767			//Life.speed=32677(cursorblinkspeed)
	D=A
	@Life.speed
	M=D

	@KBD			//Life.key=[KBD]
	D=M
	@Key.Pressed
	M=D

	@Key.Up		//Skiptoendofkeyprocessingloopifwehaveakey
	D;JNE		//Thishandlesstalekeyonprogramstart

//Loopprocessingkeys,blinkingcursorwhilewaiting

(Key.Down)			//Loopuntilkeypressed

	@KBD			//D=[KBD]
	D=M

	@Key.Pressed	//ifakeyhasbeenpressed,processit
	D;JNE

	D=D			//NOPinstructionstoslowdownthisloop
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D
	D=D

	@Life.blink	//if--Life.blink==0,blinkcursor
	MD=M-1
	@Key.Down
	D;JNE

//Blinkthecursor

(Blink)

	@Life.speed	//Life.blink=Life.speed(resetsblinkcount)
	D=M
	@Life.blink
	M=D

//Computethelocationinthescreenbufferofthecurrentcursorposition.
//Thereare32bytesperrow,and8rowspercell.32*8=256.Wealsoskip
//2rowsbecauseweonlymodifythecentral4x4pixelsofacell.

	@Life.y		//Blink.row=(Life.y*256)+SCREEN+64
	AD=M
	AD=D+A
	AD=D+A
	AD=D+A
	AD=D+A
	AD=D+A
	AD=D+A
	AD=D+A
	AD=D+A
	@16448
	D=D+A
	@Blink.row
	M=D

//Eachwordinthescreenbufferholdsthebitsfortwoadjacentcells.Use
//thelowbitofLife.xtodeterminewhichbyteofthewordisusedbythe
//currentcell,andcreateamask.

	D=-1			//D=1111...1110
	D=D-1
	@Life.x
	D=D&M		//D=Life.xwithlowbitmaskedoff

	@Life.x		//iflowbitset,upperbytecontainsmask
	D=D-M
	@Blink.Upper
	D;JNE

(Blink.Lower)

	@60			//D=0000000000111100
	D=A
	@Blink.Xor
	0;JMP

(Blink.Upper)

	@15360			//D=0011110000000000
	D=A

(Blink.Xor)

	@Blink.mask	//Blink.mask=XORmaskofbitstoflip
	M=D

	@Life.x		//Blink.row=Blink.row+DivByTwo[Life.x]
	D=M			//Sincewedon'thaveashift-rightinstruction
	@9700			//weusealookuptable@9700
	A=D+A
	D=M

	@Blink.row		//AlsosaveBlink.rowinA,soMthenpoints
	AM=D+M		//tothefirstwordinscreemmemorywewanttoalter

	D=M			//Blink.word=[Blink.row]
	@Blink.word
	M=D

	@Blink.mask	//Blink.new=Blink.wordXORBlink.mask
	D=D|M		//XOR(A,B)=(A|B)&!(A&B)
	@Blink.or
	M=D

	@Blink.word
	D=M
	@Blink.mask
	D=D&M
	D=!D

	@Blink.or
	D=D&M

	@Blink.new
	M=D

	@Blink.row		//[Blink.row]=Blink.new
	A=M
	M=D

	@Blink.row		//[Blink.row+=32]=Blink.new
	D=M
	@32
	D=D+A
	@Blink.row
	M=D

	@Blink.new
	D=M

	@Blink.row
	A=M
	M=D

	@Blink.row		//[Blink.row+=32]=Blink.new
	D=M
	@32
	D=D+A
	@Blink.row
	M=D

	@Blink.new
	D=M

	@Blink.row
	A=M
	M=D

	@Blink.row		//[Blink.row+=32]=Blink.new
	D=M
	@32
	D=D+A
	@Blink.row
	M=D

	@Blink.new
	D=M

	@Blink.row
	A=M
	M=D

	@Key.Down		//Resumelookingforakey
	0;JMP

(Key.Pressed)

	@Life.key		//@Life.key=D
	M=D

	//Arrowkeys

	@Life.key		//Up
	D=M
	@131
	D=D-A
	@Key.MoveUp
	D;JEQ

	@Life.key		//Down
	D=M
	@133
	D=D-A
	@Key.MoveDown
	D;JEQ

	@Life.key		//Right
	D=M
	@132
	D=D-A
	@Key.MoveRight
	D;JEQ

	@Life.key		//Left
	D=M
	@130
	D=D-A
	@Key.MoveLeft
	D;JEQ

	//8-waykeys

	@Life.key		//W=Up
	D=M
	@87
	D=D-A
	@Key.MoveUp
	D;JEQ

	@Life.key		//X=Down
	D=M
	@88
	D=D-A
	@Key.MoveDown
	D;JEQ

	@Life.key		//D=Right
	D=M
	@68
	D=D-A
	@Key.MoveRight
	D;JEQ

	@Life.key		//A=Left
	D=M
	@65
	D=D-A
	@Key.MoveLeft
	D;JEQ

	@Life.key		//Q=Up-Left
	D=M
	@81
	D=D-A
	@Key.MoveUpLeft
	D;JEQ

	@Life.key		//E=Up-Right
	D=M
	@69
	D=D-A
	@Key.MoveUpRight
	D;JEQ

	@Life.key		//Z=Down-Left
	D=M
	@90
	D=D-A
	@Key.MoveDownLeft
	D;JEQ

	@Life.key		//C=Down-Right
	D=M
	@67
	D=D-A
	@Key.MoveDownRight
	D;JEQ

	@Life.key		//Spacebar?
	D=M
	@32			
	D=D-A
	@Key.Space			
	D;JEQ

	@Life.key		//Enter
	D=M
	@78
	D=D-A
	@Key.Enter
	D;JEQ

	@Life.key		//DEL
	D=M
	@139
	D=D-A
	@Key.Clear
	D;JEQ

	@Life.key		//`=Togglecell
	D=M
	@96
	D=D-A
	@Key.Toggle
	D;JEQ

	@Life.key		//S=Togglecell
	D=M
	@83
	D=D-A
	@Key.Toggle
	D;JEQ

	@Life.key		//<=Savebuffer
	D=M
	@60
	D=D-A
	@Key.Save
	D;JEQ

	@Life.key		//>=Restorebuffer
	D=M
	@62
	D=D-A
	@Key.Restore
	D;JEQ

	@Life.key		//,=Savebuffer
	D=M
	@44
	D=D-A
	@Key.Save
	D;JEQ

	@Life.key		//.=Restorebuffer
	D=M
	@46
	D=D-A
	@Key.Restore
	D;JEQ

	//otherkeyshere

	//Lastthingwecheckisloadingprestoredpatterns.First,we
	//prepareforaneventualfunctioncalltoLoad_Board(),with
	//adirectreturntotheendofourkeyboardhandler

	@Key.Up
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	//Next,welookforapatternkeyandsettheDregisterwiththe
	//addressoftheboard.

	@Life.key
	D=M
	@48
	D=D-A

	@Key.Pattern0
	D;JEQ

	D=D-1
	@Key.Pattern1
	D;JEQ

	D=D-1
	@Key.Pattern2
	D;JEQ

	D=D-1
	@Key.Pattern3
	D;JEQ

	D=D-1
	@Key.Pattern4
	D;JEQ

	D=D-1
	@Key.Pattern5
	D;JEQ

	D=D-1
	@Key.Pattern6
	D;JEQ

	D=D-1
	@Key.Pattern7
	D;JEQ

	D=D-1
	@Key.Pattern8
	D;JEQ

	D=D-1
	@Key.Pattern9
	D;JEQ

	//roomformorepatternsasneeded

(Key.Pattern6)
(Key.Pattern7)
(Key.Pattern8)
(Key.Pattern9)

	//Ifwegettohere,wedon'thaveavalidboard,soweneed
	//torestoretheSP

	@SP			//Poptheun-neededreturnaddressoffstack
	M=M+1

	@Key.Up		//Andskiptothebottomofthehandler
	0;JMP
	0;JMP

(Key.Pattern0)
	
	@Logo.Board
	D=A
	@Load_Board	//Load_Board()willreturntoKey.Up
	0;JMP

(Key.Pattern1)

	@Oscillator.Board
	D=A
	@Load_Board	//Load_Board()willreturntoKey.Up
	0;JMP

(Key.Pattern2)

	@Gliders.Board
	D=A
	@Load_Board	//Load_Board()willreturntoKey.Up
	0;JMP

(Key.Pattern3)

	@Gosper.Glider.Gun
	D=A
	@Load_Board	//Load_Board()willreturntoKey.Up
	0;JMP

(Key.Pattern4)

	@Beacon.Maker
	D=A
	@Load_Board	//Load_Board()willreturntoKey.Up
	0;JMP

(Key.Pattern5)

	@Blinker.Puffer
	D=A
	@Load_Board	//Load_Board()willreturntoKey.Up
	0;JMP

//Spacebar-runageneration

(Key.Space)

	@Key.Space.Ret	//D=Generationreturnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Generation	//Generation()
	0;JMP

(Key.Space.Ret)

	@Key.Up
	0;JMP

//C-cleartheboard

(Key.Clear)

	@Key.Change		//D=returndirectlytoKey.Changehandlerbelow
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Clear_Board	//Clear_Board()
	0;JMP

//S-savetheboard(twolevelsofsave)

(Key.Save)

	@Key.Save.2		//D=returnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@6999			//Key.Board.From=7000-1
	D=A
	@Key.Board.From
	M=D

	@4499			//Key.Board.To=4500-1
	D=A
	@Key.Board.To
	M=D

	@Key.Buffer.Copy
	0;JMP

(Key.Save.2)

	@Key.Change		//D=returndirectlytoKey.Changehandlerbelow
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@9999			//Key.Board.From=10000-1
	D=A
	@Key.Board.From
	M=D

	@6999			//Key.Board.To=7000-1
	D=A
	@Key.Board.To
	M=D

	@Key.Buffer.Copy
	0;JMP

//R-Restoretheboard

(Key.Restore)

	@Key.Restore.2	//D=returnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@9999			//Key.Board.To=10000-1
	D=A
	@Key.Board.To
	M=D

	@6999			//Key.Board.From=7000-1
	D=A
	@Key.Board.From
	M=D

	@Key.Buffer.Copy
	0;JMP

(Key.Restore.2)

	@Key.Change		//D=returndirectlytoKey.Changehandlerbelow
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@6999			//Key.Board.To=7000-1
	D=A
	@Key.Board.To
	M=D

	@4499			//Key.Board.From=4500-1
	D=A
	@Key.Board.From
	M=D

	//fallthroughtocopy

(Key.Buffer.Copy)

	@2244				//Key.Board.Count=2244(BoardSize+1)
	D=A
	@Key.Board.Count
	M=D

(Key.Buffer.Copy.Top)	//repeat[++Key.Board.To]=[++Key.Board.From]until(--Key.Board.Count==0)

	@Key.Board.From	//D=[++Key.Board.From]
	M=M+1
	A=M
	D=M

	@Key.Board.To		//[++Key.Board.To]=D
	M=M+1
	A=M
	M=D

	@Key.Board.Count	//Loop
	MD=M-1
	@Key.Buffer.Copy.Top
	D;JNE

	//returntocaller

	@SP			//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//UpLeft-movecursor

(Key.MoveUpLeft)

	@63		//Life.x=(Life.x-1)&03F(63)
	D=A		//thenfallthroughtomoveup
	@Life.x
	M=M-1
	M=D&M

//Up-movecursor

(Key.MoveUp)

	@31		//Life.y=(Life.y-1)&01F(31)
	D=A
	@Life.y
	M=M-1
	M=D&M

	@Key.Change
	0;JMP

//DownRight-movecursor

(Key.MoveDownRight)

	@63		//Life.x=(Life.x+1)&03F(63)
	D=A		//thenfallthroughtomovedown
	@Life.x
	M=M+1
	M=D&M

//Down-movecursor

(Key.MoveDown)

	@31		//Life.y=(Life.y+1)&01F(31)
	D=A
	@Life.y
	M=M+1
	M=D&M

	@Key.Change
	0;JMP

//DownLeft-movecursor

(Key.MoveDownLeft)

	@31		//Life.y=(Life.y+1)&01F(31)
	D=A		//thenfallthroughtomoveleft
	@Life.y
	M=M+1
	M=D&M

//Left-movecursor

(Key.MoveLeft)

	@63		//Life.x=(Life.x-1)&03F(63)
	D=A
	@Life.x
	M=M-1
	M=D&M

	@Key.Change
	0;JMP

//UpRight-movecursor

(Key.MoveUpRight)

	@31		//Life.y=(Life.y-1)&01F(31)
	D=A		//thenfallthroughtomoveright
	@Life.y
	M=M-1
	M=D&M

//Right-movecursor

(Key.MoveRight)

	@63		//Life.x=(Life.x+1)&03F(63)
	D=A
	@Life.x
	M=M+1
	M=D&M

	@Key.Change
	0;JMP

//togglecurrentcell

(Key.Toggle)

	@66				//R2=10067+66*Life.y+Life.x
	D=A
	@Mult.b
	M=D

	@Life.y
	D=M
	@Mult.a
	M=D

	@Key.Toggle.Ret	//D=returnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Mult			//Mult.result=Life.y*66
	0;JMP

(Key.Toggle.Ret)

	@10067			//D=10067+Life.x
	D=A
	@Life.x
	D=D+M

	@Mult.result
	M=D+M

	A=M			//D=![cellcontents]
	D=!M

	@32767			//A=0111...1111
	A=A+1		//A=1000...0000
	D=D&A		//Maskedofflowbits

	@Mult.result	//updatecellcontents
	A=M
	M=D

	@Key.Change
	0;JMP

//Enter-rungenerationsuntilanotherkeypressed

(Key.Enter)

	@Key.Enter.Ret	//D=Generationreturnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Generation	//Generation()
	0;JMP

(Key.Enter.Ret)

	@KBD			//DoanothergenerationifKBD==Life.key(either128or0)
	D=M
	@Life.key
	D=D-M
	@Key.Enter
	D;JEQ

	@Life.key		//Resetthecurrentkey(sowewillcatch"nokey"justabove,butnowEnterwillstopus)
	M=0

	@KBD			//Ifnokey,wecanloop
	D=M
	@Key.Enter
	D;JEQ

	@Life.key		//RestoreLife.keytocurrentkey,soit'llbedebouncedbelow
	M=D

	@Key.Up		//Terminatelooping
	0;JMP

//Handlechangesinstatebyrepaintingthescreen(andjumptoKey.Uphandleronreturn)

(Key.Change)

	@Key.Up			//D=returnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Paint_Board	//Paint_Board()
	0;JMP

//Bottomofkeyprocessingloop

(Key.Up)			//LoopuntilKBDnolongerLife.key(eithernewkeyorkeyup)

	@Life.key
	D=M
	@KBD
	D=D-M
	@Key.Up
	D;JEQ

	@Key.Down		//Returntocheckingfornewkey
	0;JMP

//Doneinfiniteloop(notactuallyreachable)

	@DONE
(DONE)
	0;JMP

//Generation:runsasinglegenerationofLife,thenupdatestheboarddisplay

(Generation)
(G)

	//Phase1:foreachlivingcell(notcountingtheguardcells),incrementall
	//theneighbors,sotheyhaveacountofhowmanyneighborstheyhave.Notethat
	//wecanplowthroughalltheguardcellsonleftandrightbecausetheywill
	//alwaysbedead,andit'sfastertodothisthandoadouble-loopwithskip.

	@10067			//G.cell=10067,thefirstrealcell
	D=A
	@G.cell
	M=D

(G.1.Top)			//repeatcheck_celluntil++G.cell==12177(1pastlastcell)

	@G.cell		//if[G.cell]>=0,skiptobottomofloop(it'sdead)
	A=M
	D=M
	@G.1.Bottom
	D;JGE

	@G.cell		//[G.cell-67]++(top-leftneighbor)
	D=M
	@67
	A=D-A
	M=M+1

	A=A+1		//[G.cell-66]++(topneighbor)
	M=M+1

	A=A+1		//[G.cell-65]++(top-rightneighbor)
	M=M+1

	D=A			//[G.cell-1]++(leftneighbor)
	@64
	A=D+A
	M=M+1

	A=A+1		//[G.cell+1]++(rightneighbor)
	A=A+1
	M=M+1

	D=A			//[G.cell+65]++(bottom-leftneighbor)
	@64
	A=D+A
	M=M+1

	A=A+1		//[G.cell+66]++(bottomneighbor)
	M=M+1

	A=A+1		//[G.cell+67]++(bottom-rightneighbor)
	M=M+1

(G.1.Bottom)

	@G.cell		//D,G.cell=G.cell+1
	MD=M+1
	@12177			//if(G.cell!=12177)gotoG.1.Top
	D=D-A
	@G.1.Top
	D;JNE

	//Phase2:addthecountsintheguardcellstotheirrespectivebordercells
	//ontheoppositeedge,andcleartheguardcells.Hereisamapoftheguard
	//cellsandtheedgecells
	//
	//1000010001.....1006410065
	//1006610067.....1013010131
	//....
	//....
	//1211212113.....1217612177
	//1217812179.....1224212243
	//
	//Thefollowingcodewasauto-generatedbyboardmaker.py.Thisisacasewhere
	//unrollingtheloopsisabigwinbecausewedon'thavetodoaddressarithmetic.

	//Thefourcorners

	@10000
	D=M
	M=0
	@12176
	M=D+M

	@10065
	D=M
	M=0
	@12113
	M=D+M

	@12178
	D=M
	M=0
	@10130
	M=D+M

	@12243
	D=M
	M=0
	@10067
	M=D+M

	//Thetopandbottomrows

	@10001
	D=M
	M=0
	@12113
	M=D+M

	@12179
	D=M
	M=0
	@10067
	M=D+M

	@10002
	D=M
	M=0
	@12114
	M=D+M

	@12180
	D=M
	M=0
	@10068
	M=D+M

	@10003
	D=M
	M=0
	@12115
	M=D+M

	@12181
	D=M
	M=0
	@10069
	M=D+M

	@10004
	D=M
	M=0
	@12116
	M=D+M

	@12182
	D=M
	M=0
	@10070
	M=D+M

	@10005
	D=M
	M=0
	@12117
	M=D+M

	@12183
	D=M
	M=0
	@10071
	M=D+M

	@10006
	D=M
	M=0
	@12118
	M=D+M

	@12184
	D=M
	M=0
	@10072
	M=D+M

	@10007
	D=M
	M=0
	@12119
	M=D+M

	@12185
	D=M
	M=0
	@10073
	M=D+M

	@10008
	D=M
	M=0
	@12120
	M=D+M

	@12186
	D=M
	M=0
	@10074
	M=D+M

	@10009
	D=M
	M=0
	@12121
	M=D+M

	@12187
	D=M
	M=0
	@10075
	M=D+M

	@10010
	D=M
	M=0
	@12122
	M=D+M

	@12188
	D=M
	M=0
	@10076
	M=D+M

	@10011
	D=M
	M=0
	@12123
	M=D+M

	@12189
	D=M
	M=0
	@10077
	M=D+M

	@10012
	D=M
	M=0
	@12124
	M=D+M

	@12190
	D=M
	M=0
	@10078
	M=D+M

	@10013
	D=M
	M=0
	@12125
	M=D+M

	@12191
	D=M
	M=0
	@10079
	M=D+M

	@10014
	D=M
	M=0
	@12126
	M=D+M

	@12192
	D=M
	M=0
	@10080
	M=D+M

	@10015
	D=M
	M=0
	@12127
	M=D+M

	@12193
	D=M
	M=0
	@10081
	M=D+M

	@10016
	D=M
	M=0
	@12128
	M=D+M

	@12194
	D=M
	M=0
	@10082
	M=D+M

	@10017
	D=M
	M=0
	@12129
	M=D+M

	@12195
	D=M
	M=0
	@10083
	M=D+M

	@10018
	D=M
	M=0
	@12130
	M=D+M

	@12196
	D=M
	M=0
	@10084
	M=D+M

	@10019
	D=M
	M=0
	@12131
	M=D+M

	@12197
	D=M
	M=0
	@10085
	M=D+M

	@10020
	D=M
	M=0
	@12132
	M=D+M

	@12198
	D=M
	M=0
	@10086
	M=D+M

	@10021
	D=M
	M=0
	@12133
	M=D+M

	@12199
	D=M
	M=0
	@10087
	M=D+M

	@10022
	D=M
	M=0
	@12134
	M=D+M

	@12200
	D=M
	M=0
	@10088
	M=D+M

	@10023
	D=M
	M=0
	@12135
	M=D+M

	@12201
	D=M
	M=0
	@10089
	M=D+M

	@10024
	D=M
	M=0
	@12136
	M=D+M

	@12202
	D=M
	M=0
	@10090
	M=D+M

	@10025
	D=M
	M=0
	@12137
	M=D+M

	@12203
	D=M
	M=0
	@10091
	M=D+M

	@10026
	D=M
	M=0
	@12138
	M=D+M

	@12204
	D=M
	M=0
	@10092
	M=D+M

	@10027
	D=M
	M=0
	@12139
	M=D+M

	@12205
	D=M
	M=0
	@10093
	M=D+M

	@10028
	D=M
	M=0
	@12140
	M=D+M

	@12206
	D=M
	M=0
	@10094
	M=D+M

	@10029
	D=M
	M=0
	@12141
	M=D+M

	@12207
	D=M
	M=0
	@10095
	M=D+M

	@10030
	D=M
	M=0
	@12142
	M=D+M

	@12208
	D=M
	M=0
	@10096
	M=D+M

	@10031
	D=M
	M=0
	@12143
	M=D+M

	@12209
	D=M
	M=0
	@10097
	M=D+M

	@10032
	D=M
	M=0
	@12144
	M=D+M

	@12210
	D=M
	M=0
	@10098
	M=D+M

	@10033
	D=M
	M=0
	@12145
	M=D+M

	@12211
	D=M
	M=0
	@10099
	M=D+M

	@10034
	D=M
	M=0
	@12146
	M=D+M

	@12212
	D=M
	M=0
	@10100
	M=D+M

	@10035
	D=M
	M=0
	@12147
	M=D+M

	@12213
	D=M
	M=0
	@10101
	M=D+M

	@10036
	D=M
	M=0
	@12148
	M=D+M

	@12214
	D=M
	M=0
	@10102
	M=D+M

	@10037
	D=M
	M=0
	@12149
	M=D+M

	@12215
	D=M
	M=0
	@10103
	M=D+M

	@10038
	D=M
	M=0
	@12150
	M=D+M

	@12216
	D=M
	M=0
	@10104
	M=D+M

	@10039
	D=M
	M=0
	@12151
	M=D+M

	@12217
	D=M
	M=0
	@10105
	M=D+M

	@10040
	D=M
	M=0
	@12152
	M=D+M

	@12218
	D=M
	M=0
	@10106
	M=D+M

	@10041
	D=M
	M=0
	@12153
	M=D+M

	@12219
	D=M
	M=0
	@10107
	M=D+M

	@10042
	D=M
	M=0
	@12154
	M=D+M

	@12220
	D=M
	M=0
	@10108
	M=D+M

	@10043
	D=M
	M=0
	@12155
	M=D+M

	@12221
	D=M
	M=0
	@10109
	M=D+M

	@10044
	D=M
	M=0
	@12156
	M=D+M

	@12222
	D=M
	M=0
	@10110
	M=D+M

	@10045
	D=M
	M=0
	@12157
	M=D+M

	@12223
	D=M
	M=0
	@10111
	M=D+M

	@10046
	D=M
	M=0
	@12158
	M=D+M

	@12224
	D=M
	M=0
	@10112
	M=D+M

	@10047
	D=M
	M=0
	@12159
	M=D+M

	@12225
	D=M
	M=0
	@10113
	M=D+M

	@10048
	D=M
	M=0
	@12160
	M=D+M

	@12226
	D=M
	M=0
	@10114
	M=D+M

	@10049
	D=M
	M=0
	@12161
	M=D+M

	@12227
	D=M
	M=0
	@10115
	M=D+M

	@10050
	D=M
	M=0
	@12162
	M=D+M

	@12228
	D=M
	M=0
	@10116
	M=D+M

	@10051
	D=M
	M=0
	@12163
	M=D+M

	@12229
	D=M
	M=0
	@10117
	M=D+M

	@10052
	D=M
	M=0
	@12164
	M=D+M

	@12230
	D=M
	M=0
	@10118
	M=D+M

	@10053
	D=M
	M=0
	@12165
	M=D+M

	@12231
	D=M
	M=0
	@10119
	M=D+M

	@10054
	D=M
	M=0
	@12166
	M=D+M

	@12232
	D=M
	M=0
	@10120
	M=D+M

	@10055
	D=M
	M=0
	@12167
	M=D+M

	@12233
	D=M
	M=0
	@10121
	M=D+M

	@10056
	D=M
	M=0
	@12168
	M=D+M

	@12234
	D=M
	M=0
	@10122
	M=D+M

	@10057
	D=M
	M=0
	@12169
	M=D+M

	@12235
	D=M
	M=0
	@10123
	M=D+M

	@10058
	D=M
	M=0
	@12170
	M=D+M

	@12236
	D=M
	M=0
	@10124
	M=D+M

	@10059
	D=M
	M=0
	@12171
	M=D+M

	@12237
	D=M
	M=0
	@10125
	M=D+M

	@10060
	D=M
	M=0
	@12172
	M=D+M

	@12238
	D=M
	M=0
	@10126
	M=D+M

	@10061
	D=M
	M=0
	@12173
	M=D+M

	@12239
	D=M
	M=0
	@10127
	M=D+M

	@10062
	D=M
	M=0
	@12174
	M=D+M

	@12240
	D=M
	M=0
	@10128
	M=D+M

	@10063
	D=M
	M=0
	@12175
	M=D+M

	@12241
	D=M
	M=0
	@10129
	M=D+M

	@10064
	D=M
	M=0
	@12176
	M=D+M

	@12242
	D=M
	M=0
	@10130
	M=D+M

	//Theleftandrightcolumns

	@10066
	D=M
	M=0
	@10130
	M=D+M

	@10131
	D=M
	M=0
	@10067
	M=D+M

	@10132
	D=M
	M=0
	@10196
	M=D+M

	@10197
	D=M
	M=0
	@10133
	M=D+M

	@10198
	D=M
	M=0
	@10262
	M=D+M

	@10263
	D=M
	M=0
	@10199
	M=D+M

	@10264
	D=M
	M=0
	@10328
	M=D+M

	@10329
	D=M
	M=0
	@10265
	M=D+M

	@10330
	D=M
	M=0
	@10394
	M=D+M

	@10395
	D=M
	M=0
	@10331
	M=D+M

	@10396
	D=M
	M=0
	@10460
	M=D+M

	@10461
	D=M
	M=0
	@10397
	M=D+M

	@10462
	D=M
	M=0
	@10526
	M=D+M

	@10527
	D=M
	M=0
	@10463
	M=D+M

	@10528
	D=M
	M=0
	@10592
	M=D+M

	@10593
	D=M
	M=0
	@10529
	M=D+M

	@10594
	D=M
	M=0
	@10658
	M=D+M

	@10659
	D=M
	M=0
	@10595
	M=D+M

	@10660
	D=M
	M=0
	@10724
	M=D+M

	@10725
	D=M
	M=0
	@10661
	M=D+M

	@10726
	D=M
	M=0
	@10790
	M=D+M

	@10791
	D=M
	M=0
	@10727
	M=D+M

	@10792
	D=M
	M=0
	@10856
	M=D+M

	@10857
	D=M
	M=0
	@10793
	M=D+M

	@10858
	D=M
	M=0
	@10922
	M=D+M

	@10923
	D=M
	M=0
	@10859
	M=D+M

	@10924
	D=M
	M=0
	@10988
	M=D+M

	@10989
	D=M
	M=0
	@10925
	M=D+M

	@10990
	D=M
	M=0
	@11054
	M=D+M

	@11055
	D=M
	M=0
	@10991
	M=D+M

	@11056
	D=M
	M=0
	@11120
	M=D+M

	@11121
	D=M
	M=0
	@11057
	M=D+M

	@11122
	D=M
	M=0
	@11186
	M=D+M

	@11187
	D=M
	M=0
	@11123
	M=D+M

	@11188
	D=M
	M=0
	@11252
	M=D+M

	@11253
	D=M
	M=0
	@11189
	M=D+M

	@11254
	D=M
	M=0
	@11318
	M=D+M

	@11319
	D=M
	M=0
	@11255
	M=D+M

	@11320
	D=M
	M=0
	@11384
	M=D+M

	@11385
	D=M
	M=0
	@11321
	M=D+M

	@11386
	D=M
	M=0
	@11450
	M=D+M

	@11451
	D=M
	M=0
	@11387
	M=D+M

	@11452
	D=M
	M=0
	@11516
	M=D+M

	@11517
	D=M
	M=0
	@11453
	M=D+M

	@11518
	D=M
	M=0
	@11582
	M=D+M

	@11583
	D=M
	M=0
	@11519
	M=D+M

	@11584
	D=M
	M=0
	@11648
	M=D+M

	@11649
	D=M
	M=0
	@11585
	M=D+M

	@11650
	D=M
	M=0
	@11714
	M=D+M

	@11715
	D=M
	M=0
	@11651
	M=D+M

	@11716
	D=M
	M=0
	@11780
	M=D+M

	@11781
	D=M
	M=0
	@11717
	M=D+M

	@11782
	D=M
	M=0
	@11846
	M=D+M

	@11847
	D=M
	M=0
	@11783
	M=D+M

	@11848
	D=M
	M=0
	@11912
	M=D+M

	@11913
	D=M
	M=0
	@11849
	M=D+M

	@11914
	D=M
	M=0
	@11978
	M=D+M

	@11979
	D=M
	M=0
	@11915
	M=D+M

	@11980
	D=M
	M=0
	@12044
	M=D+M

	@12045
	D=M
	M=0
	@11981
	M=D+M

	@12046
	D=M
	M=0
	@12110
	M=D+M

	@12111
	D=M
	M=0
	@12047
	M=D+M

	//Phase3:usethepreviousgenerationstateandthecountofneighborstoupdate
	//thecells.

	@10067			//G.cell=10067(firstpossibleactivecell)
	D=A
	@G.cell
	M=D

(G.3.Top)			//repeat...until++G.cell=12177(guardcellafterlastlivecell)

	@G.cell		//D=[G.cell]
	A=M
	D=M

	@G.3.Live		//ifD<0it'salivecell
	D;JLT

(G.3.Dead)

	@G.3.Next		//ifD==0break(efficiencyhack;costs2instructions,saves8ifdead
	D;JEQ		//cellhasnoneighbors.Awinifthisisthecase>25%ofthetime)

	@9980			//D=DeadTable[D]
	A=D+A
	D=M

	@G.3.Set		//Jumpdowntosetter
	0;JMP

(G.3.Live)

	@15			//D=LiveTable[D&1111](weneedtomaskoffthesignbit)
	D=D&A
	@9970
	A=D+A
	D=M

(G.3.Set)

	@G.cell		//[G.cell]=D
	A=M
	M=D

(G.3.Next)

	@G.cell		//D=++G.cell
	MD=M+1

	@12177			//ifG.cell<12177loop
	D=D-A
	@G.3.Top
	D;JLT

	//JumpdirectlytoPaint_Board()withoutpushingreturn
	//addressonstack.Itwillreturntomycaller!

	@Paint_Board
	0;JMP

//Load_Board(LB)function.ExpectsaddressofboarddataloadercodeinD.Clearstheboard,unpacksthedata,
//andsetsupthecells.

(Load_Board)
(LB)

	@20010			//BreakpointonA=20010tostophere(protip!)

	@LB.board		//LB.board=D(addressofboardbitmaploadersubroutine)
	M=D

	//Runtheboarddataloadercode(inrom)tocopyitselfintoramat9800...

	@LB.Ret1		//D=Clearboardreturnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@LB.board		//Indirectlycalltheboardloader!
	A=M
	0;JMP

	@20011			//Breakpoint

(LB.Ret1)

	//CleartheboardbycallingClear_Board(CB)function

	@LB.Ret2		//D=Clearboardreturnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Clear_Board	//Clear_Board()
	0;JMP

(LB.Ret2)

	@20011			//Breakpoint

	@9800			//LB.board=9800,addressofloadedboarddata
	D=A
	@LB.board
	M=D

	@10067			//LB.cell=10067
	D=A			//Boardstartsat10000,firstrealcellisat1,1=+66+1
	@LB.cell
	M=D

	@32			//LB.row=32(numberofrowsweneedtoread)
	D=A
	@LB.row
	M=D

(LB.forRow)		//repeatLoad_Board_Row()while(--LB.row>0)

	@20012

	@LB.forRow.Ret	//D=Load_Board_Rowreturnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Load_Board_Row //Load_Board_Row()
	0;JMP

(LB.forRow.Ret)

	@LB.row		//LB.row,D=LB.row-1
	MD=M-1
	
	@LB.forRow		//LoopifLB.row>0
	D;JGT

	//PainttheboardbyjumpingdirectlytoPaint_Board()
	//Itwillreturntomycaller.

	@Paint_Board
	0;JMP

//Load_Board_Rowfunction.Loadasinglerowfrom4wordsstartingatLB.boardinto
//64cellsstartingatLB.cell,thenmoveLB.celltothefirstcellofthenextrow
//andLB.boardtothefirstwordofthenextrowofboardinformation.

(Load_Board_Row)
(LBR)

	@20020				//Breakpoint

	@4					//LBR.word=4
	D=A
	@LBR.word
	M=D

(LBR.forWord)			//repeatLoad_Board_Wordwhile(--LBR.word>0)

	@LBR.forWord.Ret	//D=Load_Board_Rowreturnaddress
	D=A

	@SP				//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Load_Board_Word	//Load_Board_Word()
	0;JMP

(LBR.forWord.Ret)

	@LBR.word			//LBR.word,D=LBR.word-1
	MD=M-1
	
	@LBR.forWord		//LoopifLB.row>0
	D;JGT

	@20020

	@LB.cell			//LB.cell=LB.cell+2
	M=M+1
	M=M+1

	//returntocaller

	@SP			//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//Load_Board_Word(D):Usethe16bitsof[LB.board]tosetthenext
//Dcellsstartingat[LB.cell];incrementLB.boardandLB.cell.

(Load_Board_Word)
(LBW)

	@20030				//Breakpoint

	@16				//LBW.count=16(#ofbitstotransfer)
	D=A
	@LBW.count
	M=D

	@LB.board			//@LBW.bits=[LB.board]
	A=M
	D=M
	@LBW.bits
	M=D

(LBW.forCell)			//repeat[LB.cell++]=TopbitofLBW.bitswhile(--LBW.count>0)

	@LBW.bits			//D=LBW.bits
	D=M

	M=D+M			//LBW.bits=LBW.bits<<1

	@32767				//D=D&1000000000000000
	D=!D			//Wehavetobetrickytodothisbecausewecan't
	D=D|A			//loada16bitconstant.Theendresultisthatthe
	D=!D			//signbitispreservedandeverythingelseis0!

	@LB.cell			//[LB.cell]=D
	A=M
	M=D

	D=A+1			//LB.cell++
	@LB.cell
	M=D

	@LBW.count			//LBW.Count,D=LBW.Count.i-1
	MD=M-1
	
	@LBW.forCell		//LoopifCB.i>0
	D;JGT

(LBW.incBoard)

	@LB.board			//LB.board++
	M=M+1

	//returntocaller

	@SP			//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//Clear_Board(CB)function.Clearsallthecellsincludingtheborderguardcells
//Shouldrewritetonotneedthecountvariable.Lazy.

(Clear_Board)
(CB)

	@20040			//Breakpoint

	@2244			//Thereare34*66elementsintheboard=2244
	D=A			//CB.iistheloopcounter
	@CB.i
	M=D

	@10000			//CB.a=Boardlocation(can'tassignablockofmemory,alas)
	D=A
	@CB.a
	M=D
	
(CB.Top)			//repeatMem[CB.a++]=0while(--CB.i>0)

	@CB.a			//[CB.a]=0
	A=M
	M=0
	
	D=A+1		//D=CB.a+1
	@CB.a			//CB.a=D
	M=D

	@CB.i			//CB.i,D=CB.i-1
	MD=M-1
	
	@CB.Top		//LoopifCB.i>0
	D;JGT

	//returntocaller

	@SP			//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//Paint_Board(PB)function;paintsthecurrentboardontothescreen

(Paint_Board)
(PB)

	@20500

	@SCREEN		//PB.board=Addressofscreen
	D=A
	@PB.board
	M=D

	@10067			//PB.cell=10067
	D=A			//Boardstartsat10000,firstrealcellisat1,1=+66+1
	@PB.cell
	M=D

	@32			//PB.row=32(numberofrowsweneedtopaint)
	D=A
	@PB.row
	M=D

(PB.forRow)		//repeatPaint_Board_Row()while(--PB.row>0)

	@20012

	@PB.forRow.Ret	//D=Paint_Board_Rowreturnaddress
	D=A

	@SP			//[SP--]=D(PUSH)
	A=M
	M=D
	@SP
	M=M-1

	@Paint_Board_Row //Paint_Board_Row()
	0;JMP

(PB.forRow.Ret)

	@PB.row		//PB.row,D=PB.row-1
	MD=M-1
	
	@PB.forRow		//LoopifPB.row>0
	D;JGT

	//returntocaller

	@SP			//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//Paint_Board_Row():Paintasinglerow(64cells)ontothescreen.Weusean8x8matrixofpixels
//foreachcell,sotwocellsfitintoeachwordofpixels(16pixels/word),andeachrowis
//replicated8times.Onexit,PB.boardpointstothefirstwordofpixelsforthenextrowof
//cells,andPB.cellpointstothefirstcellofthenextrow.

(Paint_Board_Row)
(PBR)

	@20600

	@32				//PBR.pair=32(numberofpairsofcellsweneedtopaint)
	D=A
	@PBR.pair
	M=D

(PBR.forPair)			//repeatPaint_Board_Pair()while(--PBR.pair>0)

//Paint_Board_Pair():paintapairofcells[PB.cell],[PB.cell+1]ontothescreenatword
//[PB.board].Repeatfor8screenrows,thenupdatePB.cellandPB.boardforthenext
//iteration.
//
//Thiscodeisexecutedsomuchthatallsortsofoptimizationsarewarranted,including
//insertingithereasaninlinedfunctioncalltoavoidthecall-returnoverhead.This
//sucksabitforreadability.

(Paint_Board_Pair)
(PBP)

	//Convertcellsintopixels.Thereare4possiblecellcombinations(00,01,10,11)
	//andthus4possiblepixelvalues.Notehoweverthattwoofthemare0000...0000
	//and1111...1111,whicharepredefinedconstantsavailabletotheALU.Thismeans
	//forthesetwocases,wedon'thavetoloadthepixelvaluebeforestoringin
	//thescreenbuffer.

	@PB.cell			//D=[PB.cell](willbenegativeifcellisalive;0ifcellisdead
	A=M
	D=M

	@PBP.0X			//Skipiftoppixelisempty
	D;JEQ

(PBP.1X)				//Leftpixelisset.WhataboutRightpixel?

	@PB.cell			//D=[++PB.cell](thesecondcellinthepair)
	AM=M+1
	D=M

	@PBP.10			//Rightpixelisempty
	D;JEQ

(PBP.11)

	//Nowwesetbothpixelsin8wordsofthescreenbuffer

	@32				//D=Screenbufferrowwidth
	D=A

	@PB.board			//A=PB.board(locationoffirstscreenwordtobash)
	A=M

	M=-1				//[A]=-1--row1

	A=D+A			//A=A+32
	M=-1				//Row2
	
	A=D+A			//A=A+32
	M=-1				//Row3
	
	A=D+A			//A=A+32
	M=-1				//Row4
	
	A=D+A			//A=A+32
	M=-1				//Row5
	
	A=D+A			//A=A+32
	M=-1				//Row6
	
	A=D+A			//A=A+32
	M=-1				//Row7
	
	A=D+A			//A=A+32
	M=-1				//Row8
	
	@PB.board			//PB.board=PB.board+1
	M=M+1

	@PB.cell			//PB.cell=PB.cell+1
	M=M+1

	//returntocaller

	@PBR.forPair.Ret	//directjumpsincethisisaninlinefunctioncall
	0;JMP

(PBP.0X)				//Leftpixelisclear.WhataboutRightpixel?

	@PB.cell			//D=[++PB.cell](thesecondcellinthepair)
	AM=M+1
	D=M

	@PBP.01			//Rightpixelis*not*empty
	D;JNE

(PBP.00)

	//Nowweclearbothpixelsin8wordsofthescreenbuffer

	@32				//D=Screenbufferrowwidth
	D=A

	@PB.board			//A=PB.board(locationoffirstscreenwordtobash)
	A=M

	M=0				//[A]=0--row1

	A=D+A			//A=A+32
	M=0				//Row2
	
	A=D+A			//A=A+32
	M=0				//Row3
	
	A=D+A			//A=A+32
	M=0				//Row4
	
	A=D+A			//A=A+32
	M=0				//Row5
	
	A=D+A			//A=A+32
	M=0				//Row6
	
	A=D+A			//A=A+32
	M=0				//Row7
	
	A=D+A			//A=A+32
	M=0				//Row8
	
	@PB.board			//PB.board=PB.board+1
	M=M+1

	@PB.cell			//PB.cell=PB.cell+1
	M=M+1

	//returntocaller

	@PBR.forPair.Ret	//directjumpsincethisisaninlinefunctioncall
	0;JMP

(PBP.10)

	@255				//D=00FF(remember,leastsignificantbitsinscreenmemoryaretheleftmostones)
	D=A

	@PBP.Paint
	0;JMP

(PBP.01)

	@255				//D=!00FF
	D=!A

(PBP.Paint)

	//PaintthepixelsinDinto8successiverowsofthescreen.Loopisunrolledfor
	//efficiency.

	@PBP.pixels		//Saveourpixels
	M=D

	@PB.board			//A=PB.board(locationoffirstscreenwordtobash)
	A=M

	M=D				//[PB.board]=PBP.pixels(stillinD)--row1

	D=A				//PB.board=PB.board+32
	@32
	D=D+A
	@PB.board
	M=D

	@PBP.pixels		//[PB.board]=PBP.pixels--row2
	D=M
	@PB.board
	A=M
	M=D


	D=A				//PB.board=PB.board+32
	@32
	D=D+A
	@PB.board
	M=D

	@PBP.pixels		//[PB.board]=PBP.pixels--row3
	D=M
	@PB.board
	A=M
	M=D

	D=A				//PB.board=PB.board+32
	@32
	D=D+A
	@PB.board
	M=D

	@PBP.pixels		//[PB.board]=PBP.pixels--row4
	D=M
	@PB.board
	A=M
	M=D

	D=A				//PB.board=PB.board+32
	@32
	D=D+A
	@PB.board
	M=D

	@PBP.pixels		//[PB.board]=PBP.pixels--row5
	D=M
	@PB.board
	A=M
	M=D

	D=A				//PB.board=PB.board+32
	@32
	D=D+A
	@PB.board
	M=D

	@PBP.pixels		//[PB.board]=PBP.pixels--row6
	D=M
	@PB.board
	A=M
	M=D

	D=A				//PB.board=PB.board+32
	@32
	D=D+A
	@PB.board
	M=D

	@PBP.pixels		//[PB.board]=PBP.pixels--row7
	D=M
	@PB.board
	A=M
	M=D

	D=A				//PB.board=PB.board+32
	@32
	D=D+A
	@PB.board
	M=D

	@PBP.pixels		//[PB.board]=PBP.pixels--row8
	D=M
	@PB.board
	A=M
	M=D

	//PB.boardnowcontainsanaddressinthe8throw.Weneedtogobackto
	//thefirstrow,thenmoveforwardtothenextword.Sincewemoved7x32
	//words,wesimplysubtract(7*32)-1.Similarly,weneedtoincrement
	//PB.celltomovetothefirstcellofthenextpair.

(PBP.NextPair)

	@223				//PB.board=PB.board-223
	D=A
	@PB.board
	M=M-D

	@PB.cell
	M=M+1

	//returntocaller(fallthrough)

	//endofinlinefunctioncall

(PBR.forPair.Ret)

	@PBR.pair			//PB.pair,D=PB.pair-1
	MD=M-1
	
	@PBR.forPair		//LoopifPBR.pair>0
	D;JGT

	//UpdatePB.cellandPB.boardsotheyarecorrectforthenextiteration

	@PB.cell			//PB.cell=PB.cell+2(skipsbordercells)
	M=M+1
	M=M+1

	@224				//PB.board=PB.board+32*7(skips7pixelrows)
	D=A
	@PB.board
	M=D+M

	//returntocaller

	@SP				//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//InitializeRAMdatastructures.Wehavetwolookuptablesthatcontainthenewstateofacell,one
//fordeadcells,andoneforlivingcells.Sincethereareupto8neighbors,theindexcanrangefrom
//0to8,soweneed9elementspertable.

(Initialize)
(INI)

	@9970		//LiveTable:Celllivesifithas2or3neighbors,diesotherwise
	M=0		//DeadTable:Cellisbornifithas3neighbors,staysdeadotherwise
	@9971		//Initializeallthedeadcellsfirst
	M=0
	@9974
	M=0
	@9975
	M=0
	@9976
	M=0
	@9977
	M=0
	@9978
	M=0

	@9980
	M=0
	@9981
	M=0
	@9982
	M=0
	@9984
	M=0
	@9985
	M=0
	@9986
	M=0
	@9987
	M=0
	@9988
	M=0

	@16384		//A=0100...0000
	D=A
	D=D+A	//D=1000...0000(livecellvalue)

	@9972
	M=D
	@9973
	M=D
	@9983
	M=D

	//Divideby2table

	@0
	D=A
	@9700
	M=D
	@9701
	M=D

	@1
	D=A
	@9702
	M=D
	@9703
	M=D

	@2
	D=A
	@9704
	M=D
	@9705
	M=D

	@3
	D=A
	@9706
	M=D
	@9707
	M=D

	@4
	D=A
	@9708
	M=D
	@9709
	M=D

	@5
	D=A
	@9710
	M=D
	@9711
	M=D

	@6
	D=A
	@9712
	M=D
	@9713
	M=D

	@7
	D=A
	@9714
	M=D
	@9715
	M=D

	@8
	D=A
	@9716
	M=D
	@9717
	M=D

	@9
	D=A
	@9718
	M=D
	@9719
	M=D

	@10
	D=A
	@9720
	M=D
	@9721
	M=D

	@11
	D=A
	@9722
	M=D
	@9723
	M=D

	@12
	D=A
	@9724
	M=D
	@9725
	M=D

	@13
	D=A
	@9726
	M=D
	@9727
	M=D

	@14
	D=A
	@9728
	M=D
	@9729
	M=D

	@15
	D=A
	@9730
	M=D
	@9731
	M=D

	@16
	D=A
	@9732
	M=D
	@9733
	M=D

	@17
	D=A
	@9734
	M=D
	@9735
	M=D

	@18
	D=A
	@9736
	M=D
	@9737
	M=D

	@19
	D=A
	@9738
	M=D
	@9739
	M=D

	@20
	D=A
	@9740
	M=D
	@9741
	M=D

	@21
	D=A
	@9742
	M=D
	@9743
	M=D

	@22
	D=A
	@9744
	M=D
	@9745
	M=D

	@23
	D=A
	@9746
	M=D
	@9747
	M=D

	@24
	D=A
	@9748
	M=D
	@9749
	M=D

	@25
	D=A
	@9750
	M=D
	@9751
	M=D

	@26
	D=A
	@9752
	M=D
	@9753
	M=D

	@27
	D=A
	@9754
	M=D
	@9755
	M=D

	@28
	D=A
	@9756
	M=D
	@9757
	M=D

	@29
	D=A
	@9758
	M=D
	@9759
	M=D

	@30
	D=A
	@9760
	M=D
	@9761
	M=D

	@31
	D=A
	@9762
	M=D
	@9763
	M=D

	//returntocaller

	@SP				//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//MultiplyMult.abyMult.b,returninMult.result
//Mult.aandMult.barenotmodified.NoR-variablesareused

(Mult)

	@Mult.result		//Initializeproduct(R2)to0
	M=0

	@Mult.mask			//InitializeMult.maskto1111...1110
	M=-1				//whichis-2
	M=M-1

	@Mult.a			//CheckifMult.a>=Mult.b
	D=M				//Ifso,Mult.bisMultiplicand
	@Mult.b			//Ifnot,Mult.aisMultiplicand
	D=D-M			//Thisminimizesthenumberoftimes
	@Mult.R0_GE_R1		//throughthemainloop.
	D;JGE

	@Mult.b			//InitializeMultiplicandtoMult.b
	D=M
	@Mult.c
	M=D

	@Mult.a				//InitializeMultipliertoMult.a
	D=M
	@Mult.p
	M=D

	@Mult.loop			//Jumptotopofloop
	0;JMP

(Mult.R0_GE_R1)		//Mult.a>=Mult.b,soMult.bisMult.p

	@Mult.a			//InitializeMultiplicandtoMult.a
	D=M
	@Mult.c
	M=D

	@Mult.b				//InitializeMultipliertoMult.b
	D=M
	@Mult.p
	M=D

//Efficiencynote:WecouldplaceacheckheretoseeifMult.pis0andexitimmediately.Thiscosts
//2instructionsoneverymultiply.OmittingthischeckmeansthatifMult.pis0,we'llgothroughthe
//looponce(20instructions),sothisisonlyawinifweexpectMult.ptobe0morethan10%ofthe
//time.

(Mult.loop)			//D=Mult.pandnon-zeroatthispoint(unlessitstartsaszero).

	@Mult.p.o			//SaveacopyofMult.pasitcurrentlyis
	M=D

	@Mult.mask			//Mult.p=Mult.p&Mult.mask.Becausemaskisanegativemask,onlythebit
	D=D&M			//wecurrentlycareaboutissetto0ifitis1.Wesavethe
	@Mult.p			//*changed*versionbackintoMult.p
	M=D

	@Mult.p.o			//ifMult.p==Mult.p.o,nothingtodoonthisround
	D=D-M
	@Mult.next
	D;JEQ

	@Mult.c			//Mult.result=Mult.result+Mult.c
	D=M
	@Mult.result
	M=D+M

(Mult.next)

	@Mult.c			//Mult.c=Mult.c*2(ShiftLeft1bit)
	D=M
	M=D+M

	@Mult.mask			//Mult.mask=Mult.mask*2(Shiftleft1bit)
	D=M
	M=D+M

	@Mult.p			//LoadupMult.pagain
	D=M
	@Mult.loop			//andloopifnon-zero
	D;JNE

	//returntocaller

	@SP				//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//Logoboarddatastorage.Boardsare64x32,whichwouldbe4wordperrow,butwecan'tstore16bits
//perwordsinceAinstructionsonlyload15bits.Soeachrowintheboardisstoredin5words,
//15-15-15-15-4,usingthemostsignificantbitsfirst(otherthanthesignbit).Wecanthusrotate
//thebitsintothesignbittotestthem.

//Toaddanotherlevelofhorriblenesstoallofthis,wecan'tdirectlyaccessthedataintheROM,
//soweneedtostructureitasaprogramthatcopiestheboardsintoafixedlocationintheRAM!
//Seetheboardmaker.pyscriptforcodethatdoesthis.

(Logo.Board)

//[****************************************************************]
//[**]
//[**********************************]
//[******************************]
//[*************************************]
//[******************************]
//[*********************************]
//[**]
//[***********************************]
//[*************************]
//[*******************************]
//[**********************]
//[****************************]
//[**]
//[**************************************]
//[**************************************]
//[**************************************]
//[******************]
//[**************************]
//[**************************]
//[******************]
//[**************************************]
//[**************************************]
//[**************************************]
//[**]
//[*********]
//[*******]
//[******************************]
//[***************************]
//[************************]
//[**]
//[****************************************************************]

//[****************************************************************](Row1)

	@09800		//[****************]65535
	M=-1
	@09801		//[****************]65535
	M=-1
	@09802		//[****************]65535
	M=-1
	@09803		//[****************]65535
	M=-1

//[**](Row2)

	D=-1		//[*]32768
	@32767
	D=D-A
	@09804
	M=D
	@09805		//[]0
	M=0
	@09806		//[]0
	M=0
	@00001		//[*]1
	D=A
	@09807
	M=D

//[**********************************](Row3)

	D=-1		//[**********]40479
	@25056
	D=D-A
	@09808
	M=D
	@06552		//[******]6552
	D=A
	@09809
	M=D
	D=-1		//[*********]51148
	@14387
	D=D-A
	@09810
	M=D
	@25849		//[*********]25849
	D=A
	@09811
	M=D

//[******************************](Row4)

	D=-1		//[********]45873
	@19662
	D=D-A
	@09812
	M=D
	D=-1		//[********]40344
	@25191
	D=D-A
	@09813
	M=D
	D=-1		//[********]52332
	@13203
	D=D-A
	@09814
	M=D
	@27009		//[******]27009
	D=A
	@09815
	M=D

//[*************************************](Row5)

	D=-1		//[******]45105
	@20430
	D=D-A
	@09816
	M=D
	D=-1		//[**********]40858
	@24677
	D=D-A
	@09817
	M=D
	D=-1		//[************]53223
	@12312
	D=D-A
	@09818
	M=D
	D=-1		//[*********]57593
	@07942
	D=D-A
	@09819
	M=D

//[******************************](Row6)

	D=-1		//[********]45873
	@19662
	D=D-A
	@09820
	M=D
	D=-1		//[***********]39839
	@25696
	D=D-A
	@09821
	M=D
	D=-1		//[******]52320
	@13215
	D=D-A
	@09822
	M=D
	@24589		//[*****]24589
	D=A
	@09823
	M=D

//[*********************************](Row7)

	D=-1		//[**********]40479
	@25056
	D=D-A
	@09824
	M=D
	@06541		//[*******]6541
	D=A
	@09825
	M=D
	D=-1		//[********]35943
	@29592
	D=D-A
	@09826
	M=D
	D=-1		//[********]49401
	@16134
	D=D-A
	@09827
	M=D

//[**](Row8)

	D=-1		//[*]32768
	@32767
	D=D-A
	@09828
	M=D
	@09829		//[]0
	M=0
	@09830		//[]0
	M=0
	@00001		//[*]1
	D=A
	@09831
	M=D

//[***********************************](Row9)

	D=-1		//[**********]40479
	@25056
	D=D-A
	@09832
	M=D
	@07631		//[**********]7631
	D=A
	@09833
	M=D
	D=-1		//[***]49153
	@16382
	D=D-A
	@09834
	M=D
	D=-1		//[************]61949
	@03586
	D=D-A
	@09835
	M=D

//[*************************](Row10)

	D=-1		//[********]45873
	@19662
	D=D-A
	@09836
	M=D
	D=-1		//[**********]40908
	@24627
	D=D-A
	@09837
	M=D
	@00003		//[**]3
	D=A
	@09838
	M=D
	@06529		//[*****]6529
	D=A
	@09839
	M=D

//[*******************************](Row11)

	D=-1		//[*********]45119
	@20416
	D=D-A
	@09840
	M=D
	D=-1		//[**********]39631
	@25904
	D=D-A
	@09841
	M=D
	D=-1		//[****]49155
	@16380
	D=D-A
	@09842
	M=D
	@06641		//[********]6641
	D=A
	@09843
	M=D

//[**********************](Row12)

	D=-1		//[********]45873
	@19662
	D=D-A
	@09844
	M=D
	D=-1		//[*******]39116
	@26419
	D=D-A
	@09845
	M=D
	@00003		//[**]3
	D=A
	@09846
	M=D
	@06529		//[*****]6529
	D=A
	@09847
	M=D

//[****************************](Row13)

	D=-1		//[*********]40753
	@24782
	D=D-A
	@09848
	M=D
	D=-1		//[*********]39119
	@26416
	D=D-A
	@09849
	M=D
	D=-1		//[***]49153
	@16382
	D=D-A
	@09850
	M=D
	D=-1		//[*******]61825
	@03710
	D=D-A
	@09851
	M=D

//[**](Row14)

	D=-1		//[*]32768
	@32767
	D=D-A
	@09852
	M=D
	@09853		//[]0
	M=0
	@09854		//[]0
	M=0
	@00001		//[*]1
	D=A
	@09855
	M=D

//[**************************************](Row15)

	D=-1		//[*****]36608
	@28927
	D=D-A
	@09856
	M=D
	@04080		//[********]4080
	D=A
	@09857
	M=D
	D=-1		//[************]65520
	@00015
	D=D-A
	@09858
	M=D
	D=-1		//[*************]65521
	@00014
	D=D-A
	@09859
	M=D

//[**************************************](Row16)

	D=-1		//[*****]36608
	@28927
	D=D-A
	@09860
	M=D
	@04080		//[********]4080
	D=A
	@09861
	M=D
	D=-1		//[************]65520
	@00015
	D=D-A
	@09862
	M=D
	D=-1		//[*************]65521
	@00014
	D=D-A
	@09863
	M=D

//[**************************************](Row17)

	D=-1		//[*****]36608
	@28927
	D=D-A
	@09864
	M=D
	@04080		//[********]4080
	D=A
	@09865
	M=D
	D=-1		//[************]65520
	@00015
	D=D-A
	@09866
	M=D
	D=-1		//[*************]65521
	@00014
	D=D-A
	@09867
	M=D

//[******************](Row18)

	D=-1		//[*****]36608
	@28927
	D=D-A
	@09868
	M=D
	@00960		//[****]960
	D=A
	@09869
	M=D
	D=-1		//[****]61440
	@04095
	D=D-A
	@09870
	M=D
	D=-1		//[*****]61441
	@04094
	D=D-A
	@09871
	M=D

//[**************************](Row19)

	D=-1		//[*****]36608
	@28927
	D=D-A
	@09872
	M=D
	@00960		//[****]960
	D=A
	@09873
	M=D
	D=-1		//[********]65280
	@00255
	D=D-A
	@09874
	M=D
	D=-1		//[*********]65281
	@00254
	D=D-A
	@09875
	M=D

//[**************************](Row20)

	D=-1		//[*****]36608
	@28927
	D=D-A
	@09876
	M=D
	@00960		//[****]960
	D=A
	@09877
	M=D
	D=-1		//[********]65280
	@00255
	D=D-A
	@09878
	M=D
	D=-1		//[*********]65281
	@00254
	D=D-A
	@09879
	M=D

//[******************](Row21)

	D=-1		//[*****]36608
	@28927
	D=D-A
	@09880
	M=D
	@00960		//[****]960
	D=A
	@09881
	M=D
	D=-1		//[****]61440
	@04095
	D=D-A
	@09882
	M=D
	D=-1		//[*****]61441
	@04094
	D=D-A
	@09883
	M=D

//[**************************************](Row22)

	D=-1		//[*************]36863
	@28672
	D=D-A
	@09884
	M=D
	@04080		//[********]4080
	D=A
	@09885
	M=D
	D=-1		//[****]61440
	@04095
	D=D-A
	@09886
	M=D
	D=-1		//[*************]65521
	@00014
	D=D-A
	@09887
	M=D

//[**************************************](Row23)

	D=-1		//[*************]36863
	@28672
	D=D-A
	@09888
	M=D
	@04080		//[********]4080
	D=A
	@09889
	M=D
	D=-1		//[****]61440
	@04095
	D=D-A
	@09890
	M=D
	D=-1		//[*************]65521
	@00014
	D=D-A
	@09891
	M=D

//[**************************************](Row24)

	D=-1		//[*************]36863
	@28672
	D=D-A
	@09892
	M=D
	@04080		//[********]4080
	D=A
	@09893
	M=D
	D=-1		//[****]61440
	@04095
	D=D-A
	@09894
	M=D
	D=-1		//[*************]65521
	@00014
	D=D-A
	@09895
	M=D

//[**](Row25)

	D=-1		//[*]32768
	@32767
	D=D-A
	@09896
	M=D
	@09897		//[]0
	M=0
	@09898		//[]0
	M=0
	@00001		//[*]1
	D=A
	@09899
	M=D

//[*********](Row26)

	D=-1		//[*****]40448
	@25087
	D=D-A
	@09900
	M=D
	@00032		//[*]32
	D=A
	@09901
	M=D
	@00001		//[*]1
	D=A
	@09902
	M=D
	@00005		//[**]5
	D=A
	@09903
	M=D

//[*******](Row27)

	D=-1		//[***]41216
	@24319
	D=D-A
	@09904
	M=D
	@00032		//[*]32
	D=A
	@09905
	M=D
	@00001		//[*]1
	D=A
	@09906
	M=D
	@00005		//[**]5
	D=A
	@09907
	M=D

//[******************************](Row28)

	D=-1		//[*******]44293
	@21242
	D=D-A
	@09908
	M=D
	@07398		//[********]7398
	D=A
	@09909
	M=D
	@17613		//[*******]17613
	D=A
	@09910
	M=D
	@12701		//[********]12701
	D=A
	@09911
	M=D

//[***************************](Row29)

	D=-1		//[********]44810
	@20725
	D=D-A
	@09912
	M=D
	D=-1		//[*******]42281
	@23254
	D=D-A
	@09913
	M=D
	@10641		//[******]10641
	D=A
	@09914
	M=D
	@18981		//[******]18981
	D=A
	@09915
	M=D

//[************************](Row30)

	D=-1		//[***]36872
	@28663
	D=D-A
	@09916
	M=D
	D=-1		//[*********]40166
	@25369
	D=D-A
	@09917
	M=D
	@04305		//[*****]4305
	D=A
	@09918
	M=D
	@12829		//[*******]12829
	D=A
	@09919
	M=D

//[**](Row31)

	D=-1		//[*]32768
	@32767
	D=D-A
	@09920
	M=D
	@09921		//[]0
	M=0
	@09922		//[]0
	M=0
	@00001		//[*]1
	D=A
	@09923
	M=D

//[****************************************************************](Row32)

	@09924		//[****************]65535
	M=-1
	@09925		//[****************]65535
	M=-1
	@09926		//[****************]65535
	M=-1
	@09927		//[****************]65535
	M=-1

//returntocaller

	@SP		//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

(Oscillator.Board)

//[**]
//[*************]
//[*****]
//[********]
//[******]
//[************]
//[************]
//[****]
//[*********]
//[*******]
//[*******]
//[******]
//[**]
//[******]
//[**]
//[]
//[]
//[]
//[**]
//[******]
//[*****]
//[***]
//[]
//[]
//[]
//[***]
//[***]
//[****]
//[**]
//[]
//[]
//[]

//[**](Row1)

	@01536		//[**]1536
	D=A
	@09800
	M=D
	@09801		//[]0
	M=0
	@09802		//[]0
	M=0
	@09803		//[]0
	M=0

//[*************](Row2)

	D=-1		//[*******]58382
	@07153
	D=D-A
	@09804
	M=D
	@03640		//[******]3640
	D=A
	@09805
	M=D
	@09806		//[]0
	M=0
	@09807		//[]0
	M=0

//[*****](Row3)

	@00156		//[****]156
	D=A
	@09808
	M=D
	@09809		//[]0
	M=0
	@09810		//[]0
	M=0
	@16384		//[*]16384
	D=A
	@09811
	M=D

//[********](Row4)

	@00384		//[**]384
	D=A
	@09812
	M=D
	@08514		//[****]8514
	D=A
	@09813
	M=D
	@00001		//[*]1
	D=A
	@09814
	M=D
	@16384		//[*]16384
	D=A
	@09815
	M=D

//[******](Row5)

	@09816		//[]0
	M=0
	@08514		//[****]8514
	D=A
	@09817
	M=D
	@00002		//[*]2
	D=A
	@09818
	M=D
	D=-1		//[*]32768
	@32767
	D=D-A
	@09819
	M=D

//[************](Row6)

	@12288		//[**]12288
	D=A
	@09820
	M=D
	@08514		//[****]8514
	D=A
	@09821
	M=D
	@00196		//[***]196
	D=A
	@09822
	M=D
	D=-1		//[***]32780
	@32755
	D=D-A
	@09823
	M=D

//[************](Row7)

	@09824		//[]0
	M=0
	@03640		//[******]3640
	D=A
	@09825
	M=D
	@00194		//[***]194
	D=A
	@09826
	M=D
	D=-1		//[***]32780
	@32755
	D=D-A
	@09827
	M=D

//[****](Row8)

	D=-1		//[**]34816
	@30719
	D=D-A
	@09828
	M=D
	@09829		//[]0
	M=0
	@00001		//[*]1
	D=A
	@09830
	M=D
	@16384		//[*]16384
	D=A
	@09831
	M=D

//[*********](Row9)

	D=-1		//[**]33792
	@31743
	D=D-A
	@09832
	M=D
	@03640		//[******]3640
	D=A
	@09833
	M=D
	@09834		//[]0
	M=0
	@16384		//[*]16384
	D=A
	@09835
	M=D

//[*******](Row10)

	@10752		//[***]10752
	D=A
	@09836
	M=D
	@08514		//[****]8514
	D=A
	@09837
	M=D
	@09838		//[]0
	M=0
	@09839		//[]0
	M=0

//[*******](Row11)

	@05376		//[***]5376
	D=A
	@09840
	M=D
	@08514		//[****]8514
	D=A
	@09841
	M=D
	@09842		//[]0
	M=0
	@09843		//[]0
	M=0

//[******](Row12)

	@02112		//[**]2112
	D=A
	@09844
	M=D
	@08514		//[****]8514
	D=A
	@09845
	M=D
	@09846		//[]0
	M=0
	@09847		//[]0
	M=0

//[**](Row13)

	@01088		//[**]1088
	D=A
	@09848
	M=D
	@09849		//[]0
	M=0
	@09850		//[]0
	M=0
	@09851		//[]0
	M=0

//[******](Row14)

	@09852		//[]0
	M=0
	@03640		//[******]3640
	D=A
	@09853
	M=D
	@09854		//[]0
	M=0
	@09855		//[]0
	M=0

//[**](Row15)

	@00768		//[**]768
	D=A
	@09856
	M=D
	@09857		//[]0
	M=0
	@09858		//[]0
	M=0
	@09859		//[]0
	M=0

//[](Row16)

	@09860		//[]0
	M=0
	@09861		//[]0
	M=0
	@09862		//[]0
	M=0
	@09863		//[]0
	M=0

//[](Row17)

	@09864		//[]0
	M=0
	@09865		//[]0
	M=0
	@09866		//[]0
	M=0
	@09867		//[]0
	M=0

//[](Row18)

	@09868		//[]0
	M=0
	@09869		//[]0
	M=0
	@09870		//[]0
	M=0
	@09871		//[]0
	M=0

//[**](Row19)

	@09872		//[]0
	M=0
	@09873		//[]0
	M=0
	@24576		//[**]24576
	D=A
	@09874
	M=D
	@09875		//[]0
	M=0

//[******](Row20)

	@09876		//[]0
	M=0
	D=-1		//[**]49152
	@16383
	D=D-A
	@09877
	M=D
	@20504		//[****]20504
	D=A
	@09878
	M=D
	@09879		//[]0
	M=0

//[*****](Row21)

	@09880		//[]0
	M=0
	D=-1		//[**]49152
	@16383
	D=D-A
	@09881
	M=D
	@04120		//[***]4120
	D=A
	@09882
	M=D
	@09883		//[]0
	M=0

//[***](Row22)

	@09884		//[]0
	M=0
	@09885		//[]0
	M=0
	@28672		//[***]28672
	D=A
	@09886
	M=D
	@09887		//[]0
	M=0

//[](Row23)

	@09888		//[]0
	M=0
	@09889		//[]0
	M=0
	@09890		//[]0
	M=0
	@09891		//[]0
	M=0

//[](Row24)

	@09892		//[]0
	M=0
	@09893		//[]0
	M=0
	@09894		//[]0
	M=0
	@09895		//[]0
	M=0

//[](Row25)

	@09896		//[]0
	M=0
	@09897		//[]0
	M=0
	@09898		//[]0
	M=0
	@09899		//[]0
	M=0

//[***](Row26)

	@09900		//[]0
	M=0
	@09901		//[]0
	M=0
	@28672		//[***]28672
	D=A
	@09902
	M=D
	@09903		//[]0
	M=0

//[***](Row27)

	@09904		//[]0
	M=0
	D=-1		//[**]49152
	@16383
	D=D-A
	@09905
	M=D
	@04096		//[*]4096
	D=A
	@09906
	M=D
	@09907		//[]0
	M=0

//[****](Row28)

	@09908		//[]0
	M=0
	D=-1		//[**]49152
	@16383
	D=D-A
	@09909
	M=D
	@20480		//[**]20480
	D=A
	@09910
	M=D
	@09911		//[]0
	M=0

//[**](Row29)

	@09912		//[]0
	M=0
	@09913		//[]0
	M=0
	@24576		//[**]24576
	D=A
	@09914
	M=D
	@09915		//[]0
	M=0

//[](Row30)

	@09916		//[]0
	M=0
	@09917		//[]0
	M=0
	@09918		//[]0
	M=0
	@09919		//[]0
	M=0

//[](Row31)

	@09920		//[]0
	M=0
	@09921		//[]0
	M=0
	@09922		//[]0
	M=0
	@09923		//[]0
	M=0

//[](Row32)

	@09924		//[]0
	M=0
	@09925		//[]0
	M=0
	@09926		//[]0
	M=0
	@09927		//[]0
	M=0

//returntocaller

	@SP		//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//Automaticallygeneratedboardloadingcode

(Gliders.Board)

//[]
//[*]
//[***]
//[**]
//[*****]
//[*****]
//[*]
//[*]
//[*****]
//[**]
//[*]
//[**]
//[******]
//[]
//[****]
//[******]
//[*******]
//[***]
//[***]
//[**]
//[***]
//[**]
//[*****]
//[**************]
//[*]
//[*]
//[*******]
//[******]
//[******]
//[**]
//[]
//[]

//[](Row1)

	@09800		//[]0
	M=0
	@09801		//[]0
	M=0
	@09802		//[]0
	M=0
	@09803		//[]0
	M=0

//[*](Row2)

	@01024		//[*]1024
	D=A
	@09804
	M=D
	@09805		//[]0
	M=0
	@09806		//[]0
	M=0
	@09807		//[]0
	M=0

//[***](Row3)

	@04352		//[**]4352
	D=A
	@09808
	M=D
	@09809		//[]0
	M=0
	@09810		//[]0
	M=0
	@00128		//[*]128
	D=A
	@09811
	M=D

//[**](Row4)

	@00128		//[*]128
	D=A
	@09812
	M=D
	@09813		//[]0
	M=0
	@09814		//[]0
	M=0
	@00064		//[*]64
	D=A
	@09815
	M=D

//[*****](Row5)

	@04224		//[**]4224
	D=A
	@09816
	M=D
	@09817		//[]0
	M=0
	@09818		//[]0
	M=0
	@00448		//[***]448
	D=A
	@09819
	M=D

//[*****](Row6)

	@03968		//[*****]3968
	D=A
	@09820
	M=D
	@09821		//[]0
	M=0
	@09822		//[]0
	M=0
	@09823		//[]0
	M=0

//[*](Row7)

	@09824		//[]0
	M=0
	@02048		//[*]2048
	D=A
	@09825
	M=D
	@09826		//[]0
	M=0
	@09827		//[]0
	M=0

//[*](Row8)

	@09828		//[]0
	M=0
	@01024		//[*]1024
	D=A
	@09829
	M=D
	@09830		//[]0
	M=0
	@09831		//[]0
	M=0

//[*****](Row9)

	@09832		//[]0
	M=0
	@07180		//[*****]7180
	D=A
	@09833
	M=D
	@09834		//[]0
	M=0
	@09835		//[]0
	M=0

//[**](Row10)

	@09836		//[]0
	M=0
	@00033		//[**]33
	D=A
	@09837
	M=D
	@09838		//[]0
	M=0
	@09839		//[]0
	M=0

//[*](Row11)

	@09840		//[]0
	M=0
	@09841		//[]0
	M=0
	D=-1		//[*]32768
	@32767
	D=D-A
	@09842
	M=D
	@09843		//[]0
	M=0

//[**](Row12)

	@09844		//[]0
	M=0
	@00032		//[*]32
	D=A
	@09845
	M=D
	D=-1		//[*]32768
	@32767
	D=D-A
	@09846
	M=D
	@09847		//[]0
	M=0

//[******](Row13)

	@09848		//[]0
	M=0
	@00031		//[*****]31
	D=A
	@09849
	M=D
	D=-1		//[*]32768
	@32767
	D=D-A
	@09850
	M=D
	@09851		//[]0
	M=0

//[](Row14)

	@09852		//[]0
	M=0
	@09853		//[]0
	M=0
	@09854		//[]0
	M=0
	@09855		//[]0
	M=0

//[****](Row15)

	@09856		//[]0
	M=0
	@09857		//[]0
	M=0
	@09858		//[]0
	M=0
	@03840		//[****]3840
	D=A
	@09859
	M=D

//[******](Row16)

	@09860		//[]0
	M=0
	@09861		//[]0
	M=0
	@09862		//[]0
	M=0
	@08064		//[******]8064
	D=A
	@09863
	M=D

//[*******](Row17)

	@09864		//[]0
	M=0
	@09865		//[]0
	M=0
	@00032		//[*]32
	D=A
	@09866
	M=D
	@07872		//[******]7872
	D=A
	@09867
	M=D

//[***](Row18)

	@09868		//[]0
	M=0
	@09869		//[]0
	M=0
	@00016		//[*]16
	D=A
	@09870
	M=D
	@00384		//[**]384
	D=A
	@09871
	M=D

//[***](Row19)

	@09872		//[]0
	M=0
	@09873		//[]0
	M=0
	@00112		//[***]112
	D=A
	@09874
	M=D
	@09875		//[]0
	M=0

//[**](Row20)

	@09876		//[]0
	M=0
	@09877		//[]0
	M=0
	@00001		//[*]1
	D=A
	@09878
	M=D
	D=-1		//[*]32768
	@32767
	D=D-A
	@09879
	M=D

//[***](Row21)

	@00512		//[*]512
	D=A
	@09880
	M=D
	@09881		//[]0
	M=0
	@00004		//[*]4
	D=A
	@09882
	M=D
	@00032		//[*]32
	D=A
	@09883
	M=D

//[**](Row22)

	@00256		//[*]256
	D=A
	@09884
	M=D
	@09885		//[]0
	M=0
	@09886		//[]0
	M=0
	@00016		//[*]16
	D=A
	@09887
	M=D

//[*****](Row23)

	@01792		//[***]1792
	D=A
	@09888
	M=D
	@09889		//[]0
	M=0
	@00004		//[*]4
	D=A
	@09890
	M=D
	@00016		//[*]16
	D=A
	@09891
	M=D

//[**************](Row24)

	@09892		//[]0
	M=0
	@09893		//[]0
	M=0
	@00003		//[**]3
	D=A
	@09894
	M=D
	D=-1		//[************]65520
	@00015
	D=D-A
	@09895
	M=D

//[*](Row25)

	@09896		//[]0
	M=0
	@09897		//[]0
	M=0
	@08192		//[*]8192
	D=A
	@09898
	M=D
	@09899		//[]0
	M=0

//[*](Row26)

	@09900		//[]0
	M=0
	@09901		//[]0
	M=0
	@04096		//[*]4096
	D=A
	@09902
	M=D
	@09903		//[]0
	M=0

//[*******](Row27)

	@09904		//[]0
	M=0
	@09905		//[]0
	M=0
	@28672		//[***]28672
	D=A
	@09906
	M=D
	@03840		//[****]3840
	D=A
	@09907
	M=D

//[******](Row28)

	@09908		//[]0
	M=0
	@09909		//[]0
	M=0
	@09910		//[]0
	M=0
	@08064		//[******]8064
	D=A
	@09911
	M=D

//[******](Row29)

	@09912		//[]0
	M=0
	@09913		//[]0
	M=0
	@09914		//[]0
	M=0
	@07872		//[******]7872
	D=A
	@09915
	M=D

//[**](Row30)

	@09916		//[]0
	M=0
	@09917		//[]0
	M=0
	@09918		//[]0
	M=0
	@00384		//[**]384
	D=A
	@09919
	M=D

//[](Row31)

	@09920		//[]0
	M=0
	@09921		//[]0
	M=0
	@09922		//[]0
	M=0
	@09923		//[]0
	M=0

//[](Row32)

	@09924		//[]0
	M=0
	@09925		//[]0
	M=0
	@09926		//[]0
	M=0
	@09927		//[]0
	M=0

//returntocaller

	@SP		//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//Automaticallygeneratedboardloadingcode

(Gosper.Glider.Gun)

//[]
//[*]
//[**]
//[******]
//[******]
//[******]
//[********]
//[***]
//[**]
//[**]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[**]
//[**]
//[*]
//[**]
//[]

//[](Row1)

	@09800		//[]0
	M=0
	@09801		//[]0
	M=0
	@09802		//[]0
	M=0
	@09803		//[]0
	M=0

//[*](Row2)

	@09804		//[]0
	M=0
	@00064		//[*]64
	D=A
	@09805
	M=D
	@09806		//[]0
	M=0
	@09807		//[]0
	M=0

//[**](Row3)

	@09808		//[]0
	M=0
	@00320		//[**]320
	D=A
	@09809
	M=D
	@09810		//[]0
	M=0
	@09811		//[]0
	M=0

//[******](Row4)

	@00006		//[**]6
	D=A
	@09812
	M=D
	@01536		//[**]1536
	D=A
	@09813
	M=D
	@06144		//[**]6144
	D=A
	@09814
	M=D
	@09815		//[]0
	M=0

//[******](Row5)

	@00008		//[*]8
	D=A
	@09816
	M=D
	D=-1		//[***]34304
	@31231
	D=D-A
	@09817
	M=D
	@06144		//[**]6144
	D=A
	@09818
	M=D
	@09819		//[]0
	M=0

//[******](Row6)

	@24592		//[***]24592
	D=A
	@09820
	M=D
	@17920		//[***]17920
	D=A
	@09821
	M=D
	@09822		//[]0
	M=0
	@09823		//[]0
	M=0

//[********](Row7)

	@24593		//[****]24593
	D=A
	@09824
	M=D
	@24896		//[****]24896
	D=A
	@09825
	M=D
	@09826		//[]0
	M=0
	@09827		//[]0
	M=0

//[***](Row8)

	@00016		//[*]16
	D=A
	@09828
	M=D
	@16448		//[**]16448
	D=A
	@09829
	M=D
	@09830		//[]0
	M=0
	@09831		//[]0
	M=0

//[**](Row9)

	@00008		//[*]8
	D=A
	@09832
	M=D
	D=-1		//[*]32768
	@32767
	D=D-A
	@09833
	M=D
	@09834		//[]0
	M=0
	@09835		//[]0
	M=0

//[**](Row10)

	@00006		//[**]6
	D=A
	@09836
	M=D
	@09837		//[]0
	M=0
	@09838		//[]0
	M=0
	@09839		//[]0
	M=0

//[](Row11)

	@09840		//[]0
	M=0
	@09841		//[]0
	M=0
	@09842		//[]0
	M=0
	@09843		//[]0
	M=0

//[](Row12)

	@09844		//[]0
	M=0
	@09845		//[]0
	M=0
	@09846		//[]0
	M=0
	@09847		//[]0
	M=0

//[](Row13)

	@09848		//[]0
	M=0
	@09849		//[]0
	M=0
	@09850		//[]0
	M=0
	@09851		//[]0
	M=0

//[](Row14)

	@09852		//[]0
	M=0
	@09853		//[]0
	M=0
	@09854		//[]0
	M=0
	@09855		//[]0
	M=0

//[](Row15)

	@09856		//[]0
	M=0
	@09857		//[]0
	M=0
	@09858		//[]0
	M=0
	@09859		//[]0
	M=0

//[](Row16)

	@09860		//[]0
	M=0
	@09861		//[]0
	M=0
	@09862		//[]0
	M=0
	@09863		//[]0
	M=0

//[](Row17)

	@09864		//[]0
	M=0
	@09865		//[]0
	M=0
	@09866		//[]0
	M=0
	@09867		//[]0
	M=0

//[](Row18)

	@09868		//[]0
	M=0
	@09869		//[]0
	M=0
	@09870		//[]0
	M=0
	@09871		//[]0
	M=0

//[](Row19)

	@09872		//[]0
	M=0
	@09873		//[]0
	M=0
	@09874		//[]0
	M=0
	@09875		//[]0
	M=0

//[](Row20)

	@09876		//[]0
	M=0
	@09877		//[]0
	M=0
	@09878		//[]0
	M=0
	@09879		//[]0
	M=0

//[](Row21)

	@09880		//[]0
	M=0
	@09881		//[]0
	M=0
	@09882		//[]0
	M=0
	@09883		//[]0
	M=0

//[](Row22)

	@09884		//[]0
	M=0
	@09885		//[]0
	M=0
	@09886		//[]0
	M=0
	@09887		//[]0
	M=0

//[](Row23)

	@09888		//[]0
	M=0
	@09889		//[]0
	M=0
	@09890		//[]0
	M=0
	@09891		//[]0
	M=0

//[](Row24)

	@09892		//[]0
	M=0
	@09893		//[]0
	M=0
	@09894		//[]0
	M=0
	@09895		//[]0
	M=0

//[](Row25)

	@09896		//[]0
	M=0
	@09897		//[]0
	M=0
	@09898		//[]0
	M=0
	@09899		//[]0
	M=0

//[](Row26)

	@09900		//[]0
	M=0
	@09901		//[]0
	M=0
	@09902		//[]0
	M=0
	@09903		//[]0
	M=0

//[](Row27)

	@09904		//[]0
	M=0
	@09905		//[]0
	M=0
	@09906		//[]0
	M=0
	@09907		//[]0
	M=0

//[**](Row28)

	@09908		//[]0
	M=0
	@09909		//[]0
	M=0
	@00096		//[**]96
	D=A
	@09910
	M=D
	@09911		//[]0
	M=0

//[**](Row29)

	@09912		//[]0
	M=0
	@09913		//[]0
	M=0
	@00080		//[**]80
	D=A
	@09914
	M=D
	@09915		//[]0
	M=0

//[*](Row30)

	@09916		//[]0
	M=0
	@09917		//[]0
	M=0
	@00016		//[*]16
	D=A
	@09918
	M=D
	@09919		//[]0
	M=0

//[**](Row31)

	@09920		//[]0
	M=0
	@09921		//[]0
	M=0
	@00024		//[**]24
	D=A
	@09922
	M=D
	@09923		//[]0
	M=0

//[](Row32)

	@09924		//[]0
	M=0
	@09925		//[]0
	M=0
	@09926		//[]0
	M=0
	@09927		//[]0
	M=0

//returntocaller

	@SP		//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//Automaticallygeneratedboardloadingcode

(Beacon.Maker)

//[*]
//[***]
//[***]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[**]
//[****]
//[**]
//[**]
//[*]

//[*](Row1)

	@09800		//[]0
	M=0
	@00001		//[*]1
	D=A
	@09801
	M=D
	@09802		//[]0
	M=0
	@09803		//[]0
	M=0

//[***](Row2)

	@09804		//[]0
	M=0
	@00002		//[*]2
	D=A
	@09805
	M=D
	@09806		//[]0
	M=0
	@00003		//[**]3
	D=A
	@09807
	M=D

//[***](Row3)

	@09808		//[]0
	M=0
	@00004		//[*]4
	D=A
	@09809
	M=D
	@09810		//[]0
	M=0
	@00005		//[**]5
	D=A
	@09811
	M=D

//[**](Row4)

	@09812		//[]0
	M=0
	@00008		//[*]8
	D=A
	@09813
	M=D
	@09814		//[]0
	M=0
	@00008		//[*]8
	D=A
	@09815
	M=D

//[**](Row5)

	@09816		//[]0
	M=0
	@00016		//[*]16
	D=A
	@09817
	M=D
	@09818		//[]0
	M=0
	@00016		//[*]16
	D=A
	@09819
	M=D

//[**](Row6)

	@09820		//[]0
	M=0
	@00032		//[*]32
	D=A
	@09821
	M=D
	@09822		//[]0
	M=0
	@00032		//[*]32
	D=A
	@09823
	M=D

//[**](Row7)

	@09824		//[]0
	M=0
	@00064		//[*]64
	D=A
	@09825
	M=D
	@09826		//[]0
	M=0
	@00064		//[*]64
	D=A
	@09827
	M=D

//[**](Row8)

	@09828		//[]0
	M=0
	@00128		//[*]128
	D=A
	@09829
	M=D
	@09830		//[]0
	M=0
	@00128		//[*]128
	D=A
	@09831
	M=D

//[**](Row9)

	@09832		//[]0
	M=0
	@00256		//[*]256
	D=A
	@09833
	M=D
	@09834		//[]0
	M=0
	@00256		//[*]256
	D=A
	@09835
	M=D

//[**](Row10)

	@09836		//[]0
	M=0
	@00512		//[*]512
	D=A
	@09837
	M=D
	@09838		//[]0
	M=0
	@00512		//[*]512
	D=A
	@09839
	M=D

//[**](Row11)

	@09840		//[]0
	M=0
	@01024		//[*]1024
	D=A
	@09841
	M=D
	@09842		//[]0
	M=0
	@01024		//[*]1024
	D=A
	@09843
	M=D

//[**](Row12)

	@09844		//[]0
	M=0
	@02048		//[*]2048
	D=A
	@09845
	M=D
	@09846		//[]0
	M=0
	@02048		//[*]2048
	D=A
	@09847
	M=D

//[**](Row13)

	@09848		//[]0
	M=0
	@04096		//[*]4096
	D=A
	@09849
	M=D
	@09850		//[]0
	M=0
	@04096		//[*]4096
	D=A
	@09851
	M=D

//[**](Row14)

	@09852		//[]0
	M=0
	@08192		//[*]8192
	D=A
	@09853
	M=D
	@09854		//[]0
	M=0
	@08192		//[*]8192
	D=A
	@09855
	M=D

//[**](Row15)

	@09856		//[]0
	M=0
	@16384		//[*]16384
	D=A
	@09857
	M=D
	@09858		//[]0
	M=0
	@16384		//[*]16384
	D=A
	@09859
	M=D

//[**](Row16)

	@09860		//[]0
	M=0
	D=-1		//[*]32768
	@32767
	D=D-A
	@09861
	M=D
	@09862		//[]0
	M=0
	D=-1		//[*]32768
	@32767
	D=D-A
	@09863
	M=D

//[**](Row17)

	@00001		//[*]1
	D=A
	@09864
	M=D
	@09865		//[]0
	M=0
	@00001		//[*]1
	D=A
	@09866
	M=D
	@09867		//[]0
	M=0

//[**](Row18)

	@00002		//[*]2
	D=A
	@09868
	M=D
	@09869		//[]0
	M=0
	@00002		//[*]2
	D=A
	@09870
	M=D
	@09871		//[]0
	M=0

//[**](Row19)

	@00004		//[*]4
	D=A
	@09872
	M=D
	@09873		//[]0
	M=0
	@00004		//[*]4
	D=A
	@09874
	M=D
	@09875		//[]0
	M=0

//[**](Row20)

	@00008		//[*]8
	D=A
	@09876
	M=D
	@09877		//[]0
	M=0
	@00008		//[*]8
	D=A
	@09878
	M=D
	@09879		//[]0
	M=0

//[**](Row21)

	@00016		//[*]16
	D=A
	@09880
	M=D
	@09881		//[]0
	M=0
	@00016		//[*]16
	D=A
	@09882
	M=D
	@09883		//[]0
	M=0

//[**](Row22)

	@00032		//[*]32
	D=A
	@09884
	M=D
	@09885		//[]0
	M=0
	@00032		//[*]32
	D=A
	@09886
	M=D
	@09887		//[]0
	M=0

//[**](Row23)

	@00064		//[*]64
	D=A
	@09888
	M=D
	@09889		//[]0
	M=0
	@00064		//[*]64
	D=A
	@09890
	M=D
	@09891		//[]0
	M=0

//[**](Row24)

	@00128		//[*]128
	D=A
	@09892
	M=D
	@09893		//[]0
	M=0
	@00128		//[*]128
	D=A
	@09894
	M=D
	@09895		//[]0
	M=0

//[**](Row25)

	@00256		//[*]256
	D=A
	@09896
	M=D
	@09897		//[]0
	M=0
	@00256		//[*]256
	D=A
	@09898
	M=D
	@09899		//[]0
	M=0

//[**](Row26)

	@00512		//[*]512
	D=A
	@09900
	M=D
	@09901		//[]0
	M=0
	@00512		//[*]512
	D=A
	@09902
	M=D
	@09903		//[]0
	M=0

//[**](Row27)

	@01024		//[*]1024
	D=A
	@09904
	M=D
	@09905		//[]0
	M=0
	@01024		//[*]1024
	D=A
	@09906
	M=D
	@09907		//[]0
	M=0

//[**](Row28)

	@02048		//[*]2048
	D=A
	@09908
	M=D
	@09909		//[]0
	M=0
	@02048		//[*]2048
	D=A
	@09910
	M=D
	@09911		//[]0
	M=0

//[****](Row29)

	@28672		//[***]28672
	D=A
	@09912
	M=D
	@09913		//[]0
	M=0
	@04096		//[*]4096
	D=A
	@09914
	M=D
	@09915		//[]0
	M=0

//[**](Row30)

	@04096		//[*]4096
	D=A
	@09916
	M=D
	@09917		//[]0
	M=0
	@08192		//[*]8192
	D=A
	@09918
	M=D
	@09919		//[]0
	M=0

//[**](Row31)

	@04096		//[*]4096
	D=A
	@09920
	M=D
	@09921		//[]0
	M=0
	@16384		//[*]16384
	D=A
	@09922
	M=D
	@09923		//[]0
	M=0

//[*](Row32)

	@09924		//[]0
	M=0
	@09925		//[]0
	M=0
	D=-1		//[*]32768
	@32767
	D=D-A
	@09926
	M=D
	@09927		//[]0
	M=0

//returntocaller

	@SP		//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

//Automaticallygeneratedboardloadingcode

(Blinker.Puffer)

//[]
//[]
//[*]
//[**]
//[*]
//[****]
//[***********]
//[******]
//[****]
//[]
//[**]
//[*****]
//[****************************************]
//[**]
//[]
//[**]
//[**]
//[*]
//[**]
//[******]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]
//[]

//[](Row1)

	@09800		//[]0
	M=0
	@09801		//[]0
	M=0
	@09802		//[]0
	M=0
	@09803		//[]0
	M=0

//[](Row2)

	@09804		//[]0
	M=0
	@09805		//[]0
	M=0
	@09806		//[]0
	M=0
	@09807		//[]0
	M=0

//[*](Row3)

	@00128		//[*]128
	D=A
	@09808
	M=D
	@09809		//[]0
	M=0
	@09810		//[]0
	M=0
	@09811		//[]0
	M=0

//[**](Row4)

	@00544		//[**]544
	D=A
	@09812
	M=D
	@09813		//[]0
	M=0
	@09814		//[]0
	M=0
	@09815		//[]0
	M=0

//[*](Row5)

	@01024		//[*]1024
	D=A
	@09816
	M=D
	@09817		//[]0
	M=0
	@09818		//[]0
	M=0
	@09819		//[]0
	M=0

//[****](Row6)

	@01056		//[**]1056
	D=A
	@09820
	M=D
	@09821		//[]0
	M=0
	@09822		//[]0
	M=0
	@00192		//[**]192
	D=A
	@09823
	M=D

//[***********](Row7)

	@01984		//[*****]1984
	D=A
	@09824
	M=D
	@09825		//[]0
	M=0
	@09826		//[]0
	M=0
	@00444		//[******]444
	D=A
	@09827
	M=D

//[******](Row8)

	@09828		//[]0
	M=0
	@09829		//[]0
	M=0
	@09830		//[]0
	M=0
	@00252		//[******]252
	D=A
	@09831
	M=D

//[****](Row9)

	@09832		//[]0
	M=0
	@09833		//[]0
	M=0
	@09834		//[]0
	M=0
	@00120		//[****]120
	D=A
	@09835
	M=D

//[](Row10)

	@09836		//[]0
	M=0
	@09837		//[]0
	M=0
	@09838		//[]0
	M=0
	@09839		//[]0
	M=0

//[**](Row11)

	@00768		//[**]768
	D=A
	@09840
	M=D
	@09841		//[]0
	M=0
	@09842		//[]0
	M=0
	@09843		//[]0
	M=0

//[*****](Row12)

	@01760		//[*****]1760
	D=A
	@09844
	M=D
	@09845		//[]0
	M=0
	@09846		//[]0
	M=0
	@09847		//[]0
	M=0

//[****************************************](Row13)

	@00967		//[*******]967
	D=A
	@09848
	M=D
	@30583		//[************]30583
	D=A
	@09849
	M=D
	@30583		//[************]30583
	D=A
	@09850
	M=D
	@30576		//[*********]30576
	D=A
	@09851
	M=D

//[**](Row14)

	@00384		//[**]384
	D=A
	@09852
	M=D
	@09853		//[]0
	M=0
	@09854		//[]0
	M=0
	@09855		//[]0
	M=0

//[](Row15)

	@09856		//[]0
	M=0
	@09857		//[]0
	M=0
	@09858		//[]0
	M=0
	@09859		//[]0
	M=0

//[**](Row16)

	@00048		//[**]48
	D=A
	@09860
	M=D
	@09861		//[]0
	M=0
	@09862		//[]0
	M=0
	@09863		//[]0
	M=0

//[**](Row17)

	@00132		//[**]132
	D=A
	@09864
	M=D
	@09865		//[]0
	M=0
	@09866		//[]0
	M=0
	@09867		//[]0
	M=0

//[*](Row18)

	@00256		//[*]256
	D=A
	@09868
	M=D
	@09869		//[]0
	M=0
	@09870		//[]0
	M=0
	@09871		//[]0
	M=0

//[**](Row19)

	@00260		//[**]260
	D=A
	@09872
	M=D
	@09873		//[]0
	M=0
	@09874		//[]0
	M=0
	@09875		//[]0
	M=0

//[******](Row20)

	@00504		//[******]504
	D=A
	@09876
	M=D
	@09877		//[]0
	M=0
	@09878		//[]0
	M=0
	@09879		//[]0
	M=0

//[](Row21)

	@09880		//[]0
	M=0
	@09881		//[]0
	M=0
	@09882		//[]0
	M=0
	@09883		//[]0
	M=0

//[](Row22)

	@09884		//[]0
	M=0
	@09885		//[]0
	M=0
	@09886		//[]0
	M=0
	@09887		//[]0
	M=0

//[](Row23)

	@09888		//[]0
	M=0
	@09889		//[]0
	M=0
	@09890		//[]0
	M=0
	@09891		//[]0
	M=0

//[](Row24)

	@09892		//[]0
	M=0
	@09893		//[]0
	M=0
	@09894		//[]0
	M=0
	@09895		//[]0
	M=0

//[](Row25)

	@09896		//[]0
	M=0
	@09897		//[]0
	M=0
	@09898		//[]0
	M=0
	@09899		//[]0
	M=0

//[](Row26)

	@09900		//[]0
	M=0
	@09901		//[]0
	M=0
	@09902		//[]0
	M=0
	@09903		//[]0
	M=0

//[](Row27)

	@09904		//[]0
	M=0
	@09905		//[]0
	M=0
	@09906		//[]0
	M=0
	@09907		//[]0
	M=0

//[](Row28)

	@09908		//[]0
	M=0
	@09909		//[]0
	M=0
	@09910		//[]0
	M=0
	@09911		//[]0
	M=0

//[](Row29)

	@09912		//[]0
	M=0
	@09913		//[]0
	M=0
	@09914		//[]0
	M=0
	@09915		//[]0
	M=0

//[](Row30)

	@09916		//[]0
	M=0
	@09917		//[]0
	M=0
	@09918		//[]0
	M=0
	@09919		//[]0
	M=0

//[](Row31)

	@09920		//[]0
	M=0
	@09921		//[]0
	M=0
	@09922		//[]0
	M=0
	@09923		//[]0
	M=0

//[](Row32)

	@09924		//[]0
	M=0
	@09925		//[]0
	M=0
	@09926		//[]0
	M=0
	@09927		//[]0
	M=0

//returntocaller

	@SP		//Jumpto[++SP]
	AM=M+1
	A=M
	0;JMP

