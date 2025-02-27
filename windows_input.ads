with Interfaces.C;
with System;

package Windows_Input is
   use Interfaces.C;

   type InputType is (Input_Mouse, Input_Keyboard, Input_Hardware);
   for InputType use (Input_Mouse => 0, Input_Keyboard => 1, Input_Hardware => 2);

   type Type_KEYBDINPUT is record
      wVk         : unsigned_short;
      wScan       : unsigned_short;
      dwFlags     : unsigned_long;
      time        : unsigned;
      dwExtraInfo : unsigned_long;
   end record;
   for Type_KEYBDINPUT use record
      wVk         at 0 range 0 .. 15;
      wScan       at 2 range 0 .. 15;
      dwFlags     at 4 range 0 .. 31;
      time        at 8 range 0 .. 31;
      dwExtraInfo at 12 range 0 .. 31;
   end record;
   for Type_KEYBDINPUT'Size use 128;

   type Type_KEYBDINPUT_Access is access all Type_KEYBDINPUT;

   type Type_KBINPUT is record
      itype : InputType;
      ki    : Type_KEYBDINPUT_Access;
   end record;
   for Type_KBINPUT use record
      itype at 0 range 0 .. 31;
      ki    at 4 range 0 .. 127;
   end record;
   for Type_KBINPUT'Size use 160;

   function SendInput (cInputs : unsigned;
                       pInputs : System.Address;
                       cbSize  : int) return unsigned
   with Import, Convention => Stdcall, Link_Name => "SendInput";

end Windows_Input;
