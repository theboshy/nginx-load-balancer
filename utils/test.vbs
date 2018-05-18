
Set shell = CreateObject("WScript.Shell")
'MsgBox port
stdout = Console("docker-machine ip default")
'shell.Run """.\\load_balance_test.bat"" " &stdout, 0
shell.Run""".\\load_balance_test.bat"" " & stdout, false
'shell.Run ".\\load_balance_test.bat"

'MsgBox out

Function Console(strCmd)
  Dim Wss, Cmd, Return, Output
  Set Wss = CreateObject("WScript.Shell")
  Set Cmd = Wss.Exec("cmd.exe")
  Cmd.StdIn.WriteLine strCmd & " 2>&1"
  Cmd.StdIn.Close
  While InStr(Cmd.StdOut.ReadLine, ">" & strCmd) = 0 : Wend
  Do : Output = Cmd.StdOut.ReadLine
    If Cmd.StdOut.AtEndOfStream Then Exit Do _
    Else Return = Return & Output & vbLf
  Loop
  Console = Return
End Function
