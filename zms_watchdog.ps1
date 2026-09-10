$sig=@'
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public static class ZmsWin {
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc f, IntPtr p);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint p);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr GetWindow(IntPtr h, uint c);
 [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
 [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
 public delegate bool EnumProc(IntPtr h, IntPtr p);
 public static List<IntPtr> Find(uint pid){var r=new List<IntPtr>(); EnumWindows((h,x)=>{uint q;GetWindowThreadProcessId(h,out q);if(q==pid&&IsWindowVisible(h)&&GetWindow(h,4)==IntPtr.Zero)r.Add(h);return true;},IntPtr.Zero);return r;}
 public static string Title(IntPtr h){var s=new StringBuilder(256);GetWindowText(h,s,s.Capacity);return s.ToString();}
}
'@
Add-Type $sig
while($true){
  if(-not $script:firstZanthp){$q=Get-Process zanthp -ErrorAction SilentlyContinue | Select-Object -First 1; if($q){$script:firstZanthp=$q.Id}}
  $game=Get-Process zanzarah -ErrorAction SilentlyContinue
  $p=Get-Process zanthp -ErrorAction SilentlyContinue
  if($game -and $p){ foreach($x in $p){if($x.Id -ne $script:firstZanthp){$w=[ZmsWin]::Find([uint32]$x.Id); foreach($extra in $w){[ZmsWin]::PostMessage($extra,0x0010,[IntPtr]::Zero,[IntPtr]::Zero)|Out-Null}}}}
  Start-Sleep -Milliseconds 300
}
