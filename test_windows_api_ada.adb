with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Interfaces.C; use Interfaces.C;
with System; use System;
with System.Win32;
with Windows_Input; use Windows_Input;
with Windows_Hooks; use Windows_Hooks;
with Windows_Messages; use Windows_Messages;

procedure Test_Windows_API_Ada is

   Hello_World : constant array (1 .. 11) of unsigned_short := 
      (16#48#, 16#45#, 16#4C#, 16#4C#, 16#4F#,  -- "HELLO"
       16#20#,                                  -- " " (スペース)
       16#57#, 16#4F#, 16#52#, 16#4C#, 16#44#); -- "WORLD"

   -- 入力イベントの配列
   Send_Message_Len : Integer := Hello_World'Length;
   Inputs : array (1 .. Send_Message_Len * 2) of Type_KBINPUT;
   Index  : Integer := 1;

   HookHandle : System.Address;

   -- コールバック関数
   function KeyboardProc (nCode  : int;
                          wParam : System.Address;
                          lParam : System.Address) return int
   with Convention => Stdcall;

   function KeyboardProc (nCode  : int;
                          wParam : System.Address;
                          lParam : System.Address) return int is
      KeyCode : int;
      Sent : unsigned;
      function Address_To_KBDLLHOOKSTRUCT is 
         new Ada.Unchecked_Conversion (System.Address, KBDLLHOOKSTRUCT_Access);
      KbdStruct : KBDLLHOOKSTRUCT_Access;
   begin
      Put_Line ("Get KeyboardProc.");
      KbdStruct := Address_To_KBDLLHOOKSTRUCT (lParam);
      KeyCode := kbdStruct.vkCode;
      Put_Line("KeyCode : " & KeyCode'Image);

      if nCode >= 0 then
         if KeyCode = 16#48# then -- H key
            Put_Line("Key pressed.");
            Sent := SendInput (unsigned (Inputs'Length),
                               Inputs'Address,
                               Type_KBINPUT'Size / 8);

            -- エラーチェック
            if Sent = 0 then
               declare
                  ErrCode : System.Win32.DWORD;
               begin
                  ErrCode := System.Win32.GetLastError;
                  Put_Line("Failed to send the message.");
                  Put_Line("Error code : " & ErrCode'Image);
               end;
               Put_Line("Failed to send the message.");
            end if;
         end if;
      end if;

      return 0;
   end KeyboardProc;

   -- メッセージループ用
   Msg_Tmp : aliased Type_MSG;
   
   Hook_Failed : exception;

begin
   Put_Line("Input message setting...");
   -- 各キーを押す & 離す
   for I in Hello_World'Range loop
      -- キーを押す
      Inputs (Index).itype          := Windows_Input.Input_Keyboard;
      declare
         Keybd_Input : aliased Windows_Input.Type_KEYBDINPUT;
      begin
         Keybd_Input.wVk         := Hello_World (I);
         Keybd_Input.wScan       := 0;
         Keybd_Input.dwFlags     := 0; -- 押す
         Keybd_Input.time        := 0;
         Keybd_Input.dwExtraInfo := 0;
         Inputs (Index).ki := Keybd_Input'Unchecked_Access;
      end;
      Index := Index + 1;

      -- キーを離す
      Inputs (Index).itype          := Windows_Input.Input_Keyboard;
      declare
         Keybd_Input : aliased Windows_Input.Type_KEYBDINPUT;
      begin
         Keybd_Input.wVk         := Hello_World (I);
         Keybd_Input.wScan       := 0;
         Keybd_Input.dwFlags     := 2; -- 離す
         Keybd_Input.time        := 0;
         Keybd_Input.dwExtraInfo := 0;
         Inputs (Index).ki := Keybd_Input'Unchecked_Access;
      end;
      Index := Index + 1;

   end loop;
   
   -- デバッグ用
   Put_Line("Type_KBINPUT'Size to Byte : " & Integer'Image (Type_KBINPUT'Size / 8 ));
   Put_Line("Type_KEYBDINPUT'Size to Byte : " & Integer'Image (Type_KEYBDINPUT'Size / 8 ));

   -- キーボードフックをセット
   Put_Line ("Keyboard hook setting...");
   HookHandle := SetWindowsHookExA (WH_KEYBOARD_LL,
                                    KeyboardProc'Address,
                                    System.Null_Address,
                                    0);
   if  HookHandle /= System.Null_Address then
      Put_Line("Hook set.");
   else
      raise Hook_Failed;
   end if;

   while GetMessage(Msg_Tmp'Access, Type_HWND (System.Null_Address), 0, 0) /= 0 loop
      declare
         Result : int;
      begin
         Result := DispatchMessage(Msg_Tmp'Access);
      end;
   end loop;

   -- フック解除処理
   if UnhookWindowsHookEx(HookHandle) = 0 then
      Put_Line ("Unhook.");
   end if;
exception
   when Hook_Failed =>
      Put_Line("Failed to set the hook.");
   when others =>
      Put_Line("Error.");
      if UnhookWindowsHookEx(HookHandle) = 0 then
         null;
      end if;
end Test_Windows_API_Ada;
