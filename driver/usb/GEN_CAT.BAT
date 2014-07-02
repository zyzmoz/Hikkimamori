set INF2CATPATH=D:\WinDDK\7100.0.0\bin\selfsign
set PATH=%PATH%;%INF2CATPATH%
inf2cat /driver:atenas  /os:XP_X64,XP_X86,Vista_X86,Vista_X64,7_X86,7_X64
inf2cat /driver:pireus_usbser  /os:XP_X64,XP_X86,Vista_X86,Vista_X64,7_X86,7_X64
