$TypeDefinition = @’
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class UnicodeInput {
    internal enum INPUT_TYPE : uint {
        INPUT_MOUSE = 0,
        INPUT_KEYBOARD = 1,
        INPUT_HARDWARE = 3
    }

    // Mouse input
    [StructLayout(LayoutKind.Sequential)]
    internal struct MOUSEINPUT
    {
        internal int dx;
        internal int dy;
        internal uint mouseData;
        internal MOUSEEVENTF dwFlags;
        internal uint time;
        internal UIntPtr dwExtraInfo;
    }

    [Flags]
    internal enum MOUSEEVENTF : uint
    {
        MOVE = 0x0001,
        LEFTDOWN = 0x0002,
        LEFTUP = 0x0004,
        RIGHTDOWN = 0x0008,
        RIGHTUP = 0x0010,
        MIDDLEDOWN = 0x0020,
        MIDDLEUP = 0x0040,
        XDOWN = 0x0080,
        XUP = 0x0100,
        WHEEL = 0x0800,
        HWHEEL = 0x01000,
        MOVE_NOCOALESCE = 0x2000,
        VIRTUALDESK = 0x4000,
        ABSOLUTE = 0x8000
    }

    // Keyboard input

    [StructLayout(LayoutKind.Sequential)]
    internal struct KEYBDINPUT
    {
        internal UInt16 wVk;
        internal UInt16 wScan;
        internal KEYEVENTF dwFlags;
        internal uint time;
        internal UIntPtr dwExtraInfo;
    }

    [Flags]
    internal enum KEYEVENTF : uint
    {
        KEYDOWN = 0x0000, 
        EXTENDEDKEY = 0x0001,
        KEYUP = 0x0002,
        SCANCODE = 0x0008,
        UNICODE = 0x0004
    }

    // Hardware Input

    [StructLayout(LayoutKind.Sequential)]
    internal struct HARDWAREINPUT
    {
        internal uint uMsg;
        internal UInt16 wParamL;
        internal UInt16 wParamH;
    }

    [StructLayout(LayoutKind.Explicit)]
    internal struct INPUT_UNION {
        [FieldOffset(0)]
        internal MOUSEINPUT mi;
        [FieldOffset(0)]
        internal KEYBDINPUT ki;
        [FieldOffset(0)]
        internal HARDWAREINPUT hi;
    }

    // Master Input structure
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT {
        internal INPUT_TYPE type;
        internal INPUT_UNION dummyunionname;         
    }

    private class Inner {
        [DllImport("user32.dll", SetLastError = true)]
        internal static extern uint SendInput (
            uint cInputs, 
            [MarshalAs(UnmanagedType.LPArray)]
            INPUT[] inputs,
            int cbSize
        );
    }

    internal static uint SendInput(uint cInputs, INPUT[] inputs, int cbSize) {
        return Inner.SendInput(cInputs, inputs, cbSize);
    }

    private static INPUT GetUnicodeKeyboardInput(UInt16 ch, KEYEVENTF flag) {
        INPUT i = new INPUT();
        i.type = INPUT_TYPE.INPUT_KEYBOARD;
        i.dummyunionname.ki.time = 0;
        i.dummyunionname.ki.wVk = 0;
        i.dummyunionname.ki.dwExtraInfo = UIntPtr.Zero;
        i.dummyunionname.ki.wScan = (UInt16) ch;
        i.dummyunionname.ki.dwFlags = flag | KEYEVENTF.UNICODE;
        return i;
    }

    public static void SendChar(char ch) {
        SendChar(ch, new INPUT[1]);
    }

    public static void SendChar(char ch, INPUT[] inputs) {
        inputs[0] = GetUnicodeKeyboardInput(ch, KEYEVENTF.KEYDOWN);
        SendInput(1, inputs, Marshal.SizeOf(typeof(INPUT)));

        // Release the key
        inputs[0] = GetUnicodeKeyboardInput(ch, KEYEVENTF.KEYUP);
        SendInput(1, inputs, Marshal.SizeOf(typeof(INPUT)));

        return;
    }

    public static void SendUnicode(string str) {
        char[] chars = str.ToCharArray();
        INPUT[] inputs = new INPUT[1];
        for (int i = 0; i < chars.Length; i++)
        {
            char ch = chars[i];
            SendChar(ch, inputs);
        }
        return;
    }
}

‘@

Add-Type -TypeDefinition  $TypeDefinition
Write-Host "testing started"
[UnicodeInput]::SendUnicode("東海之內，北海之隅，有國名曰朝鮮、天毒，其人水居，偎人愛人。西海之內，流沙之中，有國名曰壑市。西海之內，流沙之西，有國名曰沮葉。流沙之西，有鳥山者，三水出焉。爰有黃金、璿瑰、丹貨、銀鐵，皆流于此中。又有淮山，好水出焉。流沙之東，黑水之西，有朝雲之國、司彘之國。黃帝妻雷祖，生昌意，昌意降處若水，生韓流。韓流擢首、謹耳、人面、豕喙、麟身、渠股、豚止，取淖子曰阿女，生帝顓頊。")
