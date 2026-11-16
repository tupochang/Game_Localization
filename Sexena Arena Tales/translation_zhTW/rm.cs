using System;
using System.Runtime.InteropServices;
using System.Text;
[StructLayout(LayoutKind.Sequential)] public struct RMPROC { public int pid; public long start; }
[StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] public struct RMPINFO { public RMPROC proc; [MarshalAs(UnmanagedType.ByValTStr, SizeConst=256)] public string app; [MarshalAs(UnmanagedType.ByValTStr, SizeConst=64)] public string svc; public uint type; public uint status; public uint session; [MarshalAs(UnmanagedType.Bool)] public bool restartable; }
public static class RM { [DllImport("rstrtmgr.dll", CharSet=CharSet.Unicode)] public static extern int RmStartSession(out uint h, int f, StringBuilder k); [DllImport("rstrtmgr.dll", CharSet=CharSet.Unicode)] public static extern int RmRegisterResources(uint h, uint nf, string[] files, uint na, IntPtr apps, uint ns, IntPtr svcs); [DllImport("rstrtmgr.dll")] public static extern int RmGetList(uint h, out uint needed, ref uint count, [In, Out] RMPINFO[] info, ref uint reasons); [DllImport("rstrtmgr.dll")] public static extern int RmEndSession(uint h); }
