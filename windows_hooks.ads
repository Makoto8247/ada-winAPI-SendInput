with Interfaces.C;
with System;

package Windows_Hooks is
   use Interfaces.C;

   WH_KEYBOARD_LL : constant int := 13;

   function SetWindowsHookExA (idHook     : int;
                               lpfn       : System.Address;
                               hMod       : System.Address;
                               dwThreadId : unsigned) return System.Address
   with Import, Conversion => Stdcall, Link_Name => "SetWindowsHookExA";

   function UnhookWindowsHookEx (hhook : System.Address) return int
   with Import, Conversion => Stdcall, Link_Name => "UnhookWindowsHookEx";

   type KBDLLHOOKSTRUCT is record
      vkCode      : int := 0;
      scanCode    : int := 0;
      flags       : int := 0;
      time        : int := 0;
      dwExtraInfo : System.Address := System.Null_Address;
   end record;

   type KBDLLHOOKSTRUCT_Access is access all KBDLLHOOKSTRUCT;

end Windows_Hooks;
