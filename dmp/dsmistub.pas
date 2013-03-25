unit DSMISTUB;
(********************************************************************
    This file is part of Ironseed.

    Ironseed is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Ironseed is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Ironseed.  If not, see <http://www.gnu.org/licenses/>.
********************************************************************)
(* This is just provides a stub for the DMP library. *)


interface

Uses detgus, det_aria, det_pas, det_sb, loaders, modload;

Const
   ID_SB	= 1;
   ID_SBPRO	= 2;
   ID_PAS	= 3;
   ID_PASPLUS	= 4;
   ID_PAS16	= 5;
   ID_SB16	= 6;
   ID_DAC	= 7;
   ID_ARIA	= 8;
   ID_WSS	= 9;
   ID_GUS	= 10;   
   LM_IML	= 1;
   LM_OLDTEMPO	= 2;
   MCP_QUALITY	= 1;
   MCP_486	= 2;
   MCP_Mono	= 4;
   PM_Loop	= 1;
   MD_Playing	= 1;
   MD_Paused	= 2;
   PAN_Left	= -63;
   PAN_Right	= 63;
   PAN_Middle	= 0;
   PAN_Surround	= 100;
	       

Type
   PModule = ^TModule;
   TModule = Record
		(*                           modType : Byte;
		Size				     : Longint;
		Filesize			     : Longint;
		Name				     : Array[0..31] of char;*)
		ChannelCount			     : Byte;
		(*ChannelPanning			     : Array[0..Max_Tracks-1] of shortint;
		InstrumentCount			     : Byte;
		Instruments			     : ^AMInstr;*)
		PatternCount			     : Byte;
		(*Patterns			     : ^AMPattern;
		TrackCount			     : Word;
		Tracks				     : ^AMTracks;
		Tempo				     : Byte;
		Speed				     : Byte;*)
	     End;				     
PSampleinfo        = ^TSampleInfo;
     TSampleInfo        = Record
                            Sample      : Pointer;
                            Length,
                            Loopstart,
                            Loopend     : Longint;
                            Mode        : Byte;
                            SampleID    : Word;
                          End;

PSoundCard        = ^TSoundCard;
      TSoundCard        = Record
                            ID          : Byte;
                            version     : Word;
                            name        : Array[0..31] of char;
                            IOPort      : Word;
                            dmaIRQ      : Byte;
                            dmaChannel  : Byte;
                            minRate     : Word;
                            maxRate     : Word;
                            Stereo      : Boolean;
                            mixer       : Boolean;
                            sampleSize  : Byte;
                            extraField  : array[0..7] of byte;
                          End;

Function initDSMI(rate,buffer,options:longint;scard:PSoundcard;override:boolean):Integer;
Function  mcpSetMasterVolume(Volume:longint):Integer;
Function  gusSetMasterVolume(Volume:longint):Integer;
Procedure mcpClearBuffer;
Function  ampPlayModule(module:PModule;opt:longint):integer;
Function  ampStopModule:integer;
Procedure ampFreeModule(var module:PModule);
Function ampLoadMOD(name:String;options:longint):PModule;
Function  mcpStartVoice:Integer;
Function  gusStartVoice:integer;
Function  cdiSetupChannels(channel,count:longint;volTable:pointer):integer;
Procedure cdiSetPan(channel:longint;pan:longint);
Procedure mcpConvertSample(Sample:Pointer;Length:Longint);
Function  mcpSetSample(Channel:longint;s:PSampleInfo):Integer;
Function  mcpPlaySample(channel:longint;rate:Longint;volume:longint):Integer;
Function  mcpPauseVoice:Integer;
Function  mcpResumeVoice:Integer;
Function  gusPauseAll:Integer;
Function  gusResumeAll:Integer;
Function  ampGetPattern:integer;
Function  ampGetRow:integer;
Function  ampGetModuleStatus:integer;
Procedure ampSetPanning(track,direction:longint);
Function GetCPUtype:Integer;
Function  emsInit(minmem,maxmem:integer):integer;
Function detectGUS(scard:PSoundcard):integer;
Function detectAria(scard:PSoundcard):integer;
Function detectSB16(scard:PSoundcard):integer;
Function detectSBPro(scard:PSoundcard):integer;
Function detectSB(scard:PSoundcard):integer;
Function detectPAS(scard:PSoundcard):integer;

implementation

   Function initDSMI(rate,buffer,options:longint;scard:PSoundcard;override:boolean):Integer;
   begin
      initDSMI := 0;
   end;

   Function  mcpSetMasterVolume(Volume:longint):Integer;
   begin
      mcpSetMasterVolume := 0;
   end;
   Function  gusSetMasterVolume(Volume:longint):Integer;
   begin
      gusSetMasterVolume := 0;
   end;
   Procedure mcpClearBuffer;
   begin
   end;
   Function  ampPlayModule(module:PModule;opt:longint):integer;
   begin
      ampPlayModule := 0;
   end;
   Function  ampStopModule:integer;
   begin
      ampStopModule := 0;
   end;
   Procedure ampFreeModule(var module:PModule);
   begin
      dispose(module);
   end;
   Function ampLoadMOD(name:String;options:longint):PModule;
   var
      module : PModule;
   begin
      new(module);
      ampLoadMOD := module;
   end;
   Function  mcpStartVoice:Integer;
   begin
      mcpStartVoice := 0;
   end;
   Function  gusStartVoice:integer;
   begin
      gusStartVoice := 0;
   end;
   Function  cdiSetupChannels(channel,count:longint;volTable:pointer):integer;
   begin
      cdiSetupChannels := 0;
   end;
   Procedure cdiSetPan(channel:longint;pan:longint);
   begin
   end;
   Procedure mcpConvertSample(Sample:Pointer;Length:Longint);
   begin
   end;
   Function  mcpSetSample(Channel:longint;s:PSampleInfo):Integer;
   begin
      mcpSetSample := 0;
   end;
   Function  mcpPlaySample(channel:longint;rate:Longint;volume:longint):Integer;
   begin
      mcpPlaySample := 0;
   end;
   Function  mcpPauseVoice:Integer;
   begin
      mcpPauseVoice := 0;
   end;
   Function  gusPauseAll:Integer;
   begin
      gusPauseAll := 0;
   end;
   Function  mcpResumeVoice:Integer;
   begin
      mcpResumeVoice := 0;
   end;
   Function  gusResumeAll:Integer;
   begin
      gusResumeAll := 0;
   end;
   Function  ampGetPattern:integer;
   begin
      ampGetPattern := 0;
   end;
   Function  ampGetRow:integer;
   begin
      ampGetRow := 0;
   end;
   Function  ampGetModuleStatus:integer;
   begin
      ampGetModuleStatus := MD_PLAYING;
   end;
   Procedure ampSetPanning(track,direction:longint);
   begin
   end;
   Function GetCPUtype:Integer;
   begin
      GetCPUtype := 0;
   end;
   Function  emsInit(minmem,maxmem:integer):integer;
   begin
      emsInit := 0;
   end;
   Function detectGUS(scard:PSoundcard):integer;
   begin
      detectGUS := 0;
   end;
   Function detectAria(scard:PSoundcard):integer;
   begin
      detectAria := 0;
   end;
   Function detectSB16(scard:PSoundcard):integer;
   begin
      detectSB16 := 0;
   end;
   Function detectSBPro(scard:PSoundcard):integer;
   begin
      detectSBPro := 0;
   end;
   Function detectSB(scard:PSoundcard):integer;
   begin
      detectSB := 0;
   end;
   Function detectPAS(scard:PSoundcard):integer;
   begin
      detectPAS := 0;
   end;
end.
