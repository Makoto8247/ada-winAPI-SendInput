with Interfaces.C;
with System;

package Windows_Messages is
   use Interfaces.C;
   use System;

   type Type_HWND   is new Address;
   type Type_WPARAM is new Address;
   type Type_LPARAM is new Address;
   type Type_DWORD  is new unsigned;
   type Type_UINT   is new unsigned;

   type Type_POINT is record
      x : int;
      y : int;
   end record;

   type Type_MSG is record
      hwnd    : Type_HWND;
      message : Type_UINT;
      wParam  : Type_WPARAM;
      lParam  : Type_LPARAM;
      time    : Type_DWORD;
      pt      : Type_POINT;
   end record;

   function GetMessage (msg            : access Type_MSG;
                        hWnd           : Type_HWND;
                        wMsgFilterMin  : Type_UINT;
                        wMsgFilterMax  : Type_UINT) return int
   with Import, Convention => Stdcall, Link_Name => "GetMessageA";

   function DispatchMessage (msg : access Type_MSG) return int
   with Import, Convention => Stdcall, Link_Name => "DispatchMessageA";

end Windows_Messages;
