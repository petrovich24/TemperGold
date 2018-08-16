program TemperGold;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows,
  SysUtils,
  jvSetupAPI,
  HID;

type
  TUSBBuf = array of byte;

var
  HidGUID: TGUID;
  PnPHandle: HDEVINFO;

  DeviceInterfaceData: TSPDeviceInterfaceData;
  FunctionClassDeviceData: PSPDeviceInterfaceDetailData;

  DevData: TSPDevInfoData;
  Success: boolean;
  DevIndex: integer;
  BytesRead: Cardinal;

  HidString: string;
  HidAttributes: THIDDAttributes;
  HidFileHandle: NativeUInt;

  buf: TUSBBuf;
  i: integer;
  hexstr: string;
  temp, tempc: real;
  Data: pointer;
  DeviceFound: boolean;
begin
  try
    LoadSetupApi;
    LoadHid;


    HidD_GetHidGuid(HidGUID);
    PnPHandle := SetupDiGetClassDevs(@HidGUID, nil, 0, DIGCF_PRESENT or DIGCF_DEVICEINTERFACE);

    if PnPHandle = Pointer(INVALID_HANDLE_VALUE) then
    begin
      Writeln('Error open PnPHandle');
      exit;
    end;

    try
      DevIndex := 0;
      DeviceFound := false;
      repeat
        DeviceInterfaceData.cbSize := sizeof(TSPDeviceInterfaceData);
        Success := SetupDiEnumDeviceInterfaces(PnPHandle, nil, HidGUID, DevIndex, DeviceInterfaceData);

        if Success then begin
        DevData.cbSize:=SizeOf(DevData);
          BytesRead:=0;
          SetupDiGetDeviceInterfaceDetail(PnPHandle, @DeviceInterfaceData, nil, 0, BytesRead, @DevData);
          if (BytesRead<>0)and(GetLastError = ERROR_INSUFFICIENT_BUFFER) then begin
            FunctionClassDeviceData:=AllocMem(BytesRead);
            FunctionClassDeviceData^.cbSize := SizeOf(TSPDeviceInterfaceDetailData);

            if SetupDiGetDeviceInterfaceDetail(PnPHandle, @DeviceInterfaceData, FunctionClassDeviceData,
                                             BytesRead, BytesRead, @DevData) then
            begin
              HidString:=StrPas(PChar(@FunctionClassDeviceData.DevicePath));
              //WriteLn(HidString);

              HidFileHandle := CreateFile(PChar(HidString), GENERIC_READ or GENERIC_WRITE,
                FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
              if HidFileHandle <> INVALID_HANDLE_VALUE then
              begin
                HidAttributes.Size := SizeOf(THIDDAttributes);
                if HidD_GetAttributes(HidFileHandle, HidAttributes) then
                begin
                  //WriteLn(IntToHex(HidAttributes.VendorID,2) + ':' + IntToHex(HidAttributes.ProductID,2));

                  if (HidAttributes.VendorID = $413d) and (HidAttributes.ProductID = $2107) then
                  begin
                    DeviceFound := true;
                    buf := TUsbBuf.Create($00, $01, $80, $33, $01, $00, $00, $00, $00);
                    WriteFile(HidFileHandle, Pointer(Buf)^, 9, BytesRead, nil);
                    if BytesRead <> 0 then
                    begin
                      ReadFile(HidFileHandle,Pointer(Buf)^, 9, BytesRead, nil);

                      if BytesRead <> 0 then
                      begin
                        Data := Pointer(Buf);
                        for i := 0 to BytesRead-1 do
                          hexstr := hexstr + IntToHex(Cardinal(PAnsiChar(Data)[I]),2) + ' ';

                        temp := Cardinal(PAnsiChar(Data)[4]) + (Cardinal(PAnsiChar(Data)[3]) shl 8);
                        tempc := temp / 100;
                        //WriteLn('Temperature = ' + FormatFloat('0.00',TempC));
                        WriteLn(FormatFloat('0.00',TempC));
                      end;
                    end;
                  end;

                end;
              end;


            end;
          end;

          FreeMem(FunctionClassDeviceData);
        end;

        Inc(DevIndex);
      until not Success;
    finally
      SetupDiDestroyDeviceInfoList(PnPHandle);
    end;

    if not DeviceFound then
      WriteLn('Device not found');

    //Readln(HidString);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
